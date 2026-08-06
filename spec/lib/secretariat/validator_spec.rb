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

  context "version 3 (nutzt die Factur-X-Schemas von version 2)" do
    let(:xml) { File.open(Secretariat.file_path("spec/fixtures/zugferd_2/extended.xml")) }
    subject { described_class.new(xml, version: 3) }

    it {
      expect(subject.validate_against_schema).to be_empty
    }
  end

  context "Schematron-Artefakte" do
    # Ein echter Schematron-Lauf für v2/v3 scheitert an XSLT 2 (siehe pending oben),
    # daher wird die Verknüpfung .sch -> codedb hier statisch abgesichert.
    # Nur das Factur-X-Schematron referenziert externe Dateien (die codedb);
    # ZUGFeRD1p0.sch kommt ohne document() aus und wird hier deshalb nicht geprüft.
    it "alle document()-Referenzen im Factur-X-Schematron zeigen auf vorhandene Dateien" do
      idx = 1
      lib_dir = Secretariat.file_path("lib/secretariat")
      schema_dir = File.expand_path(described_class::SCHEMA_DIR[idx], lib_dir)
      sch = File.read(File.expand_path(described_class::SCHEMATRON[idx], lib_dir), encoding: "UTF-8")
      referenced = sch.scan(/document\('([^']+)'\)/).flatten.uniq
      expect(referenced).not_to be_empty
      referenced.each do |filename|
        expect(File).to exist(File.join(schema_dir, filename)),
          "#{filename} wird im Schematron referenziert, fehlt aber in #{schema_dir}"
      end
    end

    # Die Meldung stammt aus <xsl:message terminate="yes"> im ISO-Schematron-Skeleton und
    # wird von Nokogiri/libxslt durchgereicht — die Exception-Klasse ist damit ein
    # Implementierungsdetail von Nokogiri (Constraint nur ">= 1.10"). Entscheidend ist die Meldung.
    it "scheitert beim Laden des Factur-X-Schematrons an der bekannten XSLT-2-Einschränkung" do
      [2, 3].each do |version|
        validator = described_class.new("<xml/>", version: version)
        expect { validator.schematron }.to raise_error(StandardError, /xslt2/i)
      end
    end
  end

  context "nicht unterstützte Version" do
    it "lehnt version 4 mit klarer Fehlermeldung ab" do
      expect { described_class.new("<xml/>", version: 4) }
        .to raise_error(ArgumentError, /Unsupported Document Version: 4 \(supported: 1\.\.3\)/)
    end

    it "lehnt nil ab" do
      expect { described_class.new("<xml/>", version: nil) }
        .to raise_error(ArgumentError, /Unsupported Document Version: nil/)
    end

    it "lehnt nicht-numerische Werte ab" do
      expect { described_class.new("<xml/>", version: "2") }
        .to raise_error(ArgumentError, /Unsupported Document Version: "2"/)
    end
  end
end
