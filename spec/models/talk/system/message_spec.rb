require 'spec_helper'

describe Talk do
  describe 'System Message' do
    subject { message }

    let(:message)       { create :message, thread: thread }
    let(:thread)        { create :thread, conversation: conversation }
    let(:conversation)  { create :conversation, type: 'system' }

    describe 'thread' do
      its(:thread) { should be_a Talk::Message::Dialog }
      its(:thread) { should == thread }
    end

    describe 'conversation' do
      its(:conversation) { should be_a Talk::Property::Conversation }
      its(:conversation) { should == conversation }

      describe 'type' do
        specify { subject.conversation.type.should == 'system' }
      end  
    end

    describe 'property' do
      its(:property) { should be_nil }
    end
  end
end