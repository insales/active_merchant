require 'net/http'
require 'json'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module YandexMoneyRecurring
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def complete?
            params['']
          end

          def item_id
            params['']
          end

          def transaction_id
            params['']
          end

          # When was this payment received by the client.
          def received_at
            params.attribute('processedDT').value
          end

          def client_order_id
            params.attribute('clientOrderId').value
          end

          def payer_email
            params['']
          end

          def receiver_email
            params['']
          end

          def security_key
            params['']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['']
          end

          # Was this a test transaction?
          def test?
            params[''] == 'test'
          end

          def status
            params.attribute('status').value
          end

          def error
            params.attribute('error').value
          end

          def acknowledge
            true
          end

          def success?
            '0' == params.attribute('error').value
          end

          def message
            params.attribute('techMessage').value
          end

          private
            def parse(post)
              @raw = post
              return if post.empty?
              self.params = Nokogiri::XML(post).xpath("//repeatCardPaymentResponse")
            end
        end
      end
    end
  end
end
