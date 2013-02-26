module Talk
  module Property
    class Dialog < ::Talk::Dialog
      include BasicDocument

      def self.message_class
        'Talk::Property::Message'
      end      

      field :state, type: String

      # valid states depends on type of conversation 
      # - personal or system    
      validates :state, property_dialog_state: true

      belongs_to :conversation, class_name: 'Talk::Property::Conversation'

      embeds_many :messages, class_name: message_class, as: :msg_dialog # inverse_of: :property_dialog

      scope :latest, -> { desc(:created_at) }
      scope :oldest, -> { asc(:created_at)  } 

      before_validation do
        if self.state.nil?
          self.state = system? ? :info : :interested
        end
      end

      class << self
        def messages state = nil
          self.create state: state
        end
      end

      delegate :property, :initiator, :replier, :receiver, :type, :system?, :personal?, to: :conversation

      def to_s
        %Q{
    id:           #{id}
    conversation: #{conversation.id if respond_to? :conversation}

    receiver:     #{receiver.name if receiver}
    state:        #{state}

    messages:     #{messages}
    }
      end
    end
  end
end