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
      module ClassMethods
        include Talk::Validation

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
          validate_property! property          
          validate_tenant! tenant
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
      end
    end
  end
end