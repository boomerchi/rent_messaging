module Talk
  module Api
    module Tenant
      def write message, type = :info
        Messenger.new self, message, type
      end

      def conversations_with account, property = nil
        validate_conversation_party! account
        validate_property!
        return property_conversations_with account, property if property? property
        system_conversations
      end

      def property_conversations_with account, property
        case account
        when User::Account::Landlord
          property_conversations.where(landlord: account, property: property)
        when User::Account::System
          property_conversations.where(type: 'system', property: property)
        else
          raise ArgumentError, "Unsupported kind of account for property conversations search, was: #{account}"
        end
      end

      def property? property
        property && property.kind_of?(Property)
      end

      def validate_property! property
        return if property? property
        if property && !property.kind_of?(Property)
          raise AgumentError, "Invalid Property, was: #{property}"
        end
      end


      def validate_conversation_party! account
        unless valid_conversation_party? account
          raise ArgumentError, "Must pass the System or Landlord account for which to get the conversations, was: #{account}"
        end
      end

      def valid_conversation_party? account
        valid_conversation_parties.any?{|type| account.kind_of? type }
      end

      def valid_conversation_parties
        [User::Account::Landlord, User::Account::System]
      end
    end
  end
end