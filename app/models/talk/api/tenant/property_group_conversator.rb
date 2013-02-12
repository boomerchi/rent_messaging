module Talk::Api::Tenant
  class PropertyGroupConversator < Talk::Api::User::PropertyGroupConversator
    alias_method :tenant,   :sender
  end
end
