module Talk
  module Api
    module Tenant
      def write message, type = :info
        Messenger.new self, message, type
      end
    end
  end
end