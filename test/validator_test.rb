require "test_helper"

module Secretariat
  class ValidatorTest < Minitest::Test
    def test_schema_validator_2
      xml = File.open(File.join(__dir__, "fixtures/zugferd_2/extended.xml"))
      v = Validator.new(xml, version: 2)
      assert_equal [], v.validate_against_schema
    end

    def test_schematron_validator_2
      xml = File.open(File.join(__dir__, "fixtures/zugferd_2/extended.xml"))
      v = Validator.new(xml, version: 2)
      assert_equal [], v.validate_against_schematron
    end

    def test_schema_validator_1
      xml = File.open(File.join(__dir__, "fixtures/zugferd_1/einfach.xml"))
      v = Validator.new(xml, version: 1)
      assert_equal [], v.validate_against_schema
    end

    def test_schematron_validator_1
      xml = File.open(File.join(__dir__, "fixtures/zugferd_1/einfach.xml"))
      v = Validator.new(xml, version: 1)
      assert_equal [], v.validate_against_schematron
    end
  end
end
