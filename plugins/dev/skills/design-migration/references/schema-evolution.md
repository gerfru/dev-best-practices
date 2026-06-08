# Schema Evolution — Referenz

Quelle: Kleppmann "Designing Data-Intensive Applications" (O'Reilly 2017), Kap. 4 + Kap. 11.

## Forward vs. Backward Compatibility (Kleppmann Kap. 4)

| Begriff | Definition | Konkret |
|---|---|---|
| **Backward Compatibility** | Neuer Code kann alte Daten lesen | Code v2 liest Daten die mit v1 geschrieben wurden |
| **Forward Compatibility** | Alter Code kann neue Daten lesen | Code v1 liest Daten die mit v2 geschrieben wurden |

**Ziel bei Rolling Deployments:** Beides — neue und alte Code-Version laufen gleichzeitig.

### Regeln fuer Schema-Aenderungen

| Aenderung | Backward compat. | Forward compat. | Sicher? |
|---|---|---|---|
| Neues optionales Feld hinzufuegen | ✅ (Defaultwert) | ✅ (ignoriert) | ✅ Sicher |
| Pflichtfeld hinzufuegen | ❌ Alter Code hat kein Feld | ✅ | ❌ Gefaehrlich |
| Feld entfernen | ✅ | ❌ Alter Code erwartet Feld | ❌ Expand-Contract noetig |
| Typ aendern (int → string) | ❌ | ❌ | ❌ Breaking Change |
| Feld umbenennen | ❌ | ❌ | ❌ Breaking Change |
| Enum-Wert hinzufuegen | ✅ | ❌ Alter Code kennt Wert nicht | ⚠️ Pruefe alle Consumer |

**Expand-Contract Pattern fuer Feld-Entfernung:**

```text
Phase 1 — Expand:  Neues Feld hinzufuegen, beide Felder parallel schreiben
Phase 2 — Migrate: Alte Daten in neues Feld migrieren, altes Feld nur noch lesen
Phase 3 — Contract: Altes Feld entfernen (kein Code liest es mehr)
```

---

## Dual-Write Problem (Kleppmann Kap. 11)

Wenn zwei Stores gleichzeitig geschrieben werden (z.B. DB + Search Index):

**Problem:** Kein atomares Commit ueber beide Systeme moeglich.

| Szenario | Risiko |
|---|---|
| Write A erfolgreich, Write B fehlgeschlagen | Stores divergieren |
| Write B zuerst sichtbar (Reihenfolge) | Inkonsistenter Zustand |
| Fehler nach Write A, vor Write B | Partieller Zustand |

**Loesungen nach Kleppmann:**

1. **Change Data Capture (CDC):** Nur in DB schreiben, CDC liest Transaction Log und
   aktualisiert Secondary Stores. Kausal korrekte Reihenfolge durch Log-Basis.

2. **Outbox Pattern:** Schreibe Event + Daten in einer DB-Transaktion in Outbox-Tabelle.
   Separater Processor liest Outbox und publiziert Events.

3. **Event Log als Source of Truth:** Alle Schreiboperationen als Events in ordered Log
   (Kafka). Alle Stores sind Read-Models die den Log konsumieren.

---

## Change Data Capture (CDC) (Kleppmann Kap. 11)

CDC liest den Transaction Log der Datenbank (binlog bei MySQL, WAL bei PostgreSQL).

```text
Anwendung → DB (Write) → Transaction Log → CDC Connector → Event Stream → Consumer
```

**Vorteile gegenueber Dual-Write:**
- Kausal korrekte Reihenfolge (Log-Reihenfolge)
- Kein Auslassen von Aenderungen
- Low Latency (nahezu real-time)
- Kein Applikationscode-Aenderung noetig

**CDC Tools:**
- **Debezium** (Open Source, Kafka Connect) — PostgreSQL, MySQL, MongoDB, SQL Server
- **AWS DMS** — managed CDC fuer AWS-Ziele
- **Google Datastream** — managed CDC fuer GCP

**Migration via CDC (Zero-Downtime DB-Migration):**

```text
1. CDC auf Quell-DB aktivieren (liest WAL/binlog ab Checkpoint)
2. Initial Snapshot in Ziel-DB laden
3. CDC streamt alle Delta-Aenderungen in Ziel-DB (Aufholen)
4. Lesen aus Ziel-DB aktivieren (Shadow Read)
5. Divergenz-Pruefung (Quelle vs. Ziel)
6. Schreiben auf Ziel umschalten (Dual-Write-Phase entfaellt)
7. Quelle abschalten nach Confidence-Periode
```

---

## Avro Schema Registry (Kleppmann Kap. 4)

Fuer Event-Driven Architekturen: Schema-Version mit Event mitschicken.

**Avro Schema Evolution Regeln:**
- Feld hinzufuegen: Default-Wert angeben → backward + forward compat
- Feld entfernen: Default-Wert in altem Schema angeben → backward + forward compat
- Kein Default: Breaking Change

**Confluent Schema Registry Pattern:**
- Schema-ID im Message Header (`magic byte + schema ID`)
- Reader liest Schema-ID, holt Schema aus Registry, konvertiert
- Alte und neue Schemas koennen parallel existieren

---

## Entscheidungsbaum: Welche Migration-Technik?

```text
Muss altes System weiterlaufen waehrend neu deployed wird?
├─ Nein → Maintenance Window, Big Bang (nur bei kleinen/unkritischen Systemen)
└─ Ja →
   Handelt es sich um Schema-Aenderung in DB?
   ├─ Ja → Expand-Contract Pattern (Phasen: expand → migrate → contract)
   └─ Nein (neues System / neuer Store) →
      Ist Daten-Konsistenz zwischen Stores kritisch?
      ├─ Ja → CDC (Debezium) + Divergenz-Pruefung
      └─ Nein / OK mit eventual consistency → Dual-Write + Timeout-basierte Migration
```
