module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Chronopay
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include Common

          def complete?
            true
          end

          def status
            'Completed'
          end

          # Unique ID of transaction
          def transaction_id
            params['transaction_id']
          end

          # Type of transaction
          def transaction_type
            params['transaction_type']
          end

          # Unique ID of customer
          def customer_id
            params['customer_id']
          end

          # Unique ID of Merchant’s web-site
          def site_id
            params['site_id']
          end

          # ID of a product that was purchased
          def product_id
            params['product_id']
          end

          # Language
          def language
            params['language']
          end

          def received_at
            # Date should be formatted "dd-mm-yy" to be parsed by 1.8 and 1.9 the same way
            formatted_date = Date.strptime(date, "%m/%d/%Y").strftime("%d-%m-%Y")
            Time.parse("#{formatted_date} #{time}") unless date.blank? || time.blank?
          end

          # Date of transaction in MM/DD/YYYY format
          def date
            params['date']
          end

          # Time of transaction in HH:MM:SS format
          def time
            params['time']
          end

          # The customer's full name
          def name
            params['name']
          end

          # The customer's email address
          def email
            params['email']
          end

          # The customer's street address
          def street
            params['street']
          end

          # The customer's country - 3 digit country code
          def country
            params['country']
          end

          # The customer's city
          def city
            params['city']
          end

          # The customer's zip
          def zip
            params['zip']
          end

          # The customer's state.  Only useful for US Customers
          def state
            params['state']
          end

          # Customer’s login for restricted access zone of Merchant’s Web-site
          def username
            params['username']
          end

          # Customer's password for restricted access zone of Merchant’s Web-site, as chosen
          def password
            params['password']
          end

          # The item id passed in the first custom parameter
          def item_id
            params['cs1']
          end

          # Additional parameter
          def custom2
            params['cs2']
          end

          # Additional parameter
          def custom3
            params['cs3']
          end

          # The currency the purchase was made in
          def currency
            params['currency']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['total']
          end

          def security_key
            params['sign']
          end

          def test?
            date.blank? && time.blank? && transaction_id.blank?
          end

          def acknowledge
            security_key == generate_signature
          end

          def secret
            @options[:secret]
          end

          def generate_signature_string
            [secret, customer_id, transaction_id, transaction_type, gross].join
          end
        end
      end
    end
  end
end
