require 'active_support/core_ext/hash/conversions'

class ActiveMerchant::Billing::Integrations::QiwiKz::Notification <
  ActiveMerchant::Billing::Integrations::Notification

  def complete?
    'pay' == status
  end

  def item_id
    params['account']
  end

  def transaction_id
    params['txn_id']
  end

  # When was this payment received by the client.
  def received_at
    DateTime.parse params['txn_date'] if params['txn_date']
  end

  # the money amount we received in X.2 decimal.
  def gross
    params['sum'].to_f
  end

  def currency
    'KZT'
  end

  def amount
    Money.new gross, currency
  end

  def status
    params['command']
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
      self.params = post
    end
end
