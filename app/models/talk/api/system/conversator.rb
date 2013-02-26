module Talk::Api::System
  class Conversator
    include_concerns :validation, for: 'Talk::Api'

    # message - Talk::System::Message
    attr_accessor :user_account, :messenger

    def initialize messenger, user_account
      @messenger = messenger
      @user_account = user_account
    end

    delegate :message, to: :messenger

    alias_method :receiver, :user_account

    def about property
      validate_property property

      Talk::Api::System::PropertyConversator.new self, property
    end

    # Bind the models for General System message
    def send_it!
      raise DialogNotFoundError, "No system dialog could be found for: #{self}" unless system_dialog

      system_dialog.write sender_type, message      
    end

    def sender_type
      :system
    end

    def system_dialog which = :last
      @system_dialog ||= system_conversation.find_or_create_dialog which
    end

    def system_conversation
      @system_conversation ||= Talk::System::Conversation.create_with receiver
    end

    # find all conversations about this property
    def system_conversations
      system.conversations
    end     
  end
end

