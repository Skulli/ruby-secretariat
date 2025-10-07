require "spec_helper"
require "./lib/secretariat/export"

RSpec.describe Secretariat::Export::ZugferdPdf, type: :module do
  let(:source_pdf) { Secretariat.file_path("spec/fixtures/zugferd_2/test_a1.pdf") }
  let(:source_xml) { Secretariat.file_path("spec/fixtures/zugferd_2/test-x.xml") }
  let(:output_dir) { Dir.mktmpdir }
  let(:output_filename2) { "output2.pdf" }
  let(:output_file_path) { File.join(output_dir, "test_a1_a3.pdf") }
  let(:output_file_path2) { File.join(output_dir, output_filename2) }
  let(:attachments_pathlist) { "" }

  after(:each) do
    FileUtils.remove_entry(output_dir) if File.exist?(output_dir)
  end

  describe "convert_file" do
    it "converts a1 to a3" do
      result = described_class.convert_to_a3(
        source_pdf: source_pdf,
        output_dir: output_dir
      )

      expect(result).to eq(output_file_path)
      expect(File.exist?(result)).to be(true)
    end

    after do
      File.delete(output_file_path) if File.exist?(output_file_path)
    end
  end

  describe "combine_files" do
    it "combines PDF and XML files" do
      result = described_class.combine_files(
        source_pdf: source_pdf,
        source_xml: source_xml,
        output_filename: output_filename2,
        output_dir: output_dir
      )

      expect(result).to eq(output_file_path2)
      expect(File.exist?(result)).to be(true)

      validate = described_class.validate_zugerd_pdf(output_file_path2)
      expect(validate).to be(false)
    end

    after do
      File.delete(output_file_path2) if File.exist?(output_file_path2)
    end
  end
end
