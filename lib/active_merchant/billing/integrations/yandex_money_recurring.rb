require File.dirname(__FILE__) + '/yandex_money_recurring/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module YandexMoneyRecurring
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
