require 'support/models/user/account/user'

module User::Account
  class Tenant < User
    include BasicDocument

    field :name, default: 'tenant'

    # has_many :system_conversations, class_name: 'Talk::System::Conversation', as: :sys_conversable
  end
end