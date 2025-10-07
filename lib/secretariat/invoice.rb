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

require "bigdecimal"

module Secretariat
  Invoice = Struct.new("Invoice",
    :id,
    :issue_date,
    :seller,
    :buyer,
    :recipient,
    :line_items,
    :currency_code,
    :payment_type,
    :payment_text,
    :payment_iban,
    :payment_bic,
    :payment_account_name,
    :tax_category,
    :tax_percent,
    :tax_amount,
    :tax_reason,
    :basis_amount,
    :grand_total_amount,
    :due_amount,
    :paid_amount,
    :buyer_reference,
    :payment_description,
    :payment_status,
    :payment_due_date,
    :header_text,
    :footer_text,
    :project_id,
    :project_name,
    :invoice_start,
    :invoice_end,
    :invoice_type,
    keyword_init: true) do
    include Versioner

    def errors
      @errors
    end

    def tax_reason_text
      tax_reason || TAX_EXEMPTION_REASONS[tax_category]
    end

    def tax_category_code(version: 2)
      if version == 1
        return TAX_CATEGORY_CODES_1[tax_category] || "S"
      end
      TAX_CATEGORY_CODES[tax_category] || "S"
    end

    def payment_code
      PAYMENT_CODES[payment_type] || "1"
    end

    def valid?
      @errors = []
      tax = BigDecimal(tax_amount)
      basis = BigDecimal(basis_amount)
      calc_tax = basis * BigDecimal(tax_percent) / BigDecimal(100)
      calc_tax = calc_tax.round(2)
      if tax != calc_tax
        @errors << "Tax amount and calculated tax amount deviate: #{tax} / #{calc_tax}"
        return false
      end
      grand_total = BigDecimal(grand_total_amount)
      calc_grand_total = basis + tax
      if grand_total != calc_grand_total
        @errors << "Grand total amount and calculated grand total amount deviate: #{grand_total} / #{calc_grand_total}"
        return false
      end
      line_item_sum = line_items.inject(BigDecimal(0)) do |m, item|
        m + BigDecimal(item.charge_amount)
      end
      if line_item_sum != basis
        @errors << "Line items do not add up to basis amount #{line_item_sum} / #{basis}"
        return false
      end
      true
    end

    def namespaces(version: 1)
      by_version(version,
        {
          "xmlns:ram" => "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:12",
          "xmlns:udt" => "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:15",
          "xmlns:rsm" => "urn:ferd:CrossIndustryDocument:invoice:1p0",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:xs" => "http://www.w3.org/2001/XMLSchema"
        },
        {
          "xmlns:qdt" => "urn:un:unece:uncefact:data:standard:QualifiedDataType:100",
          "xmlns:ram" => "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100",
          "xmlns:udt" => "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100",
          "xmlns:rsm" => "urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:xs" => "http://www.w3.org/2001/XMLSchema"
        })
    end

    def to_xml(version: 1, skip_validation: false, mode: :zugferd)
      if version < 1 || version > 3
        raise "Unsupported Document Version"
      end
      if mode != :zugferd && mode != :xrechnung
        raise "Unsupported Document Mode"
      end
      if mode == :xrechnung && version < 2
        raise "Mode XRechnung requires Document Version > 1"
      end

      if !skip_validation && !valid?
        puts errors.inspect
        raise ValidationError.new("Invoice is invalid", errors)
      end

      builder = Nokogiri::XML::Builder.new do |xml|
        root = by_version(version, "CrossIndustryDocument", "CrossIndustryInvoice")

        xml["rsm"].send(root, namespaces(version: version)) do
          context = by_version(version, "SpecifiedExchangedDocumentContext", "ExchangedDocumentContext")

          xml["rsm"].send(context) do
            if (version == 3 && mode == :xrechnung) || (version >= 2 && mode == :zugferd)
              xml["ram"].BusinessProcessSpecifiedDocumentContextParameter do
                xml["ram"].ID "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
              end
            end
            xml["ram"].GuidelineSpecifiedDocumentContextParameter do
              version_id = by_version(version, "urn:ferd:CrossIndustryDocument:invoice:1p0:comfort", "urn:cen.eu:en16931:2017")
              if mode == :xrechnung
                version_id += "#compliant#urn:xoev-de:kosit:standard:xrechnung_2.3" if version == 2
                version_id += "#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0" if version == 3
              end
              xml["ram"].ID version_id
            end
          end

          header = by_version(version, "HeaderExchangedDocument", "ExchangedDocument")

          xml["rsm"].send(header) do
            xml["ram"].ID id
            if !invoice_type.nil?
              if version == 1
                xml["ram"].Name INVOICE_TYPES[invoice_type][:name]
              end
              xml["ram"].TypeCode INVOICE_TYPES[invoice_type][:code]
            else
              if version == 1
                xml["ram"].Name "RECHNUNG"
              end
              xml["ram"].TypeCode "380"
            end
            xml["ram"].IssueDateTime do
              xml["udt"].DateTimeString(format: "102") do
                xml.text(issue_date.strftime("%Y%m%d"))
              end
            end

            if header_text.to_s != ""
              xml["ram"].IncludedNote {
                xml["ram"].Content header_text
                xml["ram"].SubjectCode "SUR" # Comments by the seller
              }
            end
            if footer_text.to_s != ""
              xml["ram"].IncludedNote {
                xml["ram"].Content footer_text
                xml["ram"].SubjectCode "SUR" # Comments by the seller
              }
            end
          end
          transaction = by_version(version, "SpecifiedSupplyChainTradeTransaction", "SupplyChainTradeTransaction")
          xml["rsm"].send(transaction) do
            if version >= 2
              line_items.each_with_index do |item, i|
                item.to_xml(xml, i + 1, version: version, skip_validation: skip_validation) # one indexed
              end
            end

            trade_agreement = by_version(version, "ApplicableSupplyChainTradeAgreement", "ApplicableHeaderTradeAgreement")

            xml["ram"].send(trade_agreement) do
              if version >= 2 && !buyer_reference.nil?
                xml["ram"].BuyerReference do
                  xml.text(buyer_reference)
                end
              end
              xml["ram"].SellerTradeParty do
                seller.to_xml(xml, version: version)
              end
              xml["ram"].BuyerTradeParty do
                buyer.to_xml(xml, version: version)
              end

              if project_id.to_s != "" || project_name.to_s != ""
                xml["ram"].SpecifiedProcuringProject do
                  if project_id.to_s != ""
                    xml["ram"].ID project_id.to_s
                  end
                  if project_name.to_s != ""
                    xml["ram"].Name project_name.to_s
                  end
                end
              end
            end

            delivery = by_version(version, "ApplicableSupplyChainTradeDelivery", "ApplicableHeaderTradeDelivery")

            xml["ram"].send(delivery) do
              if version >= 2
                xml["ram"].ShipToTradeParty do
                  if !recipient.nil?
                    recipient.to_xml(xml, exclude_tax: true, version: version)
                  else
                    buyer.to_xml(xml, exclude_tax: true, version: version)
                  end
                end
              end
              xml["ram"].ActualDeliverySupplyChainEvent do
                xml["ram"].OccurrenceDateTime do
                  xml["udt"].DateTimeString(format: "102") do
                    xml.text(issue_date.strftime("%Y%m%d"))
                  end
                end
              end
            end
            trade_settlement = by_version(version, "ApplicableSupplyChainTradeSettlement", "ApplicableHeaderTradeSettlement")
            xml["ram"].send(trade_settlement) do
              xml["ram"].InvoiceCurrencyCode currency_code
              xml["ram"].SpecifiedTradeSettlementPaymentMeans do
                xml["ram"].TypeCode payment_code
                xml["ram"].Information payment_text
                if payment_iban && payment_iban != ""
                  xml["ram"].PayeePartyCreditorFinancialAccount do
                    xml["ram"].IBANID payment_iban
                    if payment_account_name.to_s != ""
                      xml["ram"].payment_account_name
                    end
                  end
                  if payment_bic.to_s != ""
                    xml["ram"].PayeeSpecifiedCreditorFinancialInstitution do
                      xml["ram"].BICID payment_bic
                    end
                  end
                end
              end
              xml["ram"].ApplicableTradeTax do
                Helpers.currency_element(xml, "ram", "CalculatedAmount", tax_amount, currency_code, add_currency: version == 1)
                xml["ram"].TypeCode "VAT"
                if tax_reason_text && tax_reason_text != ""
                  xml["ram"].ExemptionReason tax_reason_text
                end
                Helpers.currency_element(xml, "ram", "BasisAmount", basis_amount, currency_code, add_currency: version == 1)
                xml["ram"].CategoryCode tax_category_code(version: version)

                percent = by_version(version, "ApplicablePercent", "RateApplicablePercent")
                xml["ram"].send(percent, Helpers.format(tax_percent))
              end
              if invoice_start.to_s != "" && invoice_end.to_s != ""
                xml["ram"].BillingSpecifiedPeriod do
                  xml["ram"].StartDateTime do
                    xml["udt"].DateTimeString(format: "102") do
                      xml.text(invoice_start.strftime("%Y%m%d"))
                    end
                  end
                  xml["ram"].EndDateTime do
                    xml["udt"].DateTimeString(format: "102") do
                      xml.text(invoice_end.strftime("%Y%m%d"))
                    end
                  end
                end
              end
              xml["ram"].SpecifiedTradePaymentTerms do
                if payment_status == "unpaid" || (payment_status.to_s == "")
                  if payment_description.to_s != ""
                    xml["ram"].Description payment_description
                  end
                  xml["ram"].DueDateDateTime do
                    xml["udt"].DateTimeString(format: "102") do
                      xml.text(payment_due_date&.strftime("%Y%m%d"))
                    end
                  end
                elsif payment_status.to_s != ""
                  xml["ram"].Description payment_status.capitalize
                end
              end

              monetary_summation = by_version(version, "SpecifiedTradeSettlementMonetarySummation", "SpecifiedTradeSettlementHeaderMonetarySummation")

              xml["ram"].send(monetary_summation) do
                Helpers.currency_element(xml, "ram", "LineTotalAmount", basis_amount, currency_code, add_currency: version == 1)
                # TODO: Fix this!
                # Zuschuesse
                unless BigDecimal(0).to_f.zero?
                  Helpers.currency_element(xml, "ram", "ChargeTotalAmount", BigDecimal(0), currency_code, add_currency: version == 1)
                end
                # Rabatte
                unless BigDecimal(0).to_f.zero?
                  Helpers.currency_element(xml, "ram", "AllowanceTotalAmount", BigDecimal(0), currency_code, add_currency: version == 1)
                end
                Helpers.currency_element(xml, "ram", "TaxBasisTotalAmount", basis_amount, currency_code, add_currency: version == 1)
                unless tax_amount.to_f.zero?
                  Helpers.currency_element(xml, "ram", "TaxTotalAmount", tax_amount, currency_code, add_currency: true)
                end
                Helpers.currency_element(xml, "ram", "GrandTotalAmount", grand_total_amount, currency_code, add_currency: version == 1)
                unless paid_amount.to_f.zero?
                  Helpers.currency_element(xml, "ram", "TotalPrepaidAmount", paid_amount, currency_code, add_currency: version == 1)
                end
                Helpers.currency_element(xml, "ram", "DuePayableAmount", due_amount, currency_code, add_currency: version == 1)
              end
            end
            if version == 1
              line_items.each_with_index do |item, i|
                item.to_xml(xml, i + 1, version: version, skip_validation: skip_validation) # one indexed
              end
            end
          end
        end
      end
      # entferne leere Knoten
      builder.doc.traverse do |node|
        node.remove if node.element? && node.text == ""
      end
      builder.to_xml
    end
  end
end
