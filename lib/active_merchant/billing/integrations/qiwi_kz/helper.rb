class ActiveMerchant::Billing::Integrations::QiwiKz::Helper <
  ActiveMerchant::Billing::Integrations::Helper

  attr_accessor :order, :currency, :amount

  def initialize(order, account, options)
    super order, account
    %w(amount currency).each do |k|
      self.send "#{k}=", options[k.to_sym]
    end
    self
  end
end
