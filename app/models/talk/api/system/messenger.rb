module Talk::Api::System
  class Messenger

    # message - Talk::System::Message
    attr_accessor :message

    def initialize message, type = :info
      @message = {body: message, type: type}
    end

    def to user_account
      unless user_account.kind_of?(Account::User)
        raise ArgumentError, "Must be an Account::User, was: #{user_account}"
      end
      Talk::Api::System::Conversator.new self, user_account
    end
  end
end

