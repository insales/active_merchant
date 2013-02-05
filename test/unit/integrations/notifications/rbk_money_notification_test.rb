require 'test_helper'

class RbkMoneyNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @rbk_money = RbkMoney::Notification.new(http_raw_data, :originals => {:account => '12', :order => '1234', :description => 'Kniga', :gross => '12.30', :currency => 'RUR', :secret => 'myKey'})
  end

  def test_accessors
    assert @rbk_money.complete?
    assert_equal "5", @rbk_money.status
    assert_equal "2007022292", @rbk_money.transaction_id
    assert_equal "12.30", @rbk_money.gross
    assert_equal "RUR", @rbk_money.currency
    assert_equal "2013-01-01 13:12:03", @rbk_money.received_at
    assert !@rbk_money.test?
  end

  def test_amount
    assert_equal BigDecimal, @rbk_money.amount.class
    assert_equal 12.3, @rbk_money.amount.to_f
  end

  def test_hash_string
    assert_equal '12::1234::Kniga::RU123456789::12.30::RUR::5::PetrovA::admin@rbkmoney.ru::2013-01-01 13:12:03::myKey', @rbk_money.send(:generate_hash_string)
  end

  def test_generate_hash
    assert_equal 'a745e35f694fb9bc7879a551ce0fb3b3', @rbk_money.send(:generate_hash)
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    
    assert @rbk_money.acknowledge
  end

  def test_respond_to_acknowledge
    assert @rbk_money.respond_to?(:acknowledge)
  end

  private
    def http_raw_data
      "eshopId=12&paymentId=2007022292&orderId=1234&eshopAccount=RU123456789&serviceName=Kniga&recipientAmount=12.30&recipientCurrency=RUR&paymentStatus=5&userName=PetrovA&userEmail=admin@rbkmoney.ru&paymentData=2013-01-01 13:12:03&secretKey=myKey&hash=a745e35f694fb9bc7879a551ce0fb3b3"
    end
end
