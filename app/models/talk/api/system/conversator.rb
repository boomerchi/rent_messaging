module Talk::Api::System
  class Conversator

    # message - Talk::System::Message
    attr_accessor :user_account, :messager

    def initialize messager, user_account
      @messager = messager
      @user_account = user_account
    end

    def about property
      unless user_account.kind_of?(Property)
        raise ArgumentError, "Must be a Property, was: #{property}"
      end
      Talk::Api::System::PropertyConversator.new self, property
    end

    # Bind the models for General System message
    def send

    end
  end
end

