# encoding: utf-8

module Talk
  module System
    class Message < Talk::Message
      embedded_in :dialog, class_name: 'Talk::System::Dialog', inverse_of: :messages

      alias_method :property_dialog, :dialog
      alias_method :thread, :dialog
      alias_method :thread=, :dialog=

      delegate :type, :conversation,  to: :property_dialog
      delegate :property,             to: :property_dialog

      # Can't be validated since only updated as it saves
      # validates :dialog,      presence: true

      def sender_type
        :system
      end

      class << self
        include Talk::Message::Validation

        def construct message, dialog
          validate_dialog! dialog
          args = construct_args(message, dialog)
          # puts "construct: #{args}"
          self.create args
        end

        protected

        def construct_args message, dialog
          validate_dialog! dialog
          message_args(message).merge(dialog: dialog)
        end

        def message_args message
          [:body, :state].each do |arg|
            raise ArgumentError, "Message must contain #{arg}" unless message.respond_to?(arg)
          end
          {body: message.body, state: message.type}
        end

        def msg_type
          :system
        end

        def valid_dialog_class
          @valid_dialog_class ||= "Talk::#{msg_type.to_s.camelize}::Dialog".constantize
        end        
      end
    end
  end
end