module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module RbkMoney
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          mapping :account, 'eshopId'
          mapping :amount, 'recipientAmount'
          mapping :currency, 'recipientCurrency'
          mapping :order, 'orderId'
          mapping :return_url, 'successUrl'
          mapping :cancel_return_url, 'failUrl'
          mapping :description, 'serviceName'
          mapping :email, 'user_email'

          CUSTOM_OPTIONS = Set.new [
            :description,
            :cancel_return_url,
            :return_url,
            :email,
          ]

          def initialize(order, account, options)
            fields = options.extract!(*CUSTOM_OPTIONS)
            super.tap { fields.each { |field, value| send "#{field}=", value } }
          end
        end
      end
    end
  end
end
