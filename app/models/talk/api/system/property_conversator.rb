module Talk::Api::System
  class PropertyConversator

    # message - Talk::System::Conversater
    attr_accessor :conversator, :property

    def initialize conversator, property
      @conversator = conversator
      @property = property
    end

    delegate :user_account, :message, to: :conversator

    def system_account
      Account::System.instance
    end

    alias_method :receiver,   :user_account
    alias_method :sender,     :system_account

    alias_method :property?,  :property

    def send_it!
      raise GeneralMessageError, "Property must be specified" unless property?
      raise DialogNotFoundError, "No property dialog could be found for: #{self}" unless property_dialog

      property_dialog.write sender_type, message
    end

    def sender_type
      :system
    end

    def property_dialog which = :last
      @property_dialog ||= property_conversation.find_or_create_dialog which
    end

    def property_conversation
      @property_conversation ||= Talk::Property::Conversation.create_between(sender, receiver, property)
    end

    # find all conversations about this property
    def property_conversations
      unless property
        raise 'Conversation must be about a property. Use #about(property) before calling #send'
      end
      system.conversations_about(property)
    end    
  end
end
