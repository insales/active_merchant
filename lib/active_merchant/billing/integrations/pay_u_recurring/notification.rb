require 'net/http'
require 'json'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PayURecurring
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
            params['']
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
            params['']
          end

          def acknowledge
            true
          end

          def success?
            '0' == params['code']
          end

          def message
            params['message']
          end

          private
            def parse(post)
              @raw = post
              return if post.empty?
              self.params = JSON.parse post
            end
        end
      end
    end
  end
end
