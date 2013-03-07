module Talk
  class Message
    module Validation
      def validate_dialog! dialog
        unless valid_dialog? dialog
          raise ArgumentError, "Not a valid dialog for constructing message: #{dialog.inspect}. Should be a #{valid_dialog_class}"
        end
      end

      def valid_dialog? dialog
        dialog && dialog.kind_of?(valid_dialog_class)
      end
    end
  end
end