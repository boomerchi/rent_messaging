require 'talk/property/conversation/class_methods'

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
      extend ClassMethods

      class NotFoundError < StandardError; end
      class InvalidProperty < StandardError; end

      def self.property_class
        ::Property.to_s
      end

      # Can reference (belong) to Tenant and Landlord Accounts
      belongs_to :tenant,     class_name: 'User::Account::Tenant',    inverse_of: :property_conversations
      belongs_to :landlord,   class_name: 'User::Account::Landlord',  inverse_of: :property_conversations
      belongs_to :system,     class_name: 'Account::System',          inverse_of: :property_conversations

      belongs_to :property,   class_name: property_class,             inverse_of: :conversations

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
        # dialog = Talk::Property::Dialog.create conversation: self
        # self.dialogs << dialog
        self.dialogs.create conversation: self
        self.save!
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

      def system_account
        Account::System.instance
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