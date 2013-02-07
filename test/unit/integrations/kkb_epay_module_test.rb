require 'test_helper'

class KkbEpayModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_notification_method
    assert KkbEpay.respond_to? :notification
    assert KkbEpay.respond_to? :helper
  end
end
