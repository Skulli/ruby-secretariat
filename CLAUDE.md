# CLAUDE.md

Hinweise für Claude Code bei der Arbeit in diesem Repository.

## Projekt

Ruby-Gem `secretariat`: Generator und Validator für elektronische Rechnungen (ZUGFeRD/Factur-X, XRechnung; CII-Syntax) plus PDF/A-3-Export via Mustang-CLI. Eigenständig gepflegter Fork: `halfbyte/ruby-secretariat` → `fortytools/ruby-secretariat` (XRechnung-Modus) → `Skulli/ruby-secretariat`.

**Fork-Strategie („Hybrid + Rückgabe", Entscheidung Juli 2026):** Der Fork bleibt führend (Schemas sind mit Factur-X 1.09 neuer als Upstream, XRechnung-Modus und Mustang-Export gibt es nur hier). Upstream-Releases von halfbyte/fortytools werden halbjährlich gesichtet und einzelne Fixes gezielt nachgebaut (Cherry-Picks konfligieren wegen 6+ Jahren Divergenz); generisch Verwertbares (z. B. Schema-Updates) wird als PR an halfbyte zurückgegeben. Kein Voll-Rebase auf Upstream — dessen API hat kein `mode:` und ein inkompatibles `taxes`-Array-Modell.

## Befehle

```sh
bundle exec rspec        # Tests; Schematron-Specs dauern ~1 Min., PDF-Export-Specs benötigen Java
bundle exec standardrb   # Code-Style (Pflicht vor Commit, CI prüft)
```

Manuelle End-to-End-Validierung eines erzeugten XML/PDF (Regelwerk wird per Guideline-URN automatisch erkannt):

```sh
java -jar lib/secretariat/export/bin/jar/Mustang-CLI-2.24.0.jar --no-notices --action validate --source <datei>
```

## Architektur

- `lib/secretariat/invoice.rb` — Kern: `Invoice`-Struct, Betragskonsistenzprüfung (`valid?`), XML-Generator `to_xml(version:, mode:, skip_validation:)`. version 1/2/3, mode `:zugferd`/`:xrechnung`. Nur `version: 3` + `mode: :xrechnung` erzeugt die XRechnung-3.0-URN, alles andere die neutrale EN16931-URN. Am Ende werden **leere XML-Knoten entfernt** — Elemente ohne Inhalt verschwinden stillschweigend (Ursache eines früheren AccountName-Bugs).
- `lib/secretariat/line_item.rb`, `trade_party.rb` — Positions- bzw. Parteien-Structs mit eigenem `to_xml`.
- `lib/secretariat/versioner.rb` — `by_version(version, v1_wert, v2_wert)`: Version 2 und 3 werden **identisch** behandelt.
- `lib/secretariat/validator.rb` — XSD-/Schematron-Validierung. Kennt kein `mode`; version 2 und 3 teilen sich die Factur-X-Schemas. `SCHEMA_VERSION` (Factur-X-Version, z. B. "1.09") ist bewusst getrennt von `Secretariat::VERSION` (Gem-Version) — nicht verwechseln.
- `lib/secretariat/constants.rb` — Code-Mappings (Steuerkategorien, Zahlungsarten, Einheiten, Rechnungstypen).
- `lib/secretariat/export/zugferd_pdf.rb` — Mustang-Aufrufe (`convert_to_a3`, `combine_files`, `validate_zugerd_pdf` [sic]); wird **nicht** automatisch geladen (`require "secretariat/export"`).
- `schemas/zugferd_1/`, `schemas/zugferd_2/` — ZUGFeRD-1.0- bzw. Factur-X-1.09-EN16931-Schemas (XSD + Schematron).

## Wichtige Fallstricke

- Die Schematron-Validierung der Factur-X-Regeln scheitert am fehlenden XSLT-2-Support von `schematron-nokogiri` (betroffene Specs stehen auf `pending`). ZUGFeRD-1-Schematron funktioniert.
- Die KoSIT-XRechnung-Regeln (BR-DE-*) sind **nicht** im Gem — vollständige XRechnung-Prüfung nur über die Mustang-CLI. XRechnung 3.0 verlangt u. a. Verkäufer-Kontakt (BR-DE-2) und bei offenem Betrag ein Fälligkeitsdatum oder Zahlungsbedingungen (BR-CO-25).
- Pro Rechnung wird nur **ein Steuersatz** unterstützt (kein `taxes`-Array wie im Upstream).
- Das Mustang-JAR (~56 MB) liegt im Repo — bei Updates Dateinamen in `zugferd_pdf.rb` sowie README/CLAUDE.md anpassen und die PDF-Export-Specs plus einen manuellen `--action validate`-Lauf gegen ein v3-XML ausführen.

## Konventionen

- Kommunikation, Kommentare, Commit-Messages und Doku auf **Deutsch**; Commit-Präfixe `fix:dev:` / `chg:dev:` (kurze einzeilige Messages, Details ggf. im Body).
- Branch-Namen mit Unterstrichen (z. B. `fix_accountname_validator_v3`, `feature_zugferd_25`); PRs gegen `main`.
- Bei Änderungen: `CHANGELOG.md` pflegen und bei Merges nach `main` die Gem-Version in `lib/secretariat/version.rb` bumpen (Bugfixes = Patch); Releases auf `main` als `vX.Y.Z` taggen.
- Der Hauptnutzer des Gems (symdok) folgt `branch: "main"` — jeder Merge nach `main` ist faktisch ein Release; Verhaltensänderungen im CHANGELOG kenntlich machen.
