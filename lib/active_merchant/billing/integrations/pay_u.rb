require File.dirname(__FILE__) + '/pay_u/helper.rb'
require File.dirname(__FILE__) + '/pay_u/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PayU

        mattr_accessor :service_url
        self.service_url = 'https://secure.payu.ru/order/lu.php'

        def self.notification(data, options)
          Notification.new(data, options)
        end

        def self.helper(order, account, options = {})
          Helper.new(order, account, options)
        end
      end
    end
  end
end
