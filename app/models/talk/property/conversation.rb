module Talk
  module Property
    # A Conversation can be for either
    # - A given property, owned by the landlord
    # - System-Landlord (no property)

    # A Property conversation can include threads for
    # - System
    # - A given Tenant

    # A Conversation is always "owned" by the Landlord of the property
    class Conversation < ::Talk::Conversation

      def self.property_class
        ::Property.to_s
      end

      # Can reference (belong) to Tenant and Landlord Accounts
      belongs_to :tenant,     class_name: 'Account::Tenant',    inverse_of: :property_conversations
      belongs_to :landlord,   class_name: 'Account::Landlord',  inverse_of: :property_conversations
      belongs_to :system,     class_name: 'Account::System',    inverse_of: :property_conversations

      has_one :property,      class_name: property_class

      has_many :dialogs,      class_name: 'Talk::Property::Dialog'

      validates_with ConversationValidator

      validates :property, presence: true

      # Note:
      # A Tenant - Landlord conversation can in theory have multiple threads.

      # This is fx useful if they discuss rental of the same property over 
      # several renting sessions, with one Conversation Dialog 
      # for each period under discussion.
      after_initialize do
        self.system = Account::System.instance if total_count == 1 && !(tenant? && landlord?)
        self.type = self.system ? :system : :personal
        unless self.property
          self.property = landlord.property if landlord
        end
      end

      # always create an initial dialog!
      after_save do
        self.system = Account::System.instance if total_count == 1        
        self.type = system ? :system : :personal
        self.dialogs.create if dialogs.empty?
      end

      scope :latest,          -> { desc  :created_at }
      scope :oldest,          -> { asc   :created_at }

      scope :between,         -> account, other_account = nil do         
        raise ArgumentError, "Must take at least one Account, was: #{account}" unless valid_account? account
        # map ids on hash ?
        where(between_hash account, other_account).asc(:created_at)
      end

      scope :for,         -> account do         
          between(account)
      end

      def self.between_hash account, other_account = nil
        other_account ||= system_account
        {}.merge(account_hash_for account).merge(account_hash_for other_account)
      end

      # def ids hash
      #   hash.each do |key, value|
      #     my_hash[key] = value.id
      #   end
      # end

      def self.system_account
        Account::System.instance
      end

      def self.account_hash_for account
        return {} if !account
        unless valid_account? account
          raise ArgumentError, "Invalid account type: #{account.type}, must be one of: #{valid_account_types}"
        end
        {account.type.to_sym => account}        
      end

      def self.valid_account? account
        valid_account_types.include? account.type.to_s
      end

      def self.valid_account_types
        %w{tenant landlord system}
      end

      def self.create_between account, other_account = nil
        find_or_create_by between_hash(account, other_account)
      end

      def self.init_between account, other_account = nil
        find_or_initialize_by between_hash(account, other_account)
      end

      def initiator
        system || tenant
      end

      def tenant?
        self.tenant
      end

      def landlord?
        self.landlord
      end

      def system?
        unless self.type
          self.type = self.system ? :system : :personal
        end
        self.type == 'system'
      end

      def personal?
        !system?
      end

      def replier
        case initiator 
        when :system, Account::System
          # human can't replies to system. 
          # system always initiates system comm.
          # landlord ? landlord : tenant
          nil
        else
          # must be reverse of initiator        
          landlord
        end
      end

      def receiver
        case initiator 
        when :system, Account::System
          # human receives messages from system. 
          # system always initiates system comm.
          landlord ? landlord : tenant
        else
          # must be reverse of initiator        
          landlord
        end
      end

      def find_dialog(which)
        case which
        when :last
          dialogs.last
        when Fixnum
          dialogs[which]
        else
          raise ArgumentError, "Not sure which: #{which} dialog you want to use"
        end      
      end

      class << self
        # Example use
        # Open System converation with Tenant about specific property
        #   Property::Conversation.about property, tenant

        # Open System converation with about specific property
        #   Property::Conversation.with_system_about property
        #   Property::Conversation.with_system_about property, tenant
        def with_system_about property, tenant = nil
          validate! property, tenant
          tenant ? system_tenant(property, tenant) : system_landlord(property)
        end

        # Open converation between Landlord and Tenant about property
        #   Property::Conversation.about property, tenant
        def about property, tenant
          validate! property, tenant
          tenant_landlord property, tenant        
        end

        protected

        def validate! property, tenant
          unless property? property
            raise ArgumentError, "Not a valid Property, was: #{property}"
          end

          return if !tenant
          unless tenant? tenant
            raise ArgumentError, "Not a valid Tenant, was: #{tenant}"
          end
        end

        # constructor methods for each variant
        def tenant_landlord property, tenant
          validate! property, tenant
          self.create tenant: tenant, landlord: property.landlord
        end
        alias_method :landlord_tenant, :tenant_landlord

        def system_tenant property, tenant
          validate! property, tenant
          self.create property: property, tenant: tenant
        end
        alias_method :tenant_system, :system_tenant

        def system_landlord property
          unless property.landlord
            raise ArgumentError, "Property must have a landlord, #{property.inspect}"
          end
          self.create landlord: property.landlord
        end   
        alias_method :landlord_system, :system_landlord

        def property? property
          property.kind_of?(::Property)
        end
               
        def tenant? account
          account.kind_of?(Account::Tenant)
        end

        def landlord? account
          account.kind_of?(Account::Landlord)
        end
      end

      # protected

      def count account
        self.send(account) ? 1 : 0
      end

      def total *accounts
        accounts.flatten.inject(0) {|res, account| res += count(account) }
      end

      def total_count
        total(:system, :tenant, :landlord)
      end

    end
  end
end