module Talk::Api::User
  class PropertyGroupConversator
    include_concerns :validation, for: 'Talk::Api'

    # message - Talk::System::Conversater
    attr_accessor :messenger, :property

    def initialize messenger, property
      validate_messenger! messenger
      validate_property property
      @messenger = messenger
      @property = property
    end

    delegate :sender_account, :message, to: :messenger

    alias_method :sender,   :sender_account

    def receiver
      nil
    end

    # send message to all most recent dialogs
    def send_it!
      raise "No conversations found for #{property}" unless property_conversations
      property_dialogs.each do |dialog|
        dialog.write(sender_type, message)
      end
    end

    # protected

    def property_dialogs
      @property_dialogs ||= latest_property_conversation ? latest_property_conversation.dialogs : []
    end

    def latest_property_conversation
      @latest_property_conversation ||= property_conversations.latest.first
    end

    # find all conversations about this property
    def property_conversations
      @property_conversations ||= sender.conversations_about(property)
    end
  end
end
