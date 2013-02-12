module Talk
  module Property
    module Messaging    
      extend ActiveSupport::Concern

      included do
        embeds_one :conversation,   class_name: 'Talk::Property::Conversation'
      end
    end
  end
end