require 'active_support/core_ext/hash/conversions'

class ActiveMerchant::Billing::Integrations::KkbEpay::Notification <
  ActiveMerchant::Billing::Integrations::Notification

  def initialize(post, crypt_params = {})
    @crypt_params = crypt_params
    @crypt = ActiveMerchant::Billing::Integrations::KkbEpay::crypt crypt_params
    super post
    self
  end

  def complete?
    true
  end

  def item_id
    params['order_id']
  end

  def transaction_id
    params['reference']
  end

  def approval_code
    params['approval_code']
  end

  # When was this payment received by the client.
  def received_at
    params['timestamp']
  end

  def payer_email
    params['email']
  end

  def security_key
    params['secure']
  end

  # the money amount we received in X.2 decimal.
  def gross
    params['amount']
  end

  def currency
    Money::Currency::find_by_iso_numeric(params['currency_code']).iso_code
  end

  def amount
    Money.new gross, currency
  end

  # Was this a test transaction?
  def test?
    false
  end

  def acknowledge
    true
  end

  private
    # Take the posted data and move the relevant data into a hash
    def parse(post)
      xml = post[:response]
      raise "Epay: Invalid signature!" unless @crypt.check_signed_xml xml
      hash = Hash.from_xml(xml)['document']
      rc = hash['bank']['results']['payment']['response_code']
      raise "Epay: ResponseCode = #{rc}. Contact to bank!" unless '00' == rc

      params['amount'] = hash['bank']['results']['payment']['amount']
      params['email'] = hash['bank']['customer']['mail']
      params['order_id'] = hash['bank']['customer']['merchant']['order']['order_id']
      params['reference'] = hash['bank']['results']['payment']['reference']
      params['approval_code'] = hash['bank']['results']['payment']['approval_code']
      params['secure'] = hash['bank']['results']['payment']['secure']
      params['timestamp'] = hash['bank']['results']['timestamp']
      params['currency_code'] = hash['bank']['customer']['merchant']['order']['currency']
    end
end
