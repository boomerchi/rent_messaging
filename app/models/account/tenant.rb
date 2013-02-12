module Account
  class Tenant < User
    include BasicDocument

    include_concerns :messaging, for: 'Account::User'
    include_concerns :messaging # tenant specific
  end
end