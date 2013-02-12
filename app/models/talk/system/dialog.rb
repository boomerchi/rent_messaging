module Talk
  module System
    class Dialog < ::Talk::Dialog
      include BasicDocument

      def self.default_state
        'info'
      end

      def self.valid_states
        %w{info warning error'}
      end

      field :state, type: String, default: default_state
      field :type,  type: String, default: 'system'

      # validates :state, system_dialog: true
      validates :state, presence: true, inclusion: {in: valid_states }

      belongs_to :conversation, class_name: 'Talk::System::Conversation'

      class << self
        def about conversation, type = :info
          self.create conversation: conversation, type: type
        end
      end

      # returns the :system symbol if thread not owned (initiated) by a tenant
      def initiator
        :system
      end

      delegate :replier, to: :conversation

      def to_s
        %Q{
    id:           #{id}
    conversation: #{conversation.id if respond_to? :conversation}

    replier:      #{replier.name}
    state:        #{state}

    messages:     #{messages}
    }
      end
    end
  end
end