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

          def initialize(account, order, options)
            @description = options.delete(:description)
            @cancel_return_url = options.delete(:cancel_return_url)
            @return_url = options.delete(:return_url)
            super
            self.description = @description
            self.cancel_return_url = @cancel_return_url
            self.return_url = @return_url
            self
          end
        end
      end
    end
  end
end
