class User::Account::User
  module Messaging
    extend ActiveSupport::Concern

    included do
      has_many :system_conversations,   class_name: 'Talk::System::Conversation', as: :sys_conversable      

      alias_method :conversations, :property_conversations

      alias_method :user_conversation, :property_conversation      
    end

    def total_unread_dialogs type = :all
      meth = "total_unread_#{type}_dialogs"
      raise ArgumentError, "Unsupported type: #{type}" unless respond_to? meth
      send meth
    end

    def unread_system_messages
      unread_dialogs_for(:system).inject(0) {|sum, dialog| sum += dialog.messages.count }
    end

    def unread_dialogs_for conv_type = :property
      conversations_for(conv_type).map do |conversation|
        conversation.unread_dialogs_for self.type
      end.flatten
    end

    def conversation_class_for type
      "Talk::#{type.to_s.camelize}::Conversation".constantize
    end

    def conversation_for conv_type = :property
      conversations_for(conv_type).first
    end

    def conversations_for conv_type = :property
      case conv_type.to_sym        
      when :system
        get_system_conversations
      when :property
        conversation_class_for(conv_type).where(self.type => self.id).to_a
      else
        raise ArgumentError, "Unsupported conversation type"
      end
    end

    def get_system_conversations
      # self.send("#{conv_type}_conversations")
      conversation_class_for(:system).where(:sys_conversable => self.id).to_a
    end

    def read_dialogs_for conv_type = :property
      conversations_for(conv_type).map do |conversation| 
        conversation.read_dialogs_for self.type
      end.flatten
    end  

    def calc_unread_dialogs_for conv_type = :property
      conversations_for(conv_type).inject(0) {|sum, conversation| sum += conversation.unread_dialogs_count_for self.type }
    end

    def unread_property_dialogs
      unread_dialogs_for :property
    end  

    def read_property_dialogs
      read_dialogs_for :property
    end  

    def total_unread_property_dialogs
      calc_unread_dialogs_for :property
    end  

    def total_unread_system_dialogs
      calc_unread_dialogs_for :system
    end  

    def total_unread_all_dialogs
      total_unread_property_dialogs + total_unread_system_dialogs
    end    

    def conversations_with account
      property_messenger.find_for account
    end
    
    def conversation_with account, which = :last
      convs = conversations_with(account)
      case which
      when :last
        convs.last
      when :first
        convs.first
      when Fixnum
        convs[which]
      else
        raise ArgumentError, "Invalid which: must be number fx 1, :first or :last, was: #{which}"
      end
    end

    alias_method :property_conversations_with,  :conversations_with
    alias_method :property_conversation_with,   :conversation_with
    
    def conversations_about property
      property_messenger property
    end

    def property_messenger property = nil
      property_messenger_class.new self, property
    end

    protected

    def property_messenger_class
      User::Account::User::PropertyMessenger
    end

    def valid_conversation_target? account
      valid_conversation_targets.any? {|clazz| account.kind_of? clazz }
    end    

    def system? account
      account.kind_of? Account::System
    end    

    def user? account
      !system? account
    end    
  end
end