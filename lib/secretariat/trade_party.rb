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

module Secretariat
  TradeParty = Struct.new("TradeParty",
    :name, :street1, :street2, :city, :postal_code, :country_id, :vat_id, :contact_name, :contact_phone, :contact_fax, :contact_email,
    :tax_id, :registration_number, :trade_party_id,
    keyword_init: true) do
    def to_xml(xml, exclude_tax: false, version: 2)
      if trade_party_id.to_s != ""
        xml["ram"].ID trade_party_id
      end
      xml["ram"].Name name
      if registration_number.to_s != ""
        xml["ram"].SpecifiedLegalOrganization do
          xml["ram"].ID registration_number
        end
      end
      if contact_name.to_s != ""
        xml["ram"].DefinedTradeContact do
          xml["ram"].PersonName contact_name
          if contact_phone.to_s != ""
            xml["ram"].TelephoneUniversalCommunication do
              xml["ram"].CompleteNumber contact_phone
            end
          end
          if contact_fax.to_s != ""
            xml["ram"].FaxUniversalCommunication do
              xml["ram"].CompleteNumber contact_fax
            end
          end
          if contact_email.to_s != ""
            xml["ram"].EmailURIUniversalCommunication do
              xml["ram"].URIID(contact_email, schemeID: "EM")
            end
          end
        end
      end
      xml["ram"].PostalTradeAddress do
        xml["ram"].PostcodeCode postal_code
        xml["ram"].LineOne street1
        if street2 && street2 != ""
          xml["ram"].LineTwo street2
        end
        xml["ram"].CityName city
        xml["ram"].CountryID country_id
      end
      if version == 3 && contact_email.to_s != ""
        xml["ram"].URIUniversalCommunication do
          xml["ram"].URIID(schemeID: "EM") do
            xml.text(contact_email)
          end
        end
      end
      # UST-ID
      if !exclude_tax && vat_id.to_s != ""
        xml["ram"].SpecifiedTaxRegistration do
          xml["ram"].ID(schemeID: "VA") do
            xml.text(vat_id)
          end
        end
      end
      # Steuernummer
      if tax_id.to_s != ""
        xml["ram"].SpecifiedTaxRegistration do
          xml["ram"].ID(schemeID: "FC") do
            xml.text(tax_id)
          end
        end
      end
    end
  end
end
