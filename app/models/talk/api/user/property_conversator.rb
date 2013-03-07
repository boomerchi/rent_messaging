module Talk::Api::User
  class PropertyConversator
    include_concerns :validation, for: 'Talk::Api'

    DialogNotFoundError = ::Talk::Api::DialogNotFoundError
    GeneralMessageError = ::Talk::Conversation::GeneralMessageError

    # message - Talk::Api::User::Messager
    attr_accessor :messenger, :property, :receiver_account

    def initialize messenger, receiver
      validate_receiver! receiver
      validate_messenger! messenger
      @messenger = messenger
      @receiver_account = receiver      
    end

    delegate :sender_account, :sender_type, :message, to: :messenger

    alias_method :receiver,   :receiver_account
    alias_method :sender,     :sender_account

    def property
      @property ||= default_property
    end

    def default_property
      landlord.the_default_property
    end

    def about property
      validate_property property
      @property = property
      self
    end

    def has_property?
       property? property
     end

    def send_it! which = :last
      raise GeneralMessageError, "Property must be specified" unless has_property?
      raise DialogNotFoundError, "No property dialog could be found for: #{self}" unless property_dialog which
      property_dialog.write(sender_type, message)
    end

    # TODO: Why have two methods that do the same?
    # note: send_it! used to take no which arg
    def send_to which = :last
      raise DialogNotFoundError, "No property dialog could be found for: #{self}, dialog: #{which}" unless property_dialog(which)
      dialog = property_dialog(which)
      raise "#{which} dialog could not be created or found" unless dialog
      dialog.write(sender_type, message)
    end

    # TODO: Cleanup! Refactor!!

    def property_dialog which = :last
      property_conversation.find_or_create_dialog which
    end

    def property_conversation
      @property_conversation ||= Talk::Property::Conversation.create_between(sender, receiver, property)
    end

    def get_property_dialog which = :last
      return existing_property_conversation(which).find_dialog      
    end

    def existing_property_conversation which = :last
      raise Talk::Property::Conversation::NotFoundError if existing_property_conversations.to_a.blank?
      @existing_property_conversation ||= existing_property_conversations.last
    end

    def existing_property_conversations
      @existing_property_conversations ||= Talk::Property::Conversation.between(sender, receiver, property)
    end

    # find all conversations about this property
    def property_conversations
      validate_property!
      sender.conversations_about(property)
    end    
  end
end