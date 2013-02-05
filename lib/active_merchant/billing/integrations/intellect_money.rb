require File.dirname(__FILE__) + '/intellect_money/helper.rb'
require File.dirname(__FILE__) + '/intellect_money/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module IntellectMoney 
        mattr_accessor :service_url, :service_url_test
        self.service_url = 'https://merchant.intellectmoney.ru/ru/'
        self.service_url_test = 'https://merchant.intellectmoney.ru/ru/'

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
