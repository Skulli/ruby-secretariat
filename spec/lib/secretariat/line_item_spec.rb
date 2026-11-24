require "spec_helper"

RSpec.describe Secretariat::LineItem do
  describe "#valid? mit Rabatt" do
    subject {
      described_class.new(
        name: "Material", quantity: 1, unit: :PIECE,
        gross_amount: "100", discount_amount: "10", net_amount: "85", charge_amount: "85",
        tax_category: :STANDARDRATE, tax_percent: 19, tax_amount: "16.15", currency_code: "EUR"
      )
    }

    it "sammelt die Abweichung von Brutto minus Rabatt als Eintrag in errors" do
      expect(subject.valid?).to be(false)
      expect(subject.errors).to eq(["Calculated net price and net price deviate: 0.9e2 / 0.85e2"])
    end
  end
end
