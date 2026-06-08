import re, glob, os

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8', newline='') as f:
        lines = f.readlines()

    inside = False
    result = []
    changed = False

    for line in lines:
        stripped = line.rstrip('\r\n')
        if re.match(r'^```', stripped):
            if inside:
                # closing fence — must be plain ```
                if stripped != '```':
                    line = line.replace(stripped, '```', 1)
                    changed = True
                inside = False
            else:
                # opening fence — add 'text' if bare
                if stripped == '```':
                    line = line.replace('```', '```text', 1)
                    changed = True
                inside = True
        result.append(line)

    if changed:
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            f.writelines(result)
        print(f'fixed: {filepath}')

os.chdir(r'c:\_Private\Dev\dev-best-practices')
for f in glob.glob('**/*.md', recursive=True):
    fix_file(f)

print('done')
