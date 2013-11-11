require 'test_helper'

class RbkMoneyHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = RbkMoney::Helper.new('order-500','cody@example.com',
      amount:             500,
      currency:           'USD',
      cancel_return_url:  'url',
      return_url:         'url2',
      description:        'desc',
      email:              'email'
    )
  end

  def test_form_fields
    [
      :orderId,
      :eshopId,
      :recipientAmount,
      :recipientCurrency,
      :successUrl,
      :failUrl,
      :serviceName,
      :user_email,
    ].each do |key|
      assert @helper.form_fields.keys.include?(key.to_s)
    end
  end
end
