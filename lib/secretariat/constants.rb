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
  BASIS_QUANTITY = 1.0

  # Für Anhänge (BG-24) zulässige MIME-Typen nach EN16931-Codeliste (BR-CL-24), je Dateiendung
  ATTACHMENT_MIME_TYPES = {
    "pdf" => "application/pdf",
    "png" => "image/png",
    "jpg" => "image/jpeg",
    "jpeg" => "image/jpeg",
    "csv" => "text/csv",
    "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "ods" => "application/vnd.oasis.opendocument.spreadsheet"
  }

  TAX_CATEGORY_CODES = {
    STANDARDRATE: "S",
    REVERSECHARGE: "AE",
    TAXEXEMPT: "E",
    ZEROTAXPRODUCTS: "Z",
    UNTAXEDSERVICE: "O",
    INTRACOMMUNITY: "K",
    EXPORT: "G"
  }

  TAX_CATEGORY_CODES_1 = {
    STANDARDRATE: "S",
    REVERSECHARGE: "AE",
    TAXEXEMPT: "E",
    ZEROTAXPRODUCTS: "Z",
    UNTAXEDSERVICE: "O",
    INTRACOMMUNITY: "IC",
    EXPORT: "E"
  }

  PAYMENT_CODES = {
    BANKACCOUNT: "42",
    NOTSPECIFIED: "1",
    AUTOMATICCLEARING: "3",
    CASH: "10",
    CHECK: "20",
    DEBITADVICE: "31",
    CREDITCARD: "48",
    DEBIT: "49",
    SEPA_CREDIT: "58",
    SEPA_DEBIT: "59",
    COMPENSATION: "97"
  }

  TAX_EXEMPTION_REASONS = {
    REVERSECHARGE: "Reverse Charge",
    INTRACOMMUNITY: "Intra-community transaction",
    EXPORT: "Export outside the EU"
  }

  UNIT_CODES = {
    ONE: "C62",
    PIECE: "H87",
    DAY: "DAY",
    HECTARE: "HAR",
    HOUR: "HUR",
    MONTH: "MON",
    KILOGRAM: "KGM",
    KILOMETER: "KMT",
    KILOWATTHOUR: "KWH",
    FIXEDRATE: "LS",
    LITRE: "LTR",
    MINUTE: "MIN",
    SQUAREMILLIMETER: "MMK",
    MILLIMETER: "MMT",
    SQUAREMETER: "MTK",
    CUBICMETER: "MTQ",
    METER: "MTR",
    PRODUCTCOUNT: "NAR",
    PRODUCTPAIR: "NPR",
    PERCENT: "P1",
    SET: "SET",
    TON: "TNE",
    WEEK: "WEE",
    BOTTLE: "BO",
    CARTON: "CT",
    CAN: "CA"
  }

  INVOICE_TYPES = {
    INVOICE: {
      code: "380",
      name: "Rechnung"
    },
    CREDIT_NOTE: {
      code: "381",
      name: "Gutschrift"
    },
    CORRECTION: {
      code: "384",
      name: "Korrekturrechnung"
    },
    PART_INVOICE: {
      code: "326",
      name: "Teilrechnung"
    },
    REVERSED_INVOICE: {
      code: "457",
      name: "Stornorechnung"
    }
  }
end
