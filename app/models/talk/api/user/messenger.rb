module Talk::Api::User
  class Messenger
    include_concerns :validation, for: 'Talk::Api'

    # message - {body: message, type: type}
    attr_accessor :message, :sender_account

    def initialize sender, message, type = :info
      validate_sender! sender
      @sender_account = sender
      @message = Hashie::Mash.new body: message, type: type, state: type
    end

    alias_method :sender, :sender_account

    def receiver
      nil
    end

    def about property
      validate_property property
      group_conversator_for self, property
    end

    def to receiver
      conversator_for receiver
    end    

    def conversator_for receiver
      conversator_class.new self, receiver
    end

    def group_conversator_for messager, property
      group_conversator_class.new messager, property
    end

    def group_conversator_class
      "Talk::Api::#{sender_type.to_s.camelize}::PropertyGroupConversator".constantize
    end

    def conversator_class
      "Talk::Api::#{sender_type.to_s.camelize}::PropertyConversator".constantize
    end

    # protected

    def sender_class
      "Account::#{sender_type.to_s.camelize}".constantize
    end

    def sender_type
      self.class.to_s.split('::')[2].underscore
    end    

    def sender_type
      self.class.to_s.split('::')[2].underscore
    end
  end
end