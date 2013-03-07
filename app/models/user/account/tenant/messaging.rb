class User::Account::Tenant
  module Messaging
    extend ActiveSupport::Concern

    included do
      puts "included: Tenant:Messaging for #{self}"

      has_many :property_conversations, class_name: 'Talk::Property::Conversation', inverse_of: :tenant

      include ::Talk::Api::Tenant      
    end

    # should use strategy pattern via ServiceObject and super
    def property_conversation property, account
      # super
      unless valid_conversation_target? account
        raise ArgumentError, "Account must be a tenant or system account, was: #{account}"
      end
      conversations_about(property).find_for(account).first
    end

    protected

    def valid_conversation_targets
      [User::Account::Landlord, Account::System]
    end    
  end
end
