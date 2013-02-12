module Talk
  module Api
    module Landlord
      def write message, type = :info
        Messenger.new self, message, type
      end
    end
  end
end