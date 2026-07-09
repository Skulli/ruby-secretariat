# Changelog

## 2.1.4

- [FIX] Kontoinhaber wird jetzt als `<ram:AccountName>` ausgegeben (wurde bisher nie ins XML geschrieben)
- [FIX] `Validator` unterstützt `version: 3` (nutzt die Factur-X-Schemas von Version 2); unbekannte Versionen werfen `ArgumentError`
- [CHG] Unerreichbaren `xrechnung_2.3`-Zweig und abgekündigte XRechnung-2.x-URNs entfernt: `mode: :xrechnung` liefert die XRechnung-3.0-URN nur noch bei `version: 3`, sonst die neutrale EN16931-Kennung
- [CHG] Specs ergänzt: Guideline-URNs je mode/version, AccountName-Ausgabe, Validator v3

## 2.1.3 (Tag `v2.1.3`, Sammelstand des Forks)

Fork-Stand Skulli/ruby-secretariat (basiert auf fortytools/ruby-secretariat, Fork von halfbyte/ruby-secretariat). Wichtigste Änderungen gegenüber 2.0.0:

- ZUGFeRD 2.5: Schemas auf Factur-X 1.09 EN16931 aktualisiert (zuvor schrittweise 2.2 → 2.3 → 2.3.2 → 2.3.3)
- XRechnung-Modus: `to_xml(mode: :xrechnung)` mit versionsspezifischen KoSIT-URNs (aus fortytools übernommen und erweitert)
- `BusinessProcessSpecifiedDocumentContextParameter` (Peppol-URN) auch im ZUGFeRD-Modus
- PDF-Export via Mustang-CLI (`Secretariat::Export::ZugferdPdf`): PDF/A-Konvertierung, Kombination PDF+XML, Validierung
- Diverse Felder ergänzt (invoice_type, Debitorennummer, Rechnungszeitraum, BIC/Kontoinhaber, Projekt-Daten, Header-/Footer-Texte, payment_due_date)
- Leere XML-Knoten werden entfernt; Umstellung der Tests auf RSpec

## 2.0.0

- [BREAKING] Validators and XML generators now need a version to use to be able to support ZUGFeRD 1.0
