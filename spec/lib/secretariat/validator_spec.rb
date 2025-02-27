require "spec_helper"

RSpec.describe Secretariat::Validator do
  context "zugpferd2 schema extended" do
    let(:xml) { File.open(Secretariat.file_path("spec/fixtures/zugferd_2/extended.xml")) }
    subject { described_class.new(xml, version: 2) }

    it {
      expect(subject.validate_against_schema).to be_empty
    }
  end

  context "zugpferd2 schematron extended" do
    let(:xml) { File.open(Secretariat.file_path("spec/fixtures/zugferd_2/extended.xml")) }
    subject { described_class.new(xml, version: 2) }

    it {
      pending "not working with xslt"
      expect(subject.validate_against_schematron).to be_empty
    }
  end

  describe "zugpferd1 schema extended" do
    context "valid" do
      let(:xml) { File.open(Secretariat.file_path("spec/fixtures/zugferd_1/einfach.xml")) }
      subject { described_class.new(xml, version: 1) }

      it {
        expect(subject.validate_against_schema).to be_empty
      }
    end

    context "invalid" do
      let(:xml) { File.open(Secretariat.file_path("spec/fixtures/zugferd_1/invalid.xml")) }
      subject { described_class.new(xml, version: 1) }

      it {
        expect(subject.validate_against_schema).not_to be_empty
      }
    end
  end

  context "zugpferd1 schematron extended" do
    let(:xml) { File.open(Secretariat.file_path("spec/fixtures/zugferd_1/einfach.xml")) }
    subject { described_class.new(xml, version: 1) }

    it {
      expect(subject.validate_against_schematron).to be_empty
    }
  end
end
