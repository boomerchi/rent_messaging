class Account::Landlord
  module Messaging
    extend ActiveSupport::Concern

    included do
      has_many :property_conversations, class_name: 'Talk::Property::Conversation', inverse_of: :landlord

      include ::Talk::Api::Landlord
    end

    # should use strategy pattern via ServiceObject and super
    def property_conversation property, account
      unless owner_of? property
        raise ArgumentError, "Property must be owned by you, was: #{property} belonging to #{property.landlord}"
      end

      # super
      unless valid_conversation_target? account
        raise ArgumentError, "Account must be a tenant or system account, was: #{account}"
      end
      conversations_about(property).find_for(account).first
    end

    def owner_of_any? *properties
      properties.flatten.any? {|prop| owner_of? property }
    end

    def owner_of_all? *properties
      properties.flatten.all? {|prop| owner_of? property }
    end

    def owner_of? property
      property.owner == self || property.landlord == self
    end
    alias_method :i_own?, :owner_of?

    protected

    def valid_conversation_targets
      [Account::Tenant, Account::System]
    end
  end
end

