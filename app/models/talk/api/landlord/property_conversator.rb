module Talk::Api::Landlord
  class PropertyConversator < Talk::Api::User::PropertyConversator

    def initialize messenger, receiver
      super
      validate_sending!
    end

    alias_method :landlord, :sender
    alias_method :tenant,   :receiver

    def receiver_class
      Account::Tenant
    end

    def messenger_class
      Talk::Api::Landlord::Messenger
    end
  end
end
