require 'money'

class ActiveMerchant::Billing::Integrations::KkbEpay::Helper <
  ActiveMerchant::Billing::Integrations::Helper

  mapping :shop_id, 'ShopID'
  mapping :email, 'email'
  mapping :notify_url, 'PostLink'
  mapping :return_url, 'BackLink'
  mapping :cancel_return_url, 'FailureBackLink'
  mapping :language, 'Language'

  attr_accessor :order, :currency, :amount

  def initialize(order, account, options, crypt_params)
    super order, account
    @crypt_params = crypt_params
    @crypt = ActiveMerchant::Billing::Integrations::KkbEpay::crypt crypt_params
    %w(amount email currency notify_url return_url cancel_return_url language shop_id).each do |k|
      self.send "#{k}=", options[k.to_sym]
    end
    self
  end

  def form_fields
    @fields.merge(
      'Signed_Order_B64' => signed_order_b64(order)
    )
  end

  private
    def signed_order_b64(order)
      @crypt.signed_xml_b64(
        order_id:       ('%06d' % order),
        amount:         amount,
        currency:       ::Money::Currency.new(currency).iso_numeric
      )
    end
end
