module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PayU
        class Notification < ActiveMerchant::Billing::Integrations::Notification

          attr_reader :secret_key, :post_data

          def initialize(data, options = {})
            super(data)
            @secret_key = options.delete :secret_key
            @post_data = options.delete :post_data
            @params = data
            self
          end

          def self.recognizes?(params)
            params.has_key?('IPN_PID') && params.has_key?('IPN_NAME') &&
              params.hash_key?('IPN_DATE') && params.has_key?('HASH') &&
              params.has_key?('ORDERSTATUS')
          end

          def complete?
            params['ORDERSTATUS'] == 'PAYMENT_AUTHORIZED' || params['ORDERSTATUS'] == 'TEST' || params['ORDERSTATUS'] == 'COMPLETE'
          end

          def hash
            params['HASH']
          end

          def amount
            params['IPN_PRICE'][0]
          end

          def currency
            params['CURRENCY']
          end

          def test?; false; end

          def success?
            acknowledge && complete?
          end

          def refund?
            acknowledge && params['ORDERSTATUS'] == 'REFUND'
          end

          def acknowledge
            hash_valid?
          end

          def response
            if success? || refund?
              response_ok
            else
              response_error
            end
          end

          def response_ok
            "<EPAYMENT>#{response_date}|#{response_hash}</EPAYMENT>"
          end

          def response_error
            "Error occured"
          end

          def recurring?
            params.key? 'IPN_CC_TOKEN'
          end

          private
            def response_date
              @response_date ||= Time.now.strftime "%Y%m%d%H%M%S"
            end

            def response_hash
              ipn_pid = params['IPN_PID'][0]
              ipn_pname = params['IPN_PNAME'][0]
              ipn_date = params['IPN_DATE']

              @response_hash ||= generate_hash(ipn_pid, ipn_pname, ipn_date, response_date)
            end

            def request_hash
              return @request_hash if @request_hash
              values = []
              post_data.split('&').each do |param|
                k, v = param.split('=')
                next if k == 'HASH'
                values << CGI.unescape(v.to_s)
              end

              @request_hash ||= generate_hash(*values)
            end

            def hash_valid?
              return true if hash == request_hash
              Rails.logger.error("[PAYU] wrong hash #{hash} != #{request_hash}, POST_DATA #{post_data.inspect}")
              false
            end

            def generate_hash(*args)
              raise "Cannot generate hash. SecretKey is not defined" if secret_key.blank?
              str = ""
              args.each do |val|
                str << "#{val.bytesize}#{val}"
              end

              OpenSSL::HMAC.hexdigest OpenSSL::Digest.new('md5'), secret_key, str
            end

            def parse(post)
              if post.is_a?(Hash)
                return
              end

              super(post)
            end
        end
      end
    end
  end
end
