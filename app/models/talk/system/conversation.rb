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

      before_validation do
        self.type = :system
      end

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

      def add_dialog type = :info
        dialogs << System::Dialog.about(type)
      end

      def initiator
        :system
      end

      def initiated_by? type
        initiator == type
      end

      alias_method :replier, :sys_conversable
      alias_method :account, :sys_conversable

      class << self
        def conversation account
          self.create sys_conversable: account
        end
      end
    end
  end
end