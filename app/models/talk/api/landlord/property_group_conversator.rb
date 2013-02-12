module Talk::Api::Landlord
  class PropertyGroupConversator < Talk::Api::User::PropertyGroupConversator
    alias_method :landlord, :sender
  end
end
