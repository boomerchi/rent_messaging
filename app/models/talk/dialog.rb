module Talk
  class Dialog
    include BasicDocument

    def self.default_state
      ''
    end

    def self.message_class
      'Talk::Message'
    end
    
    belongs_to :conversation, class_name: 'Talk::Conversation'
    embeds_many :messages, as: :msg_dialog

    field :spam,  type: Boolean, default: false
    field :state, type: String, default: default_state
    field :type,  type: String, default: ''

    embeds_many :messages, class_name: message_class, as: :msg_dialog

    # returns the :system symbol if thread not owned (initiated) by a tenant
    def initiator
      raise NotImplementedError, "Must be implemented by subclass"
    end

    def spam!
      self.spam = true
    end

    alias_method :spam?, :spam

    def to_s
      %Q{
  id:           #{id}
  conversation: #{conversation.id if respond_to? :conversation}
  type:         #{type}
  state:        #{state}
  messages:     #{messages}
  }
    end
  end
end