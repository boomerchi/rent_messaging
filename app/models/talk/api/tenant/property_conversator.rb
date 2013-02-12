module Talk::Api::Tenant
  class PropertyConversator < Talk::Api::User::PropertyConversator

    alias_method :landlord, :receiver
    alias_method :tenant,   :sender

    # protected

    def receiver_class
      Account::Landlord
    end

    def messenger_class
      Talk::Api::Tenant::Messenger
    end
  end
end
