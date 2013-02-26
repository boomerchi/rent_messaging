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
    embeds_many :messages, class_name: message_class, as: :msg_dialog

    field :spam,  type: Boolean,    default: false
    field :state, type: String,     default: default_state
    field :type,  type: String,     default: ''
    
    field :initiator_read,     type: Boolean,    default: false
    field :receiver_read,      type: Boolean,    default: false

    def system_read= value
      raise "System is not part of this conversation" if initiator.type != 'system'
      self.initiator_read = value
    end

    def read_attribute_for type
      self.initiator.type.to_sym == type.to_sym ? :initiator : :receiver
    end

    def set_read_for type, value
      self.send("#{read_attribute_for type}_read=", value)
    end

    def get_read_for type
      self.send "#{read_attribute_for type}_read"
    end

    def landlord_read= value
      set_read_for :landlord, value
    end 

    def tenant_read= value
      set_read_for :tenant, value
    end 

    def system_read
      raise "System is not part of this conversation" if initiator.type != 'system'
      self.initiator_read
    end 

    def landlord_read
      get_read_for :landlord
    end 

    def tenant_read
      get_read_for :tenant      
    end 

    # if you write a new message, you are assumed to have read the thread
    def write sender_type, message        
      read! normalized(sender_type)
      unread! normalized(reverse sender_type)
      add_message sender_type, message
    end

    def add_message sender_type, message
      self.messages << new_message(sender_type, message)
      self.save!       
    end

    def new_message sender_type, message
      Talk::Property::Message.from normalized(sender_type), message, self
    end

    def empty?
      messages.blank?
    end

    def reverse sender_type
      normalized(sender_type) == initiator.type.to_sym ? receiver.type.to_sym : initiator.type.to_sym
    end
    alias_method :reversed, :reverse

    def normalize sender_type
      type = sender_type.kind_of?(Account::Base) ? sender_type.type : sender_type
      raise "Invalid sender type" unless [:tenant, :landlord, :system].include? type.to_sym
      type.to_sym
    rescue
      raise ArgumentError, "Not a valid type of sender: #{sender_type.inspect}, must be an Account::Base, String or Symbol"
    end
    alias_method :normalized, :normalize


    def read! sender_type
      set_read_for normalized(sender_type), true
      self.save!
    end
    alias_method :read_by!, :read!

    def unread! sender_type 
      set_read_for normalized(sender_type), false
      self.save!
    end
    alias_method :unread_by!, :unread!
    
    def read_by? sender_type
      self.send("#{normalized sender_type}_read")
    end
    alias_method :read_for?, :read_by?

    def unread_by? sender_type
      !read_by? sender_type
    end
    alias_method :unread_for?, :unread_by?

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