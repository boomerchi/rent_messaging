class Account::Landlord
  module Messaging
    extend ActiveSupport::Concern

    included do
      include ::Talk::Api::Landlord

      has_many :system_conversations, class_name: 'Talk::System::Conversation', as: :sys_conversable
    end
  end
end

