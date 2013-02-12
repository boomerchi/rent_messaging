class Account::User
  module Messaging
    extend ActiveSupport::Concern

    included do
      has_many :system_conversations,   class_name: 'Talk::System::Conversation', as: :sys_conversable
      has_many :property_conversations, class_name: 'Talk::Property::Conversation'
    end

    def conversations_about property
      property_conversations.where(property: property.id)
    end
  end
end