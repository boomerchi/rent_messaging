module Account
  class Landlord < User
    include BasicDocument

    include_concerns :messaging, for: 'Account::User'
    include_concerns :messaging # landlord specific    
  end
end