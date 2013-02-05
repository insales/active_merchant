require 'test_helper'

class RbkMoneyModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of RbkMoney::Notification, RbkMoney.notification('name=cody', :originals => {})
  end

  def test_helper_method
    assert_instance_of RbkMoney::Helper, RbkMoney.helper(123, 'test')
  end  
end 
