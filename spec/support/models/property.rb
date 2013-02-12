class Property
  include BasicDocument

  class DefaultNotFoundError < StandardError; end

  field :name
  field :description

  alias_method :title, :name

  belongs_to :conversation, class_name: 'Talk::Property::Conversation', inverse_of: :property

  belongs_to :owner,    class_name: 'Account::Landlord', inverse_of: :default_property
  
  belongs_to :landlord, class_name: 'Account::Landlord', inverse_of: :properties

  # A property MUST always belong to a landlord
  validates :landlord, presence: true
end
