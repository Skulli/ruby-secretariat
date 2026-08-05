# Lessons Learned

## Schema-/Artefakt-Updates (2026-08, ZUGFeRD 2.5.2)

- Wenn ein Update die Verknüpfung zwischen Dateien ändert (hier: unversionierter `.sch`-Name + 59 relative `document()`-Referenzen auf die codedb), diese Verknüpfung explizit per Spec absichern — nicht nur darauf verweisen, dass sie „weiterhin funktioniert". Statischer Existenz-Check reicht, wenn ein echter Lauf (XSLT 2) nicht möglich ist.
- `SchematronNokogiri::Schema.new` wirft bei `queryBinding="xslt2"` bereits beim **Laden**, nicht erst bei `validate` — eine „lädt ohne Fehler"-Spec ist für die Factur-X-Schematrons falsch; stattdessen die bekannte Einschränkung als erwarteten Fehler asserten.
- Bei FeRD-Schema-Releases immer prüfen, ob zeitgleich ein Mustang-Release mit passendem Regelwerk existiert, und beides zusammen aktualisieren (End-to-End-Validierung testet dann gegen die echten neuen Regeln).
- Ruby `File.read` auf die FeRD-`.sch` braucht `encoding: "UTF-8"` (sonst `invalid byte sequence in US-ASCII` bei `scan`).

## GitHub-Workflow (2026-08)

- `gh pr create` wählt bei Fork-Repos standardmäßig das **Upstream-Repo** (fortytools) als Base — PRs hier immer explizit mit `--repo Skulli/ruby-secretariat` erstellen (passiert bei PR #10: erst versehentlich fortytools#18 erstellt, geschlossen, neu erstellt).
