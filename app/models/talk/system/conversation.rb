module Talk
  module System
    # A Conversation can be for either
    # - A given property, owned by the landlord
    # - System-Landlord (no property)

    # A Property conversation can include threads for
    # - System
    # - A given Tenant

    # A Conversation is always "owned" by the Landlord of the property
    class Conversation < ::Talk::Conversation
      def self.property_class
        ::SearchableProperty.to_s
      end

      belongs_to :sys_conversable,  polymorphic: true

      has_many :dialogs,      class_name: 'Talk::System::Dialog'

      before_validation do
        self.type = :system
      end

      # validates_with ConversationValidator      

      # any account is a conversable?
      # belongs_to :tenant,     class_name: 'Account::Tenant',    inverse_of: :property_conversations
      # belongs_to :landlord,   class_name: 'Account::Landlord',  inverse_of: :property_conversations

      alias_method :tenant,   :sys_conversable
      alias_method :landlord, :sys_conversable

      def tenant= account
        raise ArgumentError, "Must be a tenant account, was: #{account}" unless account.kind_of?(Account::Tenant)
        self.sys_conversable = account
      end

      def landlord= account
        raise ArgumentError, "Must be a landlord account, was: #{account}" unless account.kind_of?(Account::Landlord)
        self.sys_conversable = account
      end

      def add_dialog state = :info
        dialogs.create state: state, conversation: self
      end

      def clear_dialogs!
        dialogs.each {|dialog| dialog.destroy }
      end      

      def system_account
        Account::System.instance
      end

      def initiator
        system_account
      end

      def initiated_by? type
        case type
        when Symbol, String
          initiator.type == type.to_s
        when Account::Base
          initiated_by? type.type # type is an account
        else
          raise ArgumentError, "Must compare with Account or type as String or Symbol, was: #{type}"
        end
      end

      def find_or_create_dialog which = :last
        dialogs.empty? ? new_dialog : find_dialog(which)
      end

      def new_dialog
        dialog = Talk::System::Dialog.create conversation: self
        self.dialogs << dialog
        dialog
      end

      def find_dialog which = :last
        case which
        when :last
          dialogs.last
        when Fixnum
          dialogs[which]
        else
          raise ArgumentError, "Not sure which: #{which} dialog you want to use"
        end      
      end

      alias_method :receiver, :sys_conversable
      alias_method :account,  :sys_conversable

      def replier
        nil
      end

      def system?
        true
      end

      class << self
        def conversation_with account
          self.create sys_conversable: account
        end
        alias_method :with, :conversation_with

        def create_with account
          self.find_or_create_by sys_conversable: account
        end
      end
    end
  end
end