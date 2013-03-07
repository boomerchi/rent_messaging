class User::Account::User
  class PropertyMessenger
    include Talk::Validation

    attr_accessor :account, :target_account, :property

    def initialize account, property = nil
      validate_account! account
      @account  = account
      about(property) if property 
    end

    delegate :property_conversations, :system_conversations, to: :account

    alias_method :all_property_conversations, :property_conversations

    def about property
      validate_property property
      @property = property      
    end

    def find_for target_account
      @target_account = target_account
      validate_target_account! target_account
      user_conversation
    end

    def get_conversations
      property ? select_property_conversations : all_property_conversations
    end

    def select_property_conversations
      property_conversations.where property: property.id
    end

    protected

    def validate_target_account! target_account
      unless valid_target_account? target_account
        raise ArgumentError, "Target account type must be one of a #{valid_target_account_types}, was: #{target_account.type}"
      end
    end

    def valid_target_account? target_account
      valid_target_account_types.any? {|type| target_account.type.to_sym == type }
    end    

    def valid_target_account_types
      @valid_accounts ||= account_types.dup.delete_if {|type| type == account.type.to_sym }
    end

    def account_types
      [:tenant, :landlord, :system]
    end

    def it_matches
      {find_key => target_account}.merge(property_matcher)
    end    

    def property_matcher
      property ? {property: property.id} : {}
    end

    # validations
    def find_key
      account_types.find{|key| send("#{key}?", target_account) }
    end

    def user_conversation
      property_conversations.where it_matches
    end
  end
end