module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Chronopay
        module Common
          def generate_signature
            Digest::MD5.hexdigest(generate_signature_string)
          end
        end
      end
    end
  end
end
