module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Chronopay
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          include Common

          # All currently supported checkout languages:
          #   es (Spanish)
          #   en (English)
          #   de (German)
          #   pt (Portuguese)
          #   lv (Latvian)
          #   cn1 (Chinese Version 1)
          #   cn2 (Chinese version 2)
          #   nl (Dutch)
          #   ru (Russian)
          COUNTRIES_FOR_LANG = {
            'ES'  => %w( AR BO CL CO CR CU DO EC SV GQ GT HN MX NI PA PY PE ES UY VE),
            'DE'  => %w( DE AT CH LI ),
            'PT'  => %w( AO BR CV GW MZ PT ST TL),
            'RU'  => %w( BY KG KZ RU ),
            'LV'  => %w( LV ),
            'CN1' => %w( CN ),
            'NL'  => %w( NL )
          }

          LANG_FOR_COUNTRY = COUNTRIES_FOR_LANG.inject(Hash.new("EN")) do |memo, (lang, countries)|
            countries.each do |code|
              memo[code] = lang
            end
            memo
          end

          self.country_format = :alpha3

          def initialize(order, account, options = {})
            @secret = options.delete(:secret)
            super
            add_field 'cb_type', 'p'
          end

          def generate_signature_string
            sign_params = [:account, :amount].map { |key| @fields[mappings[key]] }
            sign_params.push @secret
            sign_params.join '-'
          end

          def form_fields
            @fields.merge('sign' => generate_signature)
          end

          def billing_address(mapping = {})
            # Gets the country code in the appropriate format or returns what we were given
            # The appropriate format for Chronopay is the alpha 3 country code
            country_code = lookup_country_code(mapping.delete(:country))
            add_field(mappings[:billing_address][:country], country_code)

            countries_with_supported_states = ['USA', 'CAN']
            if !countries_with_supported_states.include?(country_code)
              mapping.delete(:state)
              add_field(mappings[:billing_address][:state], 'XX')
            end
            mapping.each do |k, v|
              field = mappings[:billing_address][k]
              add_field(field, v) unless field.nil?
            end
            add_field('language', checkout_language_from_country(country_code))
          end

          mapping :account, 'product_id'
          mapping :amount,   'product_price'

          mapping :order, 'cs1'

          mapping :notify_url, 'cb_url'
          mapping :return_url, 'success_url'
          mapping :cancel_return_url, 'decline_url'

          mapping :invoice, 'product_name'
          mapping :currency, 'product_price_currency'

          mapping :customer, :first_name => 'f_name',
                             :last_name  => 's_name',
                             :phone      => 'phone',
                             :email      => 'email'

          # country - The country must be a 3 digit country code
          mapping :billing_address, :city     => 'city',
                                    :address1 => 'street',
                                    :state    => 'state',
                                    :zip      => 'zip',
                                    :country  => 'country'
          mapping :credit_card, :number       => 'card_no',
                                :expiry_month => 'exp_month',
                                :expiry_year  => 'exp_year'

          # cs1
          # cs2
          # cs3

          private

          def checkout_language_from_country(country_code)
            country    = Country.find(country_code)
            short_code = country.code(:alpha2).to_s
            LANG_FOR_COUNTRY[short_code]
          rescue InvalidCountryCodeError
            'EN'
          end
        end
      end
    end
  end
end
