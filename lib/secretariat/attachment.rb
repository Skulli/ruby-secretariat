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
#
module Secretariat
  # Rechnungsbegründende Unterlage (BG-24), eingebettet als AdditionalReferencedDocument.
  # content sind die Rohdaten der Datei; der MIME-Typ ergibt sich aus der Dateiendung.
  Attachment = Struct.new("Attachment",
    :filename,
    :content,
    :description,
    keyword_init: true) do
    def errors
      @errors
    end

    def mime_code
      ATTACHMENT_MIME_TYPES[File.extname(filename.to_s).delete_prefix(".").downcase]
    end

    def valid?
      @errors = []
      @errors << "filename is missing" if filename.to_s == ""
      @errors << "content is missing" if content.to_s == ""
      if filename.to_s != "" && mime_code.nil?
        @errors << "file type of #{filename} is not allowed, allowed: #{ATTACHMENT_MIME_TYPES.keys.join(", ")}"
      end
      @errors.empty?
    end

    # Validierung über Invoice#valid?, das auch doppelte Dateinamen erkennt
    def to_xml(xml)
      xml["ram"].AdditionalReferencedDocument do
        xml["ram"].IssuerAssignedID filename
        xml["ram"].TypeCode "916" # Rechnungsbegründende Unterlage
        xml["ram"].Name description if description.to_s != ""
        xml["ram"].AttachmentBinaryObject([content].pack("m0"), mimeCode: mime_code, filename: filename)
      end
    end
  end
end
