module Talk
  module Validation

    def validate_account! account
      unless account? account
        raise ArgumentError, "Not a valid account. Was: #{account}" 
      end
    end

    def account? account
      account.kind_of? Account::Base
    end

    def landlord? account
      account.kind_of? User::Account::Landlord
    end

    def tenant? account
      account.kind_of? User::Account::Tenant
    end

    def system? account
      account.kind_of? Account::System
    end

    def valid_messenger? messenger
      messenger.kind_of? messenger_class
    end

    def messenger_class
      Talk::Api::User::Messenger
    end

    def validate_property!
      validate_property property
    end

    def validate_property property
      unless property? property
        raise ArgumentError, "Must be a Property, was: #{property} - #{property? property}"
      end
    end      

    def property? property
      return false if property.nil?      
      property.kind_of? ::Property
    end

    def validate_tenant! tenant
      return if !tenant      
      unless tenant? tenant
        raise ArgumentError, "Not a valid Tenant, was: #{tenant}"
      end
    end    
  end
end
