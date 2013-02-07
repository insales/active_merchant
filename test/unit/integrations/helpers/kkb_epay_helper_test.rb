require 'test_helper'

class KkbEpayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
  private_key = <<-PEM
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,25E4520A4E5EE17A

r1Uz/b1FZpMJg0kh2efZoaXpLnEg9xR8rkU8nH5y5LTP7q15zldAWm0BqGax6ZHm
5xe/zTjFcZKYjh7NeINlTKrAnbNNYZnYxqqj9GGUa1gEpvHn8TukXB83cEbvsDeS
jrbvbj5itRqqa9fNNs4rzizVdaGFpQKVhCqx4u7lE8oWdR1WCUHOywpFpkpHznDr
od/B2JSzG6OekuwCB4tnyZmJ1RYncbsM7NysOGcUZcT9ZmfzteYkVjPxZKcHzjTr
pLzhlYeAr0by9jNhtodGaYoRHEs2cqK8zEPBRMmgDydVA9Fg2NIIDaBB7ugdjaUw
XuWUo1y5JrU0hRnB7FdAEizO1g5CNG5aZ5UDcg9jbNeKEqrZy2VcBKARYxVDUIlm
INB98tXargbAgbCRwKvn76m8R0ClBMlIHiMzP3LCTfQaJnCIIDirfA==
-----END RSA PRIVATE KEY-----
  PEM

    params  = {
      shop_id: 'shop_id',
      amount:   500,
      currency: 'USD',
      email: 'customer@email.com',
      notify_url: 'notify_url',
      return_url: 'return_url',
      cancel_return_url: 'cancel_return_url'
    }
    crypt_params = {
      private_key: private_key,
      private_key_password: 'nissan',
      cert_id:  '00C182B189',
      merchant_id: '92061101',
      merchant_name: 'test merchant'
    }
    @helper = KkbEpay::Helper.new('567', 'cody@example.com', params, crypt_params)
  end

  def test_form_fields
    assert_equal [
      "BackLink",
      "FailureBackLink",
      "PostLink",
      "ShopID",
      "Signed_Order_B64",
      "email"
     ], @helper.form_fields.keys.sort
  end
end
