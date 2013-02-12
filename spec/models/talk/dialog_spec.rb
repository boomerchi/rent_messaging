require 'spec_helper'

describe Talk::Dialog do
  subject { dialog }

  let(:dialog)        { create :dialog, conversation: conversation }
  let(:message)       { create :message, dialog: dialog }
  let(:conversation)  { create :conversation }

  before do
    conversation.dialogs << dialog
  end

  describe 'spam' do
    context 'default - not spam' do
      its(:spam?) { should_not be_true }
    end

    context 'marked as spam' do
      before do
        subject.spam!
      end

      its(:spam?) { should be_true }
    end
  end

  describe 'type' do
    context 'default' do
      its(:type) { should == 'msg' }
    end

    context 'mark as info' do
      before do
        subject.type = 'info'
      end

      its(:type) { should == 'info' }
    end    
  end

  describe 'state' do
    context 'default' do
      its(:state) { should == '' }
    end

    context 'mark as info' do
      before do
        subject.state = 'info'
      end

      its(:state) { should == 'info' }
    end
  end

  context 'With messages' do
    before do
      subject.messages << message
    end

    describe 'messages' do
      its(:messages) { should_not be_empty }
      specify { subject.messages.first.should == message }
    end
  end

  context 'No messages' do
    describe 'messages' do
      its(:messages) { should be_empty }
    end
  end
end
