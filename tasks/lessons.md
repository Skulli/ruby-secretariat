# Lessons Learned

## Schema-/Artefakt-Updates (2026-08, ZUGFeRD 2.5.2)

- Wenn ein Update die Verknüpfung zwischen Dateien ändert (hier: unversionierter `.sch`-Name + 59 relative `document()`-Referenzen auf die codedb), diese Verknüpfung explizit per Spec absichern — nicht nur darauf verweisen, dass sie „weiterhin funktioniert". Statischer Existenz-Check reicht, wenn ein echter Lauf (XSLT 2) nicht möglich ist.
- `SchematronNokogiri::Schema.new` wirft bei `queryBinding="xslt2"` bereits beim **Laden**, nicht erst bei `validate` — eine „lädt ohne Fehler"-Spec ist für die Factur-X-Schematrons falsch; stattdessen die bekannte Einschränkung als erwarteten Fehler asserten.
- Bei FeRD-Schema-Releases immer prüfen, ob zeitgleich ein Mustang-Release mit passendem Regelwerk existiert, und beides zusammen aktualisieren (End-to-End-Validierung testet dann gegen die echten neuen Regeln).
- Ruby `File.read` auf die FeRD-`.sch` braucht `encoding: "UTF-8"` (sonst `invalid byte sequence in US-ASCII` bei `scan`).

## GitHub-Workflow (2026-08)

- `gh pr create` wählt bei Fork-Repos standardmäßig das **Upstream-Repo** (fortytools) als Base — PRs hier immer explizit mit `--repo Skulli/ruby-secretariat` erstellen (passiert bei PR #10: erst versehentlich fortytools#18 erstellt, geschlossen, neu erstellt).

## XML-Ausgabe und Versionierung (2026-11, PR #17)

- `Nokogiri::XML::Builder.new(encoding: "UTF-8")` schreibt Strings in anderer Kodierung (ISO-8859-1, BINARY, kaputtes UTF-8) als Rohbytes ins XML, das dann nicht mehr wohlgeformt ist. Ohne `encoding:` kam `&#xFFFD;` heraus. Wer die Ausgabe-Kodierung ändert, prüft auch Eingaben, die nicht UTF-8 sind (Abhilfe hier: `scrub("�")` am Ende von `to_xml`).
- Ein neues Feature oder eine geänderte Ausgabe bedeutet einen Minor-Bump, keinen Patch. Eine Änderung an den Bytes der Ausgabe steht im CHANGELOG als Verhaltensänderung, auch wenn sie für XML-Parser keinen Unterschied macht, denn symdok folgt direkt `main`.
