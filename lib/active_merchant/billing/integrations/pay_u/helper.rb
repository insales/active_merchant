require 'hmac-md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PayU
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          mapping :account, 'MERCHANT'
          mapping :order, 'ORDER_REF'
          mapping :order_date, 'ORDER_DATE'
          mapping :order_pname, 'ORDER_PNAME[]'
          mapping :order_pcode, 'ORDER_PCODE[]'
          mapping :order_pinfo, 'ORDER_PINFO[]'
          mapping :amount, 'ORDER_PRICE[]'
          mapping :order_price_type, 'ORDER_PRICE_TYPE[]'
          mapping :order_qty, 'ORDER_QTY[]'
          mapping :order_vat, 'ORDER_VAT[]'
          mapping :order_shipping, 'ORDER_SHIPPING'
          mapping :currency, 'PRICES_CURRENCY'
          mapping :pay_method, 'PAY_METHOD'
          mapping :order_hash, 'ORDER_HASH'
          mapping :testorder, 'TESTORDER'
          mapping :debug, 'DEBUG'
          mapping :back_ref, 'BACK_REF'

          mapping :bill_fname, 'BILL_FNAME'
          mapping :bill_lname, 'BILL_LNAME'
          mapping :bill_email, 'BILL_EMAIL'
          mapping :bill_phone, 'BILL_PHONE'
          mapping :bill_countrycode, 'BILL_COUNTRYCODE'

          mapping :bill_address, 'BILL_ADDRESS'
          mapping :bill_zipcode, 'BILL_ZIPCODE'
          mapping :bill_city, 'BILL_CITY'
          mapping :bill_state, 'BILL_STATE'

          mapping :language, 'LANGUAGE'
          mapping :order_discount, 'DISCOUNT'


          attr_accessor :secret_key

          def initialize(account, order, options)
            super(account, order)
            options.each do |k,v|
              self.send("#{k}=", v)
            end
            self.order_hash = order_hash

            self
          end

          def order_hash
            str = ""
            attrs = %w(
              MERCHANT ORDER_REF ORDER_DATE ORDER_PNAME[] ORDER_PCODE[] ORDER_PINFO[] ORDER_PRICE[]
              ORDER_QTY[] ORDER_VAT[] ORDER_SHIPPING PRICES_CURRENCY DISCOUNT PAY_METHOD ORDER_PRICE_TYPE[]
              )
            values = []
            attrs.each do |attr|
              ary = self.fields.to_a.find_all { |a| a[0] == attr }.map { |e| e[1] }
              next if attr == 'PAY_METHOD' && ary[0].blank?
              values += ary.flatten
            end

            values.each {|value| str << "#{value.to_s.bytesize}#{value}"}

            hmac = HMAC::MD5.new(secret_key)
            hmac.update(str)
            hmac.to_s
          end
        end
      end
    end
  end
end
