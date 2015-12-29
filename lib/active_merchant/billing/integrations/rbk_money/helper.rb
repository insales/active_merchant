# encoding: utf-8
require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module RbkMoney
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          mapping :account, 'eshopId'
          mapping :amount, 'recipientAmount'
          mapping :currency, 'recipientCurrency'
          mapping :order, 'orderId'
          mapping :return_url, 'successUrl'
          mapping :cancel_return_url, 'failUrl'
          mapping :description, 'serviceName'
          mapping :email, 'user_email'
          mapping :due_date, 'DueDate'

          attr_accessor :order_lines

          CUSTOM_OPTIONS = Set.new [
            :description,
            :cancel_return_url,
            :return_url,
            :email,
            :order_lines,
            :due_date,
          ]

          ORDER_LINES_FIELDS = Set.new [
            :Name,
            :Description,
            :TotalPrice,
            :Count,
          ]

          # userFields never used actually
          SIGNATURE_FIELDS = %w(eshopId recipientAmount recipientCurrency user_email serviceName orderId userFields)

          def initialize(order, account, options)
            options = options.dup
            @secret_key = options.delete(:secret_key)
            fields = options.extract!(*CUSTOM_OPTIONS)
            super(order, account, options).tap {
              fields.each { |field, value| send "#{field}=", value }
            }
          end

          def signature(fields)
            s = SIGNATURE_FIELDS.map{|key| fields[key]}.join('::') + "::#{@secret_key}" # Seriously, fuck this shit
            Digest::MD5.hexdigest(s)
          end

          def form_fields
            result = super
            result['hash'] = signature(result)
            order_lines.try(:each_with_index) do |line, i|
              ORDER_LINES_FIELDS.each do |field|
                result["PurchaseItem_#{i}_#{field}"] = line[field]
              end
            end
            result
          end
        end
      end
    end
  end
end
