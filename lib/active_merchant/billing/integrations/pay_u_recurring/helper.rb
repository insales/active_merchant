require 'hmac-md5'
require 'date'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PayURecurring
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          delegate :service_url, to: ActiveMerchant::Billing::Integrations::PayURecurring

          # order is significant!
          mapping :account,         'MERCHANT'
          mapping :ref_no,          'REF_NO'
          mapping :order,           'EXTERNAL_REF'
          mapping :amount,          'AMOUNT'
          mapping :currency,        'CURRENCY'
          mapping :timestamp,       'TIMESTAMP'
          mapping :method,          'METHOD'
          mapping :sign,            'SIGN'
          mapping :cancel_reason,   'CANCEL_REASON'

          attr_accessor :secret_key

          FIELDS_FOR_HASH = %w(
            MERCHANT REF_NO EXTERNAL_REF AMOUNT CURRENCY TIMESTAMP METHOD
          ).sort

          def initialize(order, account, options)
            super order, account
            options[:timestamp] ||= DateTime.now
            options[:timestamp] = options[:timestamp].strftime '%Y%m%d%H%M%S' if
              options[:timestamp].is_a? DateTime
            options.each do |k,v|
              self.send("#{k}=", v)
            end
            self.sign = order_hash
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
            str = FIELDS_FOR_HASH.map { |field|
              next unless fields.include? field
              val = fields[field].to_s
              "#{val.bytesize}#{val}"
            }.reject(&:nil?).join
            OpenSSL::HMAC.hexdigest OpenSSL::Digest::Digest.new('md5'), secret_key, str
          end
        end
      end
    end
  end
end
