# Changelog

## 2.2.0

- [CHG] Schemas auf **Factur-X 1.09.2 (ZUGFeRD 2.5.2)** aktualisiert (gültig ab 1. September 2026). Die XSDs sind inhaltlich unverändert (die 2.5.2-XSD-Änderungen betreffen nur das nicht gebündelte Profil EXTENDED); die Schematron-Regeln wurden aktualisiert (u. a. BR-CO-27 → CII-SR-470, neuer Metadaten-Header)
- [CHG] Schematron und codedb liegen jetzt unter den FeRD-Originalnamen ohne Versionssuffix (`FACTUR-X_EN16931.sch`, `FACTUR-X_EN16931_codedb.xml`); `Validator::SCHEMA_VERSION` steuert nur noch die XSD-Dateinamen
- [CHG] Mustang-CLI 2.24.0 → 2.25.0: Validierungsregeln für ZUGFeRD 2.5.2/Factur-X 1.09.2, VeraPDF-Sicherheitsfixes (CVE-2026-54078, CVE-2026-54079)
- [CHG] Neue Specs: `document()`-Referenzen im Schematron zeigen auf vorhandene Dateien, Schematron lädt für version 2/3
- [FIX] XRechnung-v3-URN (BT-24) auf den seit XRechnung 3.0 gültigen KoSIT-Namensraum aktualisiert: `urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0` (vorher `urn:xoev-de:kosit:standard:xrechnung_3.0` → BR-DE-21-Warnung)
- [FIX] `ShipToTradeParty` (BG-13) enthält nur noch ID, Name und Adresse (EN16931 CII-SR-310..315): Kontakt-, Register- und Steuerdaten der Liefer-Partei werden nicht mehr ausgegeben — beim Buyer bleiben sie im `BuyerTradeParty`-Block vollständig erhalten (`TradeParty#to_xml` hat dafür einen neuen Parameter `ship_to:`)

## 2.1.4

- [FIX] Kontoinhaber wird jetzt als `<ram:AccountName>` ausgegeben (wurde bisher nie ins XML geschrieben)
- [FIX] `Validator` unterstützt `version: 3` (nutzt die Factur-X-Schemas von Version 2); unbekannte Versionen werfen `ArgumentError`
- [CHG] Unerreichbaren `xrechnung_2.3`-Zweig und abgekündigte XRechnung-2.x-URNs entfernt: `mode: :xrechnung` liefert die XRechnung-3.0-URN nur noch bei `version: 3`, sonst die neutrale EN16931-Kennung
- [CHG] Specs ergänzt: Guideline-URNs je mode/version, AccountName-Ausgabe, Validator v3
- [CHG] Mustang-CLI 2.16.5 → 2.24.0: Validierungsregeln jetzt aktuell (XRechnung 3.0.2, EN16931-Schematron 1.3.15, ZUGFeRD 2.5/Factur-X 1.09), PDFBox-Sicherheitsfixes. Achtung: strengeres Regelwerk — XRechnung verlangt jetzt u. a. die elektronische Adresse des Käufers (BT-49, `contact_email` am buyer)
- [CHG] README überarbeitet (deutsch, lauffähiges Beispiel, Format-Tabelle), CLAUDE.md ergänzt

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
