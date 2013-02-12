require 'spec_helper'

describe Talk::System::Conversation do
  subject { conversation }

  let(:conversation) { create :system_conversation }
  let(:dialog)       { create :system_dialog, conversation: conversation }

  let(:clazz) { Talk::System::Conversation }

  describe 'type' do
    its(:type) { should == 'system' }
  end  

  context 'No threads' do
    describe 'threads and dialogs' do
      its(:threads) { should be_empty }
      its(:dialogs) { should be_empty }
    end
  end

  context 'With threads' do
    before do
      subject.add_dialog(dialog)
    end

    describe 'threads and dialogs' do
      its(:threads) { should_not be_empty }
      its(:dialogs) { should_not be_empty }
      specify { subject.threads.first.should be_a Talk::System::Dialog }
    end
  end

  describe 'initiator' do
    its(:initiator) { should == :system }
  end

  describe 'add_dialog type' do
    before do
      subject.add_dialog :info
    end

    specify { subject.dialogs.first.type.should == 'info' }
  end

  describe 'initiated_by? type' do
    specify { subject.initiated_by?(:system).should be_true }
  end

  describe 'replier' do
    its(:replier) { should be_an Account::Tenant }
  end

  describe 'account' do
    its(:account) { should be_an Account::Tenant }
  end

  describe 'constructors' do
    describe 'conversation account' do
      let(:conversation) do
        clazz.conversation tenant
      end

      let(:tenant) { create :tenant_account }

      its(:account) { should == tenant }
    end
  end
end