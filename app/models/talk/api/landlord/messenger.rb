module Talk::Api::Landlord
  class Messenger < Talk::Api::User::Messenger
    def initialize sender, message, type = :info
      super
    end

    def to receiver
      conversator_for receiver
    end        

    def sender_class
      User::Account::Landlord
    end    
  end
end

