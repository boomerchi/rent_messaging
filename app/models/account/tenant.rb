module Account
  class Tenant < User
    include BasicDocument

    include_concerns :messaging # tenant specific
    include_concerns :messaging, for: 'Account::User'    
  end
end