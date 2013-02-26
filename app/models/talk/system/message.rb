module Talk
  module System
    class Message < Talk::Message
      embedded_in :dialog, class_name: 'Talk::System::Dialog', inverse_of: :messages

      alias_method :property_dialog, :dialog
      alias_method :thread, :dialog
      alias_method :thread=, :dialog=

      delegate :type, :conversation,  to: :property_dialog
      delegate :property,             to: :property_dialog

      validates :dialog,      presence: true

      def sender_type
        :system
      end

      def self.construct message, dialog
        self.create construct_args(message, dialog)
      end

      protected

      def self.construct_args message, dialog
        message_args(message).merge(sender_type: sender_type, dialog: dialog)
      end

      def self.message_args message
        [:body, :state].each do |arg|
          raise ArgumentError, "Message must contain #{arg}" unless message.respond_to?(arg)
        end
        {body: message.body, state: message.type}
      end
    end
  end
end