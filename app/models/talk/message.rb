# encoding: utf-8

module Talk
  class Message
    include BasicDocument
    include Validation

    def self.thread_class
      ::Message::Dialog.to_s
    end

    def self.valid_states
      %w{info spam}
    end

    field :subject, type: String, default: 'no subject'
    field :body,    type: String
    field :state,   type: String, default: 'info'

    validates :state, presence: true, inclusion:  {in: Talk::Message.valid_states }

    # trigger state machine!
    def spam!
      self.state = 'spam'
      self
    end

    def spam?
      self.state == 'spam'
    end

    def to_s
      %Q{
  subject: #{subject}
  body:    #{body}
  state:   #{state}
  }
    end
  end
end