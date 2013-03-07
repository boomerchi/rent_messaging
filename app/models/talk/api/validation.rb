module Talk::Api
  module Validation
    extend ActiveSupport::Concern

    include ::Talk::Validation

    # sender
    def validate_sender! sender
      sender_error! sender unless valid_sender? sender
    end

    def valid_sender? sender
      sender.kind_of? sender_class
    end

    def sender_error! sender
      raise Talk::Conversation::SenderError, "Sender must be a #{sender_class}, was: #{sender}" unless valid_sender? sender
    end

    # if landlord, there must already be a dialog started 
    # with at least one message from tenant or system
    def validate_sending!
      return unless landlord? sender
      get_property_dialog
    rescue Talk::Property::Conversation::NotFoundError
      raise Talk::Conversation::InitiationError, "Sender #{sender} can't initiate a conversation or dialog: receiver: #{receiver.inspect} property: #{property.inspect}"
    end

    # receiver

    def validate_receiver! receiver
      receiver_error! receiver unless valid_receiver? receiver      
    end

    def receiver_error! receiver
      raise Talk::Conversation::ReceiverError, "Receiver must be a #{receiver_class}, was: #{receiver}"
    end

    def valid_receiver? receiver
      receiver.kind_of? receiver_class
    end

    def receiver_class
      raise NotImplementedError, "Must be implemented by subclass"
    end

    def sender_class
      raise NotImplementedError, "Must be implemented by subclass"
    end

    # messenger

    def validate_messenger! messenger
      messenger_error! messenger unless valid_messenger? messenger
    end 

    def messenger_error! messenger
      raise ArgumentError, "Must be a #{messenger_class}, was: #{messenger}"    
    end
  end
end