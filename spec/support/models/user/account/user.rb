module User::Account
  class User < Account::Base
    include BasicDocument
    
    field :name
  end
end
