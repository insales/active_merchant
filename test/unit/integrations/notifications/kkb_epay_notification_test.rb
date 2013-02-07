require 'test_helper'

class KkbEpayNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @kkb_epay = KkbEpay::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @kkb_epay.complete?
    assert_equal "130206172902", @kkb_epay.transaction_id
    assert_equal "001321", @kkb_epay.item_id
    assert_equal "104.0", @kkb_epay.gross
    #assert_equal "KZT", @kkb_epay.currency
    assert_equal "2013-02-06 17:29:03", @kkb_epay.received_at
  end

  def test_compositions
    #assert_equal Money.new(104, 'KZT'), @kkb_epay.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @kkb_epay.respond_to?(:acknowledge)
  end

  private
    def http_raw_data
      {
        response: '<document><bank name="Kazkommertsbank JSC"><customer name="asd sdf" mail="maxim.melentiev@insales.ru" phone=""><merchant cert_id="00C182B189" name="abc"><order order_id="001321" amount="104.0" currency="398"><department merchant_id="92061101" amount="104.0"/></order></merchant><merchant_sign type="RSA"/></customer><customer_sign type="RSA"/><results timestamp="2013-02-06 17:29:03"><payment merchant_id="92061101" card="440564-XX-XXXX-6150" amount="104.0" reference="130206172902" approval_code="172902" response_code="00" Secure="Yes" card_bin="KAZ"/></results></bank><bank_sign cert_id="00C18327E8" type="SHA/RSA">UQv9RX2OncKzPKnZgBT6n+pAnYCWfmAKMJPoFiOGugcFPq5ZTIFmWlxxYqzz707DOTAum7hvIvCooVuLWgScs4YdQOD172V+nLW2FsDba+lEVN 0u7nD2+qsriol7GXkn+INLhzRI+7beapT7xmHoP8hcrPE53UfA5XUgCa15iWw=</bank_sign></document> '
      }
    end
end
