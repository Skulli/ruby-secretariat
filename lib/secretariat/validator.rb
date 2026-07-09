# Copyright Jan Krutisch
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "nokogiri"
require "schematron-nokogiri"
require "open-uri"

module Secretariat
  class Validator
    SCHEMA_VERSION = "1.09"
    SCHEMATRON = [
      "../../schemas/zugferd_1/ZUGFeRD1p0.sch",
      "../../schemas/zugferd_2/Factur-X_#{SCHEMA_VERSION}_EN16931.sch"
    ]

    SCHEMA = [
      "../../schemas/zugferd_1/ZUGFeRD1p0.xsd",
      "../../schemas/zugferd_2/Factur-X_#{SCHEMA_VERSION}_EN16931.xsd"
    ]

    SCHEMA_DIR = [
      "../../schemas/zugferd_1",
      "../../schemas/zugferd_2"
    ]
    attr_accessor :doc, :version
    def initialize(io_or_str, version: 1)
      if version < 1 || version > 3
        raise ArgumentError, "Unsupported Document Version"
      end
      @doc = Nokogiri.XML(io_or_str)
      @version = version
    end

    def schema
      Nokogiri::XML.Schema File.open(File.join(__dir__, SCHEMA[schema_index]))
    end

    def schematron
      SchematronNokogiri::Schema.new(
        Nokogiri::XML(File.open(File.join(__dir__, SCHEMATRON[schema_index])))
      )
    end

    def validate_against_schema
      schema.validate(doc)
    end

    def validate_against_schematron
      result = []
      Dir.chdir File.join(__dir__, SCHEMA_DIR[schema_index]) do
        result = schematron.validate(doc)
      end
      result
    end

    private

    # Version 2 und 3 teilen sich die Factur-X-Schemas (CII-Struktur ist identisch)
    def schema_index
      (version == 1) ? 0 : 1
    end
  end
end
