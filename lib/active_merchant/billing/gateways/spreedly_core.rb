require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    # Public: This gateway allows you to interact with any gateway you've
    # created in Spreedly Core (https://spreedlycore.com).  It's an adapter
    # which can be particularly useful if you already have code interacting with
    # ActiveMerchant and want to easily take advantage of Core's vault.
    class SpreedlyCoreGateway < Gateway
      self.live_url = 'https://spreedlycore.com/v1'

      self.supported_countries = %w(AD AE AT AU BD BE BG BN CA CH CY CZ DE DK EE EG ES FI FR GB
                                    GI GR HK HU ID IE IL IM IN IS IT JO KW LB LI LK LT LU LV MC
                                    MT MU MV MX MY NL NO NZ OM PH PL PT QA RO SA SE SG SI SK SM
                                    TR TT UM US VA VN ZA)

      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      self.homepage_url = 'https://spreedlycore.com'
      self.display_name = 'Spreedly Core'
      self.money_format = :cents
      self.default_currency = 'USD'

      # Public: Create a new Spreedly Core Gateway.
      #
      # options - A hash of options:
      #           :login         - Your Spreedly Core API login.
      #           :password      - Your Spreedly Core API secret.
      #           :gateway_token - The token of the gateway you've created in
      #                            Spreedly Core.
      def initialize(options = {})
        requires!(options, :login, :password, :gateway_token)
        super
      end

      # Public: Run a purchase transaction.
      #
      # money          - The monetary amount of the transaction in cents.
      # payment_method - The CreditCard or the Spreedly Core payment method
      #                  token.
      # options        - A standard ActiveMerchant options hash
      def purchase(money, payment_method, options = {})
        if payment_method.is_a?(String)
          purchase_with_token(money, payment_method, options)
        else
          MultiResponse.run do |r|
            r.process { save_card(false, payment_method, options) }
            r.process { purchase_with_token(money, r.authorization, options) }
          end
        end
      end

      # Public: Run an authorize transaction.
      #
      # money          - The monetary amount of the transaction in cents.
      # payment_method - The CreditCard or the Spreedly Core payment method
      #                  token.
      # options        - A standard ActiveMerchant options hash
      def authorize(money, payment_method, options = {})
        if payment_method.is_a?(String)
          authorize_with_token(money, payment_method, options)
        else
          MultiResponse.run do |r|
            r.process { save_card(false, payment_method, options) }
            r.process { authorize_with_token(money, r.authorization, options) }
          end
        end
      end

      def capture(money, authorization, options={})
        request = build_xml_request('transaction') do |doc|
          add_invoice(doc, money, options)
        end

        commit("transactions/#{authorization}/capture.xml", request)
      end

      def refund(money, authorization, options={})
        request = build_xml_request('transaction') do |doc|
          add_invoice(doc, money, options)
        end

        commit("transactions/#{authorization}/credit.xml", request)
      end

      def void(authorization, options={})
        commit("transactions/#{authorization}/void.xml", '')
      end

      # Public: Store a credit card in the Spreedly Core vault and retain it.
      #
      # credit_card    - The CreditCard to store
      # options        - A standard ActiveMerchant options hash
      def store(credit_card, options={})
        save_card(true, credit_card, options)
      end

      # Public: Redact the CreditCard in Spreedly Core.  This wipes the
      # sensitive payment information from the card.
      #
      # credit_card    - The CreditCard to store
      # options        - A standard ActiveMerchant options hash
      def unstore(authorization, options={})
        commit("payment_methods/#{authorization}/redact.xml", '', :put)
      end

      private
      def save_card(retain, credit_card, options)
        request = build_xml_request('payment_method') do |doc|
          add_credit_card(doc, credit_card, options)
          add_data(doc, options)
          doc.retained(true) if retain
        end

        commit("payment_methods.xml", request, :post, :payment_method_token)
      end

      def purchase_with_token(money, payment_method_token, options)
        request = auth_purchase_request(money, payment_method_token, options)
        commit("gateways/#{@options[:gateway_token]}/purchase.xml", request)
      end

      def authorize_with_token(money, payment_method_token, options)
        request = auth_purchase_request(money, payment_method_token, options)
        commit("gateways/#{@options[:gateway_token]}/authorize.xml", request)
      end

      def auth_purchase_request(money, payment_method_token, options)
        build_xml_request('transaction') do |doc|
          add_invoice(doc, money, options)
          doc.payment_method_token(payment_method_token)
        end
      end

      def add_invoice(doc, money, options)
        doc.amount amount(money)
        doc.currency_code(options[:currency] || currency(money) || default_currency)
      end

      def add_credit_card(doc, credit_card, options)
        doc.credit_card do
          doc.number(credit_card.number)
          doc.first_name(credit_card.first_name)
          doc.last_name(credit_card.last_name)
          doc.month(credit_card.month)
          doc.year(credit_card.year)
          doc.email(options[:email])
          doc.address1(options[:billing_address].try(:[], :address1))
          doc.address2(options[:billing_address].try(:[], :address2))
          doc.city(options[:billing_address].try(:[], :city))
          doc.state(options[:billing_address].try(:[], :state))
          doc.zip(options[:billing_address].try(:[], :zip))
        end
      end

      def add_data(doc, options)
        doc.data do
          data_to_doc(doc, options[:data])
        end
      end

      def data_to_doc(doc, value)
        return doc.text value unless value.kind_of? Hash
        value.each do |k, v|
          doc.send(k) do
            data_to_doc(doc, v)
          end
        end
      end

      def parse(xml)
        response = {}

        doc = Nokogiri::XML(xml)
        doc.root.xpath('*').each do |node|
          if (node.elements.empty?)
            response[node.name.downcase.to_sym] = node.text
          else
            node.elements.each do |childnode|
              childnode_to_response(response, node, childnode)
            end
          end
        end

        response
      end

      def childnode_to_response(response, node, childnode)
        name = "#{node.name.downcase}_#{childnode.name.downcase}"
        if name == 'payment_method_data' && !childnode.elements.empty?
          response[name.to_sym] = Hash.from_xml(childnode.to_s).values.first
        else
          response[name.to_sym] = childnode.text
        end
      end

      def build_xml_request(root)
        builder = Nokogiri::XML::Builder.new
        builder.__send__(root) do |doc|
          yield(doc)
        end
        builder.to_xml
      end

      def commit(relative_url, request, method = :post, authorization_field = :token)
        begin
          raw_response = ssl_request(method, "#{live_url}/#{relative_url}", request, headers)
        rescue ActiveUtils::ResponseError => e
          raw_response = e.response.body
        end

        response_from(raw_response, authorization_field)
      end

      def response_from(raw_response, authorization_field)
        parsed = parse(raw_response)
        options = {
          :authorization => parsed[authorization_field],
          :test => (parsed[:on_test_gateway] == 'true'),
          :avs_result => { :code => parsed[:response_avs_code] },
          :cvv_result => parsed[:response_cvv_code]
        }

        Response.new(parsed[:succeeded] == 'true', parsed[:message] || parsed[:error], parsed, options)
      end

      def headers
        {
          'Authorization' => ('Basic ' + Base64.strict_encode64("#{@options[:login]}:#{@options[:password]}").chomp),
          'Content-Type' => 'text/xml'
        }
      end
    end
  end
end

