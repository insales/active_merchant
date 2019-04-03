require 'cgi'
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module RbkMoney
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          # original merchent data: eshopId, orderId, serviceName, recipientAmount, recipientCurrency, secretKey.
          attr_reader :originals

          def initialize(data, options = {})
            super
            @originals = @options.delete(:originals)
          end

          def self.recognizes?(params)
            params.has_key?('eshopId') && params.has_key?('paymentStatus') &&
              params.hash_key?('recipientAmount') && params.has_key?('hash')
          end

          def complete?
            !in_process?
          end

          def success?
            params['paymentStatus'] == "5"
          end

          def in_process?
            params['paymentStatus'] == "3"
          end

          def order
            params['orderId']
          end

          # site id
          def account
            params['eshopId']
          end

          # purse id
          def account_purse
            params['eshopAccount']
          end

          def transaction_id
            params['paymentId']
          end

          def received_at
            params['paymentData']
          end

          def payer_name
            params['userName']
          end

          def payer_email
            params['userEmail']
          end

          def hash
            params['hash']
          end

          def secret_key
            params['secretKey']
          end

          def amount
            gross.to_d
          end

          def gross
            params['recipientAmount']
          end

          def currency
            params['recipientCurrency']
          end

          def description
            params['serviceName']
          end

          def test?
            false
          end

          def status
            params['paymentStatus']
          end

          def acknowledge
            hash_unchanged? && amount_unchanged? && currency_unchanged? && account_unchanged?
          end

          private
            def hash_unchanged?
              hash == generate_hash
            end

            def amount_unchanged?
              amount.to_f == originals[:gross].to_f
            end

            def currency_unchanged?
              currency == originals[:currency]
            end

            def account_unchanged?
              account == originals[:account]
            end

            def generate_hash
              Digest::MD5.hexdigest(generate_hash_string)
            end

            def generate_hash_string
              hash_string_attributes.join('::')
            end

            def hash_string_attributes
              [ originals[:account], originals[:order], description, account_purse, originals[:gross],
                originals[:currency], status, payer_name, payer_email, received_at, originals[:secret] ]
            end

            def parse(post)
              @raw = post
              for line in post.split('&')
                key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
                params[key] = CGI.unescape(value)
              end
            end
        end
      end
    end
  end
end
