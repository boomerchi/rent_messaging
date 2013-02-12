require 'spec_helper'

describe Talk::System::Dialog do
  subject { dialog }

  let(:tenant_dialog)   { create :system_dialog, conversation: tenant_conversation }
  let(:landlord_dialog) { create :system_dialog, conversation: landlord_conversation }  

  let(:tenant_conversation)   { create :system_tenant_conversation }
  let(:landlord_conversation) { create :system_landlord_conversation }

  context 'System -> Tenant dialog' do
    let(:dialog)       { tenant_dialog }
    let(:conversation) { tenant_conversation }

    before do
      conversation.dialogs << dialog
    end

    describe 'type' do
      its(:type) { should == 'tenant' }
    end  

    describe 'state' do
      context 'Info (default for system)' do
        its(:state) { should == 'info' }
      end

      context 'Warning' do
        before do
          subject.state = 'warning'
        end

        its(:state) { should == 'warning' }
      end

      context 'Error' do
        before do
          subject.state = 'error'
        end

        its(:state) { should == 'error' }
      end

      context 'Invalid property thread states' do      
        describe 'rejected' do
          before do
            subject.state = 'rejected'
          end

          its(:valid?) { should_not be_true }
        end

        describe 'interested' do
          before do
            subject.state = 'interested'
          end

          its(:valid?) { should_not be_true }
        end
      end
    end 

    context 'With messages' do
      before do
        subject.messages.create subject: 'hi'
      end

      describe 'messages' do
        its(:messages) { should_not be_empty }

        specify { subject.messages.first.should be_a Talk::Message }
      end
    end
  
    context 'No messages' do
      describe 'messages' do
        its(:messages) { should be_empty }
      end
    end
  end
end
