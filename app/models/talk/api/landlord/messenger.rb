module Talk::Api::Landlord
  class Messenger < Talk::Api::User::Messenger
    def initialize sender, message, type = :info
      super
    end

    def sender_class
      Account::Landlord
    end    
  end
end

