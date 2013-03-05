module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module KkbEpay
      end
    end
  end
end

require File.dirname(__FILE__) + '/kkb_epay/crypt.rb'
require File.dirname(__FILE__) + '/kkb_epay/helper.rb'
require File.dirname(__FILE__) + '/kkb_epay/notification.rb'

module ActiveMerchant::Billing::Integrations::KkbEpay
  BANK_CERT_PATH = File.join(File.dirname(__FILE__), 'kkb_epay', 'kkbca.pem').freeze
  BANK_CERT = File.read(BANK_CERT_PATH).freeze

  mattr_accessor :production_url
  mattr_accessor :test_url
  self.production_url = 'https://epay.kkb.kz/jsp/process/logon.jsp'
  self.test_url = 'https://3dsecure.kkb.kz/jsp/process/logon.jsp'

  class << self
    def service_url
      mode = ActiveMerchant::Billing::Base.integration_mode
      case mode
      when :production
        production_url
      when :test
        test_url
      else
        raise StandardError, "Integration mode set to an invalid value: #{mode}"
      end
    end

    def notification(*args)
      Notification.new(*args)
    end

    def helper(*args)
      Helper.new(*args)
    end

    def crypt(params)
      Crypt.new({bank_cert: BANK_CERT}.merge params)
    end
  end
end
