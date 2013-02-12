module Talk::Api::User
  class PropertyConversator
    include_concerns :validation, for: 'Talk::Api'

    DialogNotFoundError = ::Talk::Api::DialogNotFoundError

    # message - Talk::Api::User::Messager
    attr_accessor :messenger, :property, :receiver_account

    def initialize messenger, receiver
      validate_receiver! receiver
      validate_messenger! messenger
      @messenger = messenger
      @receiver_account = receiver
    end

    delegate :sender_account, :sender_type, :message, to: :messenger

    alias_method :receiver, :receiver_account
    alias_method :sender,   :sender_account

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

    def send_it!
      raise DialogNotFoundError, "No property dialog could be found for: #{self}" unless property_dialog
      property_dialog.write(sender_type, message)
    end

    def send_to which = :last
      raise DialogNotFoundError, "No property dialog could be found for: #{self}, dialog: #{which}" unless property_dialog(which)
      property_dialog(which).write(sender_type, message)
    end

    # TODO: Cleanup! Refactor!!

    def property_dialog which = :last
      conv = find_or_create_user_property_conversation
      conv.dialogs.empty? ? conv.dialogs.create : conv.find_dialog(which)
    end

    # find all conversations about this property
    def property_conversations
      validate_property!
      sender.conversations_about(property)
    end    
  end
end