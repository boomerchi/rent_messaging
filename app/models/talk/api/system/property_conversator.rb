module Talk::Api::System
  class PropertyConversater

    # message - Talk::System::Conversater
    attr_accessor :conversator, :property

    def initialize conversator, property
      @conversator = conversator
      @property = property
    end

    delegate :user_account, to: :conversator

    def send
      property_conversations.most_recent_dialog_for(user_account).each do |dialog|
        dialog.write(:system, message)
      end       
    end

    def system
      Account::System.first
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
