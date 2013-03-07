# encoding: utf-8

module Talk
  module Property
    class Message < Talk::Message
      embedded_in :dialog, class_name: 'Talk::Property::Dialog', inverse_of: :messages

      alias_method :property_dialog, :dialog
      alias_method :thread, :dialog
      alias_method :thread=, :dialog=

      delegate :type, :conversation,  to: :property_dialog
      delegate :property,             to: :property_dialog

      field :sender_type, type: String

      # Can't be validated since only updated as it saves
      # validates :dialog,      presence: true

      validates :sender_type, presence: true, inclusion: {in: ['system', 'tenant', 'landlord']}

      class << self
        include Talk::Message::Validation

        def from sender_type, message, dialog
          validate_dialog! dialog
          args = construct_args(sender_type, message, dialog)
          self.create args
        end

        protected

        def construct_args sender_type, message, dialog
          validate_dialog! dialog
          message_args(message).merge sender_type: sender_type, dialog: dialog
        end

        def message_args message
          [:body, :state].each do |arg|
            raise ArgumentError, "Message must contain #{arg}" unless message.respond_to?(arg)
          end
          {body: message.body, state: message.type}
        end

        def valid_dialog_class
          @valid_dialog_class ||= "Talk::#{msg_type.to_s.camelize}::Dialog".constantize
        end                      

        def msg_type
          :property
        end
      end
    end
  end
end