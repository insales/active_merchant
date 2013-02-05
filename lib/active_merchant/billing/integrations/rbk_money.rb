require File.dirname(__FILE__) + '/rbk_money/helper.rb'
require File.dirname(__FILE__) + '/rbk_money/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module RbkMoney

        # http://www.rbkmoney.ru/primery-integratsii
        # Docs: https://docs.google.com/leaf?id=0B9UL0sMPo7JJNDMzYTA5YzUtZTI5ZS00M2I1LWE2NWQtNjY3N2IyZTRkNTVl&sort=name&layout=list&pid=0B9UL0sMPo7JJOGNiYmJkZWItY2JkZi00ZjhlLWE3NDItOWRjZWRkMTFmZTk1&cindex=3

        mattr_accessor :service_url
        self.service_url = 'https://rbkmoney.ru/acceptpurchase.aspx'

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
