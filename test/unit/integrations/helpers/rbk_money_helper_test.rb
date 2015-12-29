# encoding: utf-8
require 'test_helper'

class RbkMoneyHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @options = {
      amount:             500,
      currency:           'USD',
      cancel_return_url:  'url',
      return_url:         'url2',
      description:        'desc',
      email:              'email',
      order_lines: [
        {
          Name:         'name1',
          Description:  'desc1',
          TotalPrice:   1.0,
          Count:        11.0,
        },
        {
          Name:         'name2',
          Description:  'desc2',
          TotalPrice:   2.0,
          Count:        22.0,
        },
      ],
    }
    @helper = RbkMoney::Helper.new('order-500','cody@example.com', @options)

    @sign_options = {
      amount: '12.30',
      currency: 'RUR',
      email: 'admin@rbkmoney.ru',
      description: 'Книга',
      secret_key: 'myKey'
    }

    @sign_helper = RbkMoney::Helper.new('1234', '12', @sign_options)
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

  def test_order_lines_form_fields
      (0..1).each do |i|
        [:Name, :Description, :TotalPrice, :Count].each do |field|
          assert_equal @options[:order_lines][i][field], @helper.form_fields["PurchaseItem_#{i}_#{field}"]
        end
    end
  end

  def test_signature
    actual = @sign_helper.form_fields['hash']
    assert_equal 'a379869123fd5157a8d14fd95e9e0186', actual
  end
end
