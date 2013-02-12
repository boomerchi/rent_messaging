module Talk
  class Conversation
    include BasicDocument

    def self.dialog_class
      ::Talk::Dialog.to_s
    end

    # has_many :dialogs, class_name: dialog_class
    has_many :dialogs, class_name: 'Talk::Dialog'

    field :type, type: String

    alias_method :threads, :dialogs

    def to_s
      %Q{
  class:  #{self.class}
  id:     #{id}
  dialogs: 
  #{dialogs.join("\n")}
  }
    end
  end
end