require 'base64'
require 'openssl'

class ActiveMerchant::Billing::Integrations::KkbEpay::Crypt
  BANK_CONTENT_REGEX = /\A<document.*?>(.+)<bank_sign.*\z/.freeze
  BANK_SIGN_REGEX = /<bank_sign.*?>(.*)<\/bank_sign>/.freeze

  class << self
    def validate_options(options)
      new(options).validate_options
    end
  end

  def initialize(options)
    @options = options
  end

  def signed_xml_b64(data)
    Base64.encode64(signed_xml data).gsub("\n", '')
  end

  def check_signed_xml(xml)
    content = BANK_CONTENT_REGEX.match(xml)[1]
    bank_sign_raw_base64 = BANK_SIGN_REGEX.match(xml)[1]
    bank_sign_raw = Base64.decode64 bank_sign_raw_base64
    bank_sign_raw.reverse!

    digest = OpenSSL::Digest::SHA1.new
    bank_public_key.verify digest, bank_sign_raw, content
  end

  def validate_options
    errors = {}
    begin
      bank_public_key
    rescue => e
      errors[:bank_cert] = e.message
    end
    begin
      private_key
    rescue => e
      errors[:private_key] = e.message
    end
    errors.empty? ? nil : errors
  end

  protected
    def bank_public_key
      cert = @options[:bank_cert] || File.read(@options[:bank_cert_path])
      OpenSSL::X509::Certificate.new(cert).public_key
    end

    def private_key
      private_key = @options[:private_key] || File.read(@options[:private_key_path])
      pkey = OpenSSL::PKey::RSA.new(private_key, @options[:private_key_password])
    end

    def xml_content(data)
      <<XML.gsub("\n", '')
<merchant cert_id="#{@options[:cert_id]}" name="#{@options[:merchant_name]}">
  <order order_id="#{data[:order_id]}" amount="#{data[:amount]}" currency="#{data[:currency]}">
    <department merchant_id="#{@options[:merchant_id]}" amount="#{data[:amount]}"/>
  </order>
</merchant>
XML
    end

    def xml_sign(xml)
      signature = private_key.sign OpenSSL::Digest::SHA1.new, xml
      signature.reverse!
      signature_encoded = Base64.encode64(signature).gsub("\n", '')
      %Q|<merchant_sign type="RSA">#{signature_encoded}</merchant_sign>|
    end

    def signed_xml(data)
      xml = xml_content data
      "<document>#{xml}#{xml_sign xml}</document>"
    end
end
