module Talk
  module Messaging
    extend ActiveSupport::Concern

    included do
      embedded_in :msg_dialog, polymorphic: true

      delegate :type, :conversation, to: :msg_dialog

      alias_method :dialog, :msg_dialog
      alias_method :dialog=, :msg_dialog=

      alias_method :thread, :dialog
      alias_method :thread=, :dialog=
    end
  end
end