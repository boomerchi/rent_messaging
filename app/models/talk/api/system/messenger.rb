module Talk::Api::System
  class Messenger

    # message - Talk::System::Message
    attr_accessor :message

    def initialize message, type = :info
      @message = Hashie::Mash.new body: message, type: type, state: type
    end

    def to user_account
      validate_user user_account
      Talk::Api::System::Conversator.new self, user_account
    end

    def validate_user user_account
      unless user_account.kind_of?(User::Account::User)
        raise ArgumentError, "Must be an Account::User, was: #{user_account}"
      end
    end
  end
end

