require 'support/models/account/user'

module Account
  class Landlord < User
    include BasicDocument

    field :name, default: 'landlord'

    has_many :properties,       class_name: 'Property', inverse_of: :landlord
    has_one  :default_property, class_name: 'Property', inverse_of: :owner

    def property= property
      self.properties << property
    end

    def the_default_property
      unless default_property?
        raise Property::DefaultNotFoundError, "No default property can be determined unless exactly 1 property (has #{properties.count}) or one explicitly set as default_property (= #{default_property})"
      end
      default_property || properties.last
    end
    alias_method :property, :the_default_property

    def default_property?
      default_property || properties.count == 1
    end

    # has_many :system_conversations, class_name: 'Talk::System::Conversation', as: :sys_conversable    
  end
end