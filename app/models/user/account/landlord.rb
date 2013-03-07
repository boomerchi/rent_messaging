module User::Account
  class Landlord < User
    include BasicDocument

    include_concerns :messaging # landlord specific    
    include_concerns :messaging, for: 'User::Account::User'    
  end
end