module User::Account
  class Tenant < User
    include BasicDocument

    include_concerns :messaging # tenant specific
    include_concerns :messaging, from: 'User::Account::User'
  end
end