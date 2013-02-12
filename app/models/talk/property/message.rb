module Talk
  module Property
    class Message < Talk::Message
      embedded_in :dialog, class_name: 'Talk::Property::Dialog', inverse_of: :messages

      alias_method :property_dialog, :dialog
      alias_method :thread, :dialog
      # alias_method :thread=, :dialog=

      delegate :type, :conversation,  to: :property_dialog
      delegate :property,             to: :property_dialog      
    end
  end
end

