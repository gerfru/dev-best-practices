#!/usr/bin/env bash
# Validates the plugin structure: plugin.json, marketplace.json, SKILL.md frontmatter, command references.
set -eu

PLUGIN_DIR="plugins/dev"
ERRORS=0

fail() { echo "❌ $*" >&2; ERRORS=$((ERRORS + 1)); }
pass() { echo "✅ $*"; }

json_has_field() {
  grep -q "\"${1}\"[[:space:]]*:" "$2"
}

# --- plugin.json ---
echo "=== plugin.json ==="
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
if [[ ! -f "$PLUGIN_JSON" ]]; then
  fail "Missing: $PLUGIN_JSON"
else
  for field in name version description; do
    if ! json_has_field "$field" "$PLUGIN_JSON"; then
      fail "$PLUGIN_JSON: missing required field: $field"
    fi
  done
  pass "plugin.json valid"
fi

# --- marketplace.json ---
echo "=== marketplace.json ==="
MARKETPLACE_JSON=".claude-plugin/marketplace.json"
if [[ ! -f "$MARKETPLACE_JSON" ]]; then
  fail "Missing: $MARKETPLACE_JSON"
else
  while IFS= read -r source; do
    source=$(echo "$source" | tr -d '\r' | sed 's/.*"source"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/')
    if [[ -n "$source" && ! -d "$source" ]]; then
      fail "$MARKETPLACE_JSON: source path does not exist: '$source'"
    fi
  done < <(grep '"source"' "$MARKETPLACE_JSON")
  pass "marketplace.json valid"
fi

# --- Skills: each folder must have a valid SKILL.md ---
echo "=== skills ==="
if [[ ! -d "$PLUGIN_DIR/skills" ]]; then
  fail "Missing directory: $PLUGIN_DIR/skills"
else
  for skill_dir in "$PLUGIN_DIR/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"

    if [[ ! -f "$skill_md" ]]; then
      fail "[$skill_name] Missing SKILL.md"
      continue
    fi

    first_line=$(head -1 "$skill_md" | tr -d '\r')
    if [[ "$first_line" != "---" ]]; then
      fail "[$skill_name] SKILL.md must start with YAML frontmatter (---)"
      continue
    fi

    for field in name description; do
      if ! grep -q "^${field}:" "$skill_md"; then
        fail "[$skill_name] SKILL.md frontmatter missing required field: $field"
      fi
    done

    pass "[$skill_name] ok"
  done
fi

# --- Commands: frontmatter + referenced skill must exist ---
echo "=== commands ==="
if [[ -d "$PLUGIN_DIR/commands" ]]; then
  for cmd_file in "$PLUGIN_DIR/commands"/*.md; do
    [[ -f "$cmd_file" ]] || continue
    cmd_name=$(basename "$cmd_file" .md)

    first_line=$(head -1 "$cmd_file" | tr -d '\r')
    if [[ "$first_line" != "---" ]]; then
      fail "[$cmd_name] command must start with YAML frontmatter (---)"
      continue
    fi

    if ! grep -q "^description:" "$cmd_file"; then
      fail "[$cmd_name] command frontmatter missing required field: description"
    fi

    ref_skill=$(grep -o 'skills/[^/]*/SKILL\.md' "$cmd_file" | head -1 | cut -d'/' -f2 || true)
    if [[ -n "$ref_skill" && ! -d "$PLUGIN_DIR/skills/$ref_skill" ]]; then
      fail "[$cmd_name] references non-existent skill folder: $ref_skill"
    fi

    pass "[$cmd_name] ok"
  done
else
  echo "(no commands directory — skipped)"
fi

# --- Summary ---
echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo "❌ $ERRORS error(s) found — fix before committing"
  exit 1
else
  echo "✅ All skill validation checks passed"
fi
