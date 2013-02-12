class Account::System
  module Messaging
    extend ActiveSupport::Concern

    included do
      include ::Talk::Api::System

      has_many :system_conversations,   class_name: 'Talk::System::Conversation', as: :sys_conversable
      has_many :property_conversations, class_name: 'Talk::Property::Conversation'
    end
  end
end

