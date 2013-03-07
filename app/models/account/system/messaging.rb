class Account::System
  module Messaging
    extend ActiveSupport::Concern

    include Talk::Validation

    included do
      include ::Talk::Api::System

      has_many :system_conversations,   class_name: 'Talk::System::Conversation',   as: :sys_conversable

      has_many :property_conversations, class_name: 'Talk::Property::Conversation', inverse_of: :system

      alias_method :conversations, :system_conversations
    end

    def conversations_with account
      property_messenger.find_for account
    end
    
    def conversation_with account
      conversations_with(account).last
    end

    alias_method :property_conversations_with,  :conversations_with
    alias_method :property_conversation_with,   :conversation_with

    # conversations_about(property).with(account)
    def conversations_about property
      property_messenger property
    end    

    def general_conversation_with account
      system_conversations.where it_matches(account)
    end    

    def property_messenger property = nil
      User::Account::User::PropertyMessenger.new self, property
    end

    protected

    def it_matches account
      landlord? account ? {landlord: account.id} : {tenant: account.id}
    end
  end
end

