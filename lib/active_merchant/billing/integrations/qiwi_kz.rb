module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module QiwiKz
      end
    end
  end
end

require 'money'
require File.dirname(__FILE__) + '/qiwi_kz/helper.rb'
require File.dirname(__FILE__) + '/qiwi_kz/notification.rb'

module ActiveMerchant::Billing::Integrations::QiwiKz
  class << self
    def notification(*args)
      Notification.new(*args)
    end

    def helper(*args)
      Helper.new(*args)
    end
  end
end
