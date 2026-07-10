# ruby-secretariat — ZUGFeRD/XRechnung-XML-Generator und -Validator

![Testing](https://github.com/Skulli/ruby-secretariat/actions/workflows/ci.yml/badge.svg?branch=main)
<a href="https://github.com/testdouble/standard" target="_blank">
  <img alt="Ruby Code Style" src="https://img.shields.io/badge/Ruby_Code_Style-standard-brightgreen.svg" />
</a>

Ruby-Gem zum Erzeugen und Validieren elektronischer Rechnungen im ZUGFeRD-/Factur-X- und XRechnung-Format (CII-Syntax), inklusive PDF/A-3-Export über die Mustang-CLI.

Dies ist ein eigenständig gepflegter Fork: [halfbyte/ruby-secretariat](https://github.com/halfbyte/ruby-secretariat) → [fortytools/ruby-secretariat](https://github.com/fortytools/ruby-secretariat) (XRechnung-Modus) → **Skulli/ruby-secretariat** (Schema-Updates bis ZUGFeRD 2.5, PDF-Export, Fixes).

## Unterstützte Formate

| `version` | `mode` | Ergebnis |
|---|---|---|
| 1 | `:zugferd` | ZUGFeRD 1.0 (`CrossIndustryDocument`) |
| 2 | `:zugferd` | ZUGFeRD 2.x / Factur-X, Profil EN16931 (`urn:cen.eu:en16931:2017`) |
| 3 | `:zugferd` | wie Version 2 (identische CII-Struktur) |
| 3 | `:xrechnung` | XRechnung 3.0 (`urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_3.0`) |

Die mitgelieferten Schemas entsprechen **Factur-X 1.09 (ZUGFeRD 2.5), Profil EN16931**. Für ZUGFeRD 2.x wird ausschließlich das EN16931-Profil unterstützt. `mode: :xrechnung` mit `version: 2` fällt auf die neutrale EN16931-URN zurück (die XRechnung-2.x-URNs sind abgekündigt).

## Installation

```ruby
# Gemfile
gem "secretariat", github: "Skulli/ruby-secretariat", branch: "main"
```

## Verwendung

```ruby
require "secretariat"

seller = Secretariat::TradeParty.new(
  name: "Muster GmbH",
  street1: "Musterstraße 1",
  city: "Hamburg",
  postal_code: "20253",
  country_id: "DE",
  vat_id: "DE123456789",
  contact_name: "Max Mustermann",       # Pflicht für XRechnung (BR-DE-2)
  contact_phone: "+49 40 123456",
  contact_email: "rechnung@example.com"
)

buyer = Secretariat::TradeParty.new(
  name: "Kunde AG",
  street1: "Kundenweg 2",
  city: "Berlin",
  postal_code: "10115",
  country_id: "DE",
  vat_id: "DE987654321"
)

line_item = Secretariat::LineItem.new(
  name: "Beratungsleistung",
  quantity: 1,
  unit: :PIECE,
  gross_amount: "29",
  net_amount: "29",
  charge_amount: "29",
  tax_category: :STANDARDRATE,
  tax_percent: "19",
  tax_amount: "5.51",
  origin_country_code: "DE",
  currency_code: "EUR"
)

invoice = Secretariat::Invoice.new(
  id: "RE-2026-0001",
  issue_date: Date.today,
  seller: seller,
  buyer: buyer,
  line_items: [line_item],
  currency_code: "EUR",
  payment_type: :SEPA_CREDIT,
  payment_text: "Überweisung",
  payment_iban: "DE02120300000000202051",
  payment_bic: "BYLADEM1001",
  payment_account_name: "Muster GmbH",
  payment_due_date: Date.today + 14,    # Pflicht bei offenem Betrag (BR-CO-25)
  tax_category: :STANDARDRATE,
  tax_percent: "19",
  tax_amount: "5.51",
  basis_amount: "29",
  grand_total_amount: "34.51",
  due_amount: "34.51",
  paid_amount: 0,
  buyer_reference: "04011000-12345-03", # Leitweg-ID für XRechnung
  invoice_type: :INVOICE
)

xml = invoice.to_xml(version: 3, mode: :xrechnung)  # XRechnung 3.0
xml = invoice.to_xml(version: 2)                    # ZUGFeRD 2.x / Factur-X EN16931
```

`to_xml` prüft vorab die Betragskonsistenz (Steuer, Summen, Positionssummen) und wirft bei Abweichungen einen `Secretariat::ValidationError` mit Fehlerliste (`skip_validation: true` überspringt das). Leere XML-Knoten werden vor der Ausgabe entfernt. Weitere Beispiele in den Specs (`spec/lib/secretariat/`).

## Validierung

```ruby
validator = Secretariat::Validator.new(xml, version: 3) # v2 und v3 teilen sich die Factur-X-Schemas
validator.validate_against_schema      # XSD; leeres Array = valide
validator.validate_against_schematron  # EN16931-Schematron (siehe Hinweis)
```

**Hinweise:**
- Die Schematron-Validierung scheitert für die Factur-X-Regeln derzeit am fehlenden XSLT-2-Support des `schematron-nokogiri`-Gems (ZUGFeRD-1-Regeln funktionieren).
- Die **KoSIT-XRechnung-Regeln (BR-DE-*) sind nicht enthalten** — `mode: :xrechnung` ist ein Generator-Modus, kein Validierungsprofil. Für eine vollständige Prüfung eignet sich die mitgelieferte Mustang-CLI:

```sh
java -jar lib/secretariat/export/bin/jar/Mustang-CLI-2.16.5.jar \
  --no-notices --action validate --source rechnung.xml
```

Mustang erkennt anhand der Guideline-URN automatisch das richtige Regelwerk (XRechnung 3.0 bzw. Factur-X EN16931).

## PDF-Export (ZUGFeRD-PDF, PDF/A-3)

Erfordert Java. Der Export wird nicht automatisch geladen:

```ruby
require "secretariat/export"

pdf_a3 = Secretariat::Export::ZugferdPdf.convert_to_a3(source_pdf: "rechnung.pdf") # PDF/A-1 → PDF/A-3
Secretariat::Export::ZugferdPdf.combine_files(                                     # PDF + XML → ZUGFeRD-PDF
  source_pdf: pdf_a3,
  source_xml: "rechnung.xml",
  output_dir: "tmp",
  output_filename: "rechnung_zugferd.pdf"
)
Secretariat::Export::ZugferdPdf.validate_zugerd_pdf("tmp/rechnung_zugferd.pdf")    # Mustang-Validierung
```

## Entwicklung

```sh
bundle install
bundle exec rspec       # PDF-Export-Specs benötigen Java
bundle exec standardrb  # Code-Style
```

Änderungen bitte im [CHANGELOG.md](CHANGELOG.md) dokumentieren; Releases werden auf `main` getaggt (`vX.Y.Z`, siehe `lib/secretariat/version.rb`).

## Einschränkungen

1. Die Bibliothek ist bewusst schlank („opinionated") und auf konkrete Anwendungsfälle zugeschnitten — pro Rechnung wird z. B. nur **ein Steuersatz** unterstützt.
2. Die eingebauten Konsistenzprüfungen verhindern grobe Fehler, garantieren aber keine steuerrechtliche Korrektheit des erzeugten XML.
3. XRechnung-Pflichtangaben wie Leitweg-ID (`buyer_reference`), Verkäufer-Kontakt und Fälligkeitsdatum muss der Aufrufer selbst befüllen (siehe Beispiel oben).

## Lizenz

Siehe [LICENSE](LICENSE) (Apache 2.0). Die Schemadateien sind laut ZUGFeRD-Dokumentation ebenfalls Apache-lizenziert. Das Projekt nutzt nokogiri und schematron-nokogiri (beide MIT) sowie die [Mustang-CLI](https://www.mustangproject.org/) (APL 2.0). Ursprüngliche Autoren und Beitragende: siehe die Upstream-Projekte [halfbyte/ruby-secretariat](https://github.com/halfbyte/ruby-secretariat) und [fortytools/ruby-secretariat](https://github.com/fortytools/ruby-secretariat).
