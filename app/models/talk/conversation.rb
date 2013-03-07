module Talk
  class Conversation
    include BasicDocument
    include Talk::Validation

    class InitiationError < StandardError; end
    class GeneralMessageError < StandardError; end
    class NotFoundError < StandardError; end
    class ReceiverError < StandardError; end
    class SenderError < StandardError; end

    def self.dialog_class
      ::Talk::Dialog.to_s
    end

    # has_many :dialogs, class_name: dialog_class
    has_many :dialogs, class_name: 'Talk::Dialog'

    field :type, type: String

    alias_method :threads, :dialogs

    #  no dialogs or messages
    def empty?
      dialogs.empty? || dialogs.first.empty?
    end

    def all_read_by? sender_type
      !read_dialogs_by(sender_type).empty?
    end

    def any_unread_by? sender_type
      !unread_dialogs_by(sender_type).empty?
    end

    def read_all_dialogs! sender_type
      unread_dialogs_by(sender_type).each{|dialog| dialog.read_by! sender_type }
    end

    def read_dialogs_by sender_type
      dialogs.select {|dialog| dialog.read_by? sender_type }
    end
    alias_method :read_dialogs,           :read_dialogs_by
    alias_method :read_dialogs_for,       :read_dialogs_by

    def unread_dialogs_by sender_type
      dialogs.select {|dialog| dialog.unread_by? sender_type }
    end
    alias_method :unread_dialogs,         :unread_dialogs_by
    alias_method :unread_dialogs_for,     :unread_dialogs_by

    # cache later
    def unread_dialogs_count_for sender_type
      unread_dialogs_by(sender_type).count
    end
    alias_method :unread_dialogs_count,   :unread_dialogs_count_for

    def read_dialogs_count_for sender_type
      read_dialogs_by(sender_type).count
    end
    alias_method :read_dialogs_count,     :read_dialogs_count_for

    def dialog
      dialogs.last
    end

    def current_dialog
      dialog
    end

    def as_string
    end

    def to_str
      %Q{
  class:  #{self.class}
  id:     #{id}
  #{as_string}

  dialogs: 
  #{dialogs.join("\n")}
  }
    end
  end
end