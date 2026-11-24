# Changelog

## [2.4.0] - 2026-11-24

### Neu
- Anhänge (BG-24, rechnungsbegründende Unterlagen) für ZUGFeRD 2.x und XRechnung: `Invoice#attachments` nimmt `Secretariat::Attachment`-Objekte (`filename`, `content` als Rohdaten, optional `description`) und bettet sie als `ram:AdditionalReferencedDocument` mit `TypeCode` 916 und Base64-kodiertem `AttachmentBinaryObject` ein. Der MIME-Typ ergibt sich aus der Dateiendung; zulässig sind die Typen der EN16931-Codeliste (BR-CL-24: PDF, PNG, JPEG, CSV, XLSX, ODS), andere führen ebenso wie doppelte Dateinamen (BR-DE-22) zu einem `ValidationError`; `Invoice#valid?`/`#errors` melden das bereits vorab. Mehrere Anhänge sind erlaubt (BG-24 ist 0..n), das EN16931-CII-Schematron gibt ab dem zweiten dann aber die Warnungen CII-SR-475/476 aus (Status bleibt gültig). Ohne `attachments` ändert sich die Ausgabe nicht. ZUGFeRD 1 (`version: 1`) kennt keine eingebetteten Anhänge — dort wird mit Anhängen ein Fehler geworfen.

## [2.3.0] - 2026-11-24

### Hinzugefügt
- `Invoice#payment_reference`: Verwendungszweck (BT-83) als `PaymentReference` im Zahlungsblock, für alle Dokumentversionen. Übernommen aus fortytools/ruby-secretariat (`dcf941f3`).

### Geändert
- **Geänderte Ausgabe:** Das XML beginnt jetzt mit `<?xml version="1.0" encoding="UTF-8"?>` und enthält Umlaute und Sonderzeichen direkt als UTF-8-Bytes statt als Zeichenreferenzen (`Fleethörn` statt `Fleeth&#xF6;rn`). Für XML-Parser ist das gleichwertig, die Bytes der Ausgabe ändern sich aber. Eingaben müssen in UTF-8 vorliegen; andere Kodierungen werden wie bisher zum Ersatzzeichen U+FFFD. Übernommen aus fortytools/ruby-secretariat (`19538c55`).
- `to_xml` schreibt bei ungültigen Beträgen nichts mehr auf stdout (`puts`/`pp`); die Fehler stehen weiterhin in `ValidationError#errors`.

### Korrigiert
- `LineItem#valid?`: Eine Abweichung zwischen Brutto minus Rabatt und Nettopreis landet als Eintrag in `errors`, statt die Liste durch einen String zu ersetzen.
- Ein leerer `discount_amount` (`""`) wird wie `nil` behandelt, statt in `valid?` mit `ArgumentError` abzubrechen.
- Ein `payment_reference` aus Leerzeichen erzeugt kein leeres `PaymentReference`-Element.

## [2.2.2] - 2026-11-24

### Geändert
- Mustang-CLI 2.25.0 → 2.26.0. Die CLI-Validierung prüft XRechnungen jetzt gegen das EN16931-Schematron 1.3.16 (vorher 1.3.15), das für CII strenger ist (u. a. Zahlungsart BT-81..83, BT-123/BT-128, Summenblock, Zu- und Abschläge). ZUGFeRD-Rechnungen prüft Mustang weiter mit den unveränderten FeRD-Regeln. Die Schemas und der Validator des Gems sind nicht betroffen.

## [2.2.1] - 2026-09-19

### Geändert
- Release-Workflow nach dem Vorbild aus `ruby_gkv_billing`.
- Abdeckung wird gemessen (`COVERAGE=1`), Untergrenze 75 % bei aktuell 80,22 %.

### Korrigiert
- CI prueft auch Pull Requests, deren Ziel ein Branch mit Schraegstrich ist.
- `actions/checkout` von v3 auf v7 (v3 ist fuer die heutigen Runner zu alt).

## 2.2.0

- [CHG] Schemas auf **Factur-X 1.09.2 (ZUGFeRD 2.5.2)** aktualisiert (gültig ab 1. September 2026). Die XSDs sind inhaltlich unverändert (die 2.5.2-XSD-Änderungen betreffen nur das nicht gebündelte Profil EXTENDED); die Schematron-Regeln wurden aktualisiert (u. a. BR-CO-27 → CII-SR-470, neuer Metadaten-Header)
- [CHG] Schematron und codedb liegen jetzt unter den FeRD-Originalnamen ohne Versionssuffix (`FACTUR-X_EN16931.sch`, `FACTUR-X_EN16931_codedb.xml`); `Validator::SCHEMA_VERSION` steuert nur noch die XSD-Dateinamen
- [CHG] Mustang-CLI 2.24.0 → 2.25.0: Validierungsregeln für ZUGFeRD 2.5.2/Factur-X 1.09.2, VeraPDF-Sicherheitsfixes (CVE-2026-54078, CVE-2026-54079)
- [CHG] Neue Specs: `document()`-Referenzen im Factur-X-Schematron zeigen auf vorhandene Dateien; die bekannte XSLT-2-Einschränkung (Schematron-Validierung für version 2/3 ist weiterhin **nicht** nutzbar) ist als Spec festgehalten
- [FIX] XRechnung-v3-URN (BT-24) auf den seit XRechnung 3.0 gültigen KoSIT-Namensraum aktualisiert: `urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0` (vorher `urn:xoev-de:kosit:standard:xrechnung_3.0` → BR-DE-21-Warnung)
- [FIX] `ShipToTradeParty` (BG-13) enthält nur noch ID, Name und Adresse (EN16931 CII-SR-310..315): Kontakt-, Register- und Steuerdaten der Liefer-Partei werden nicht mehr ausgegeben — beim Buyer bleiben sie im `BuyerTradeParty`-Block vollständig erhalten (`TradeParty#to_xml` hat dafür einen neuen Parameter `ship_to:`)
- [FIX] Dient der Käufer als Lieferanschrift, wird seine Debitorennummer nicht mehr als Lieferort-Kennung (BT-71) ausgegeben — sie ist BT-46 und bleibt im `BuyerTradeParty` erhalten. Bei explizitem `recipient` wird dessen `trade_party_id` weiterhin als BT-71 übernommen
- [CHG] `TradeParty#to_xml`: Parameter `exclude_tax:` entfernt (durch `ship_to:` abgelöst, hatte keine Aufrufer mehr)

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
