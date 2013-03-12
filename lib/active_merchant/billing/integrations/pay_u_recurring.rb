require File.dirname(__FILE__) + '/pay_u_recurring/helper.rb'
require File.dirname(__FILE__) + '/pay_u_recurring/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PayURecurring
        mattr_accessor :service_url
        self.service_url = 'https://secure.payu.ru/order/tokens/'

        class << self
          def notification(data, options)
            Notification.new(data, options)
          end

          def helper(order, account, options = {})
            Helper.new(order, account, options)
          end
        end
      end
    end
  end
end
