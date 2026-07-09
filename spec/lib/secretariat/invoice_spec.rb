require "spec_helper"

RSpec.describe Secretariat::Invoice do
  let(:seller) {
    Secretariat::TradeParty.new(
      name: "Depfu inc",
      street1: "Quickbornstr. 46",
      city: "Hamburg",
      postal_code: "20253",
      country_id: "DE",
      vat_id: "DE304755032"
    )
  }

  let(:buyer) {
    Secretariat::TradeParty.new(
      name: "Depfu inc",
      street1: "Quickbornstr. 46",
      city: "Hamburg",
      postal_code: "20253",
      country_id: "SE",
      vat_id: "SE304755032"
    )
  }

  let(:line_item) {
    Secretariat::LineItem.new(
      name: "Depfu Starter Plan",
      quantity: 1,
      gross_amount: "29",
      net_amount: "29",
      unit: :PIECE,
      charge_amount: "29",
      tax_category: :REVERSECHARGE,
      tax_percent: 0,
      tax_amount: "0",
      origin_country_code: "DE",
      currency_code: "EUR"
    )
  }

  subject {
    described_class.new(
      id: "12345",
      issue_date: Date.today,
      seller: seller,
      buyer: buyer,
      line_items: [line_item],
      currency_code: "USD",
      payment_type: :CREDITCARD,
      payment_text: "Kreditkarte",
      tax_category: :REVERSECHARGE,
      tax_percent: 0,
      tax_amount: "0",
      basis_amount: "29",
      grand_total_amount: 29,
      due_amount: 0,
      paid_amount: 29,
      buyer_reference: "REF-112233",
      invoice_type: :INVOICE
    )
  }

  describe "valid xml schema version 2" do
    let(:xml) { subject.to_xml(version: 2) }

    let(:validator) { Secretariat::Validator.new(xml, version: 2) }

    it {
      expect(validator.validate_against_schema).to be_empty
    }
  end

  describe "valid xml schema version 1" do
    let(:xml) { subject.to_xml(version: 1) }

    let(:validator) { Secretariat::Validator.new(xml, version: 1) }

    it {
      expect(validator.validate_against_schema).to be_empty
    }
  end

  describe "valid xml schematron version 2" do
    let(:xml) { subject.to_xml(version: 2) }

    let(:validator) { Secretariat::Validator.new(xml, version: 2) }

    it {
      pending "not working with xslt"
      expect(validator.validate_against_schematron).to be_empty
    }
  end

  describe "valid xml schematron version 1" do
    let(:xml) { subject.to_xml(version: 1) }

    let(:validator) { Secretariat::Validator.new(xml, version: 1) }

    it {
      pending
      expect(validator.validate_against_schematron).to be_empty
    }
  end

  context "xrechnung" do
    describe "valid xml schema version 2" do
      let(:xml) { subject.to_xml(version: 2, mode: :xrechnung) }

      let(:validator) { Secretariat::Validator.new(xml, version: 2) }

      it {
        expect(validator.validate_against_schema).to be_empty
      }
    end

    describe "valid xml schema version 3" do
      let(:xml) { subject.to_xml(version: 3, mode: :xrechnung) }

      let(:validator) { Secretariat::Validator.new(xml, version: 3) }

      it {
        expect(validator.validate_against_schema).to be_empty
      }
    end
  end

  describe "GuidelineSpecifiedDocumentContextParameter" do
    def guideline_id(xml)
      doc = Nokogiri::XML(xml)
      doc.remove_namespaces!
      doc.at_xpath("//GuidelineSpecifiedDocumentContextParameter/ID")&.text
    end

    it "setzt für ZUGFeRD v2 die neutrale EN16931-URN" do
      expect(guideline_id(subject.to_xml(version: 2))).to eq("urn:cen.eu:en16931:2017")
    end

    it "setzt für ZUGFeRD v3 die neutrale EN16931-URN" do
      expect(guideline_id(subject.to_xml(version: 3))).to eq("urn:cen.eu:en16931:2017")
    end

    it "setzt für XRechnung v3 die XRechnung-3.0-URN" do
      expect(guideline_id(subject.to_xml(version: 3, mode: :xrechnung)))
        .to eq("urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_3.0")
    end

    it "fällt für XRechnung v2 (abgekündigte 2.x-URNs) auf die EN16931-URN zurück" do
      expect(guideline_id(subject.to_xml(version: 2, mode: :xrechnung))).to eq("urn:cen.eu:en16931:2017")
    end
  end

  describe "Zahlungsangaben mit IBAN und Kontoinhaber" do
    subject {
      super().tap do |invoice|
        invoice.payment_type = :SEPA_CREDIT
        invoice.payment_iban = "DE02120300000000202051"
        invoice.payment_bic = "BYLADEM1001"
        invoice.payment_account_name = "Depfu inc"
      end
    }

    let(:xml) { subject.to_xml(version: 2) }

    it "gibt den Kontoinhaber als AccountName aus" do
      doc = Nokogiri::XML(xml)
      doc.remove_namespaces!
      account = doc.at_xpath("//PayeePartyCreditorFinancialAccount")
      expect(account.at_xpath("IBANID")&.text).to eq("DE02120300000000202051")
      expect(account.at_xpath("AccountName")&.text).to eq("Depfu inc")
    end

    it "bleibt schema-valide" do
      expect(Secretariat::Validator.new(xml, version: 2).validate_against_schema).to be_empty
    end
  end
end
