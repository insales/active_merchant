require 'hmac-md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PayU
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          # order is significant!
          mapping :account,           'MERCHANT'
          mapping :order,             'ORDER_REF'
          mapping :order_date,        'ORDER_DATE'
          mapping :order_pname,       'ORDER_PNAME[]'
          mapping :order_pcode,       'ORDER_PCODE[]'
          mapping :order_pinfo,       'ORDER_PINFO[]'
          mapping :amount,            'ORDER_PRICE[]'
          mapping :order_qty,         'ORDER_QTY[]'
          mapping :order_vat,         'ORDER_VAT[]'
          mapping :order_shipping,    'ORDER_SHIPPING'
          mapping :currency,          'PRICES_CURRENCY'
          mapping :order_discount,    'DISCOUNT'
          mapping :pay_method,        'PAY_METHOD'
          mapping :order_price_type,  'ORDER_PRICE_TYPE[]'

          mapping :bill_fname,        'BILL_FNAME'
          mapping :bill_lname,        'BILL_LNAME'
          mapping :bill_email,        'BILL_EMAIL'
          mapping :bill_phone,        'BILL_PHONE'
          mapping :bill_countrycode,  'BILL_COUNTRYCODE'
          mapping :bill_address,      'BILL_ADDRESS'
          mapping :bill_zipcode,      'BILL_ZIPCODE'
          mapping :bill_city,         'BILL_CITY'
          mapping :bill_state,        'BILL_STATE'

          mapping :language,          'LANGUAGE'
          mapping :testorder,         'TESTORDER'
          mapping :debug,             'DEBUG'
          mapping :back_ref,          'BACK_REF'
          mapping :recurring,         'LU_ENABLE_TOKEN'
          mapping :token_type,        'LU_TOKEN_TYPE'

          mapping :order_hash,        'ORDER_HASH'

          attr_accessor :secret_key

          FIELDS_FOR_HASH = %w(
            MERCHANT ORDER_REF ORDER_DATE ORDER_PNAME[] ORDER_PCODE[] ORDER_PINFO[]
            ORDER_PRICE[] ORDER_QTY[] ORDER_VAT[] ORDER_SHIPPING PRICES_CURRENCY
            DISCOUNT PAY_METHOD ORDER_PRICE_TYPE[]
          )

          def initialize(account, order, options)
            super(account, order)
            options.each do |k,v|
              self.send("#{k}=", v)
            end
            self.order_hash = order_hash

            self
          end

          # seems like it should be in specific order
          def form_fields
            values = super
            result = {}
            mappings.values.each { |field|
              result[field] = values[field] if values[field]
            }
            result
          end

          def order_hash
            values = []
            fields = form_fields
            FIELDS_FOR_HASH.each { |field|
              next unless fields.include? field
              val = fields[field]
              val = [val] unless val.is_a? Array
              next if field == 'PAY_METHOD' && val[0].blank?
              values += val.flatten.map &:to_s
            }
            str = values.map { |val| "#{val.bytesize}#{val}" }.join
            OpenSSL::HMAC.hexdigest OpenSSL::Digest::Digest.new('md5'), secret_key, str
          end
        end
      end
    end
  end
end
