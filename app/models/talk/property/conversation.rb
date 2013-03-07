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

      class NotFoundError < StandardError; end
      class InvalidProperty < StandardError; end

      def self.property_class
        ::Property.to_s
      end

      # Can reference (belong) to Tenant and Landlord Accounts
      belongs_to :tenant,     class_name: 'User::Account::Tenant',    inverse_of: :property_conversations
      belongs_to :landlord,   class_name: 'User::Account::Landlord',  inverse_of: :property_conversations
      belongs_to :system,     class_name: 'Account::System',          inverse_of: :property_conversations

      belongs_to :property,   class_name: property_class,       inverse_of: :conversations

      has_many :dialogs,      class_name: 'Talk::Property::Dialog'

      validates_with ConversationValidator

      validates :property, presence: true

      # Note:
      # A Tenant - Landlord conversation can in theory have multiple threads.

      # This is fx useful if they discuss rental of the same property over 
      # several renting sessions, with one Conversation Dialog 
      # for each period under discussion.
      after_initialize do
        self.system = system_account if total_count == 1 && !(tenant? && landlord?)
        self.type = self.system ? :system : :personal
        unless self.property
          self.property = landlord.property if landlord
        end        
      end

      before_save do
        unless self.property
          raise InvalidProperty, "Error: A Property Conversation can NOT be initialized without a property"
        end
      end

      # always create an initial dialog!
      after_save do
        self.system = system_account if total_count == 1        
        self.type = system ? :system : :personal
        self.dialogs.create if dialogs.empty?
      end

      scope :latest,          -> { desc  :created_at }
      scope :oldest,          -> { asc   :created_at }

      scope :between,         -> account, other_account = nil, property = nil do         
        raise ArgumentError, "Must be different types of accounts, was both: #{account.class}" if account.class == other_account.class
        raise ArgumentError, "Must take at least one Account, was: #{account}" unless valid_account? account
        
        query = query_hash account, other_account, property

        where(query).asc(:created_at)
      end

      scope :for,         -> account do         
          between(account)
      end

      def system_account
        Account::System.instance
      end

      def as_string
        %Q{
          landlord: #{landlord.id}
          tenant: #{tenant.id}
          system: #{true if system?}

          property: #{property.id}
        }
      end

      def clear_dialogs!
        dialogs.each {|dialog| dialog.destroy }
      end      

      class << self
        def between_hash account, other_account = nil, property = nil
          other_account ||= system_account

          prop_find = {}
          if property
            validate_property property 
            
            # ignore property if not ownded by landlord
            if ignore_property?(account, other_account, property)
              raise InvalidProperty, "Property: #{property} can't be talked about between #{account} and #{other_account}: no_landlord? #{no_landlord?(account, other_account)}, landlord_property? #{landlord_property?(account, other_account, property)}"
            end

            prop_find = {property: property}
          end
          
          account_hash_for(account).merge(account_hash_for other_account).merge(prop_find)
        end

        def validate_property property
          unless property.kind_of?(::Property)
            raise ArgumentError, "Must be a Property, was: #{property} - #{property.kind_of?(Property)}"        
          end
        end            

        alias_method :create_hash, :between_hash

        def ignore_property? account, other_account, property
          return false if no_landlord?(account, other_account) || landlord_property?(account, other_account, property)
          true
        end

        def query_hash account, other_account = nil, property = nil
          find_prop = property ? {property: property.id} : {}
          between_hash(account, other_account).merge(find_prop)
        end

        def no_landlord? account, other_account
          !has_landlord? account, other_account
        end

        def has_landlord? account, other_account
          !get_landlord(account, other_account).nil?
        end

        def landlord_property? account, other_account, property
          return false if !property
          landlord = get_landlord account, other_account
          return false if !landlord
          landlord.owner_of? property
        end

        def get_landlord *accounts
          accounts.flatten.find do |acc| 
            acc.type == 'landlord'
          end
        end

        def account_hash_for account
          return {} if !account
          unless valid_account? account
            raise ArgumentError, "Invalid account type: #{account.type}, must be one of: #{valid_account_types}"
          end
          {account.type.to_sym => account}        
        end

        def valid_account? account
          valid_account_types.include? account.type.to_s
        end

        def valid_account_types
          %w{tenant landlord system}
        end

        def find_between account, other_account = nil, property = nil
          where query_hash(account, other_account, property)
        end

        def create_new_between account, other_account = nil, property = nil
          self.create create_hash(account, other_account, property)
        end

        def create_between account, other_account = nil, property = nil
          res = find_between account, other_account, property
          res.blank? ? create_new_between(account, other_account, property) : res.first
        end

        def init_between account, other_account = nil, property = nil
          query = between_hash account, other_account, property
          find_or_initialize_by query
        end
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

      def find_or_create_dialog which = :last
        dialogs.empty? ? new_dialog : find_dialog(which)
      end

      def new_dialog
        dialog = Talk::Property::Dialog.create conversation: self
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
          account.kind_of?(User::Account::Tenant)
        end

        def landlord? account
          account.kind_of?(User::Account::Landlord)
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