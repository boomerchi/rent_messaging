module Talk
  module Property
    class Dialog < ::Talk::Dialog
      include BasicDocument

      def self.message_class
        Talk::Property::Message
      end      

      field :state, type: String

      # valid states depends on type of conversation 
      # - personal or system    
      validates :state, property_dialog_state: true

      belongs_to :conversation, class_name: 'Talk::Property::Conversation'

      embeds_many :messages, class_name: message_class.to_s, inverse_of: :dialog

      scope :latest, -> { desc(:created_at) }
      scope :oldest, -> { asc(:created_at)  } 

      before_validation do
        if self.state.nil?
          self.state = system? ? :info : :interested
        end
      end

      def add_message sender_type, message
        msg = new_message(sender_type, message)
        # puts "add prop msg: #{msg.inspect} - dialog: #{msg.dialog.inspect}"
        self.messages << msg
        super # validate added msg

        # alternative way!
        # args = message_class.msg_args_from(normalized(sender_type), message, self)
        # puts "add and create msg: #{args}"
        # self.messages.create args

        self.save!
      end

      def new_message sender_type, message
        message_class.from normalized(sender_type), message, self
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