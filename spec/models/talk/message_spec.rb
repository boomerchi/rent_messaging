require 'spec_helper'

describe Talk::Message do
  subject { message }

  let(:message) { create :message, dialog: dialog }
  let(:dialog)  { create :dialog }

  # before do
  #   puts subject.inspect
  # end

  describe 'subject' do
    its(:subject) { should_not be_empty }
    its(:subject) { should == 'hello' }
  end

  describe 'body' do
    its(:body) { should_not be_empty }
    its(:body) { should == 'hi' }    
  end

  describe 'state' do
    its(:state) { should == 'info' }
  end

  describe 'dialog' do
    its(:dialog) { should be_a Talk::Dialog }

    describe 'thread (alias)' do
      its(:thread) { should be_a Talk::Dialog }
    end
  end
end
