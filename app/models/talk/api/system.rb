module Talk
  module Api
    module System
      def write message, type = :info
        Messenger.new message, type
      end
    end
  end
end