require 'spec_helper'

describe Talk::System::Conversation do
  subject { conversation }

  let(:conversation) { create :system_conversation }
  let(:dialog)       { create :system_dialog, conversation: conversation }

  let(:clazz) { Talk::System::Conversation }

  its(:valid?) { should be_true }

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
      conversation.add_dialog(dialog)
    end

    describe 'threads and dialogs' do
      its(:threads) { should_not be_empty }
      its(:dialogs) { should_not be_empty }
      specify { conversation.threads.first.should be_a Talk::System::Dialog }
    end
  end

  describe 'initiator' do
    it 'should be the system' do
      expect(subject.initiator).to eq Account::System.instance
    end
  end

  describe 'add_dialog type' do
    subject { conversation.dialogs.first }

    before do
      conversation.add_dialog :info
    end

    its(:valid?) { should be_true }
    its(:state) { should == 'info' }
    its(:type) { should == 'system' }

    context 'invalid state' do
      subject { conversation.dialogs.first }

      before do
        conversation.clear_dialogs!
        conversation.add_dialog :system
        # puts conversation.dialogs.inspect
      end

      # its(:valid?)  { should be_false }
      # its(:state)   { should == 'system' }

      its(:valid?)  { should be_true }
      its(:state)   { should == 'info' }
      its(:type)    { should == 'system' }
    end
  end

  describe 'initiated_by? type' do
    specify { subject.initiated_by?(:system).should be_true }
  end

  describe 'replier' do
    its(:replier) { should be_nil }
  end

  describe 'receiver' do
    its(:receiver) { should be_an Account::Tenant }
  end

  describe 'account' do
    its(:account) { should be_an Account::Tenant }
  end

  context 'tenant Conversation' do
    let(:tenant) { create :tenant_account }

    describe 'constructors' do
      describe 'conversation account' do
        let(:conversation) do
          clazz.conversation_with tenant
        end

        it 'should set the account to tenant' do
          expect(subject.account).to eq tenant
        end
      end
    end

    describe 'counting dialogs' do      
      before do
        @conversation    = clazz.conversation_with tenant
        @conversation.add_dialog :info
      end

      describe 'read_dialogs_by' do
        it 'should not be read' do
          expect(@conversation.read_dialogs_by :tenant).to eq []
        end
      end

      describe 'read_dialogs_count' do
        it 'should not be read' do
          expect(@conversation.read_dialogs_count :tenant).to eq 0
        end
      end

      describe 'unread_dialogs_by' do
        it 'should not be unread' do
          expect(@conversation.unread_dialogs_by :tenant).to_not be_empty
        end
      end

      describe 'unread_dialogs_count' do
        it 'should not be unread' do
          expect(@conversation.unread_dialogs_count :tenant).to eq 1
        end
      end
    end  
  end
end