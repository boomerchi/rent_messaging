require 'spec_helper'

describe Talk::Conversation do
  subject { conversation }

  let(:dialog) { create :dialog, conversation: conversation }

  let(:conversation)  { create :conversation }
  let(:message)       { create :message, dialog: dialog }

  before do
    conversation.dialogs << dialog
  end

  describe 'dialogs' do
    specify { subject.dialogs.size.should > 0 }

    describe 'threads (alias)' do
      specify { subject.threads.size.should > 0 }      
    end
  end
end