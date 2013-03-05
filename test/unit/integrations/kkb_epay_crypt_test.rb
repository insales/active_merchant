require 'test_helper'

class KkbEpayCryptTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @pk_good = <<-PEM
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,B5277503D7B49F94FBED7200C0FD25C7

nNy8Prb9hCpkAvsOTMAS88DVHzYqNF9PvSRg69+An3lLZ2kPN6h1kXpqNcNDVO9k
lqihAt9V2MMK6OPbCgGlRzIaaQ/4MnxAjTWRqPmDs8TpYWqW4GLXShVOqNkthXxU
2s9dXo0mTIHrjtz8IemKsRbxquTdzh1nLQ3T94rNlEDdBCXAlZZqzcSB48FmzR+Z
owt7+l506K5GmwfcV14ta+6bElM7rX80yi0ONnEHgtU8dXr7Qly8bWchOND+8LPT
fOR3aLIKNkvWH5sOi/bc+3GbItpcqgRDnEW60PYNsCwdWcqqTpZEPFGxnro+nnPc
IDt0YqtK4jHhAb+mO8sYnA1tY++TeZChxjsaixbgYQN6ruHaqFQwe4awTAlnrs7e
ozhc3r0ePruI7vPTWKEU1JhhTGAqObTRL8i/XTgg7cKdi5VSdIEBGtvIisn7KDbB
/ViR5dZApcSyADfctbvoOf4kOF6aP6kzXwto/rPrfWYEuhklYXr7EHmYI3cWimye
aKNt1rEWkz89EIo9Na390xETD/ReQgvFfgXG2Ceg4+/Vlpo7NDigUZ50LOCIVRFV
OY3O6zG8wuHcG18A1wKXT12kI/2t3/+VFXM+B7nFKXZqMME5dHMkh0cSORptyk0E
uSfZAra8bkMJ6YwGJCIzbBZ+yep6t/SFJu3GokHTVXZqAuPPnelYzWJSdeqg7O2+
pwiI3IzweMLtEIdt7QLwey5dzqGYl1IxAw8gFazyAEOu0mH3+rdKXr1LN4yEJk5t
WjbuQFXK8rjrc2/5Ki2RXOwCY0cNGRk7+/Vf5ZjYCte8eBXY++U0zK+RmIajNi8u
Tqdtrlt0hyHcPqK5at4hOQqt4lw/65eNPSxEgV6a8XcgG0oWneEYqBVlKldrixrY
SMOHenKZBvt6ugI4TKSkyNN4W2tKrQn0xr62JlNbMLlsKR+UnWKCE2EzZD67YTT+
wLL8hd1zjMjghimPN7dmuTdYMQuDo0fw4oVqRKDDcb5Kljb9pbc+4i0oxPY1zeaM
50ghHXZ4u7StEfMKE/zKrC9PN4pT6p82oQ4UWRleLLPyn3z+oSb3hmCB2l90x0Qy
0Cn5adt2ETY5qvIY/PUqQ/0FTIpN8vjp2IeKdNQFusRtcVgQHaWRiluT3w7xRcIA
wFg1Udn2fcmsdwsZadU6oo1u6A9VRcpcvwvvldQfhKt56sfAHtkBfiBevEYAIJ71
o9QaqelceNagPNnP9r/PXp8BRngn7ArfrThBa+9G/3gpmExdft1lu9xud8LjxPv7
CeOqagl3OKwMtDwyaH05S95qFz27pn/Da1LRt/2RnQLrFitS08sxtseZ8Cmkbbg6
yO9AfEAK99lA4RialCNkkQrdKYxmbqkw8FM5TTajv7yD2vXdqaF3vzxWuBcmBv5J
S+8Be0XuvEXpNb03+AedjpnbNTcCZsI+qNZZpjRr477cYcO6RudrfNfY2EImoqrK
KEgBZVVPHiWTJoh3uPOwsKp+wocLBKYWMzAuN2GUBElUIxVAYc5HH63vX+rjCcfg
RLaEZMowjgTa7OiVdOySJucLJ42XyMiOe5bYXPk4hAmgI1k1vbWn8RjncspzHwSM
-----END RSA PRIVATE KEY-----
    PEM
    @pk_bad  = 'smth'
    @psw_good  = 'testtest'
    @psw_bad   = 'wrongpsw'
  end

  def test_validation
    assert_equal nil, KkbEpay::Crypt.validate_options(
      {
        private_key: @pk_good,
        private_key_password: @psw_good
      }.merge bank_cert: KkbEpay::BANK_CERT
    ), 'good keys'

    assert_equal [:bank_cert, :private_key], KkbEpay::Crypt.validate_options(
      private_key: @pk_good,
      private_key_password: @psw_bad
    ).try(:keys).try(:sort), 'bad keys'
  end

  def test_instance_validation
    assert_equal nil, KkbEpay::crypt(
      private_key: @pk_good,
      private_key_password: @psw_good
    ).validate_options, 'good keys'

    assert_equal [:private_key], KkbEpay::crypt(
      private_key: @pk_good,
      private_key_password: @psw_bad
    ).validate_options.try(:keys), 'bad password'

    assert_equal [:private_key], KkbEpay::crypt(
      private_key: @pk_good,
      private_key_password: @psw_bad
    ).validate_options.try(:keys), 'bad key'

    assert_equal [:bank_cert], KkbEpay::crypt(
      private_key: @pk_good,
      private_key_password: @psw_good,
      bank_cert: 'wrong'
    ).validate_options.try(:keys), 'bad bank cert'
  end
end
