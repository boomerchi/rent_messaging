require 'spec_helper'

describe Talk::Property::Dialog do
  subject { dialog }

  let(:conversation)  { create :system_property_tenant_conversation, property: property }
  let(:property)      { create :valid_property }
  let(:message)       { create :property_message, dialog: dialog }

  let(:initiator)     { conversation.system }
  let(:replier)       { nil }
  let(:receiver)      { conversation.tenant }

  context 'System -> Tenant' do    
    let(:dialog) { create :valid_property_dialog, conversation: conversation, message_count: 2 }

    describe 'type' do
      its(:type) { should == 'system' }
    end  

    describe 'conversation' do
      its(:conversation) { should be_a Talk::Property::Conversation }

      it 'should have it' do
        expect(subject.conversation).to eq conversation
      end
    end     

    describe 'initiator' do
      it 'should have it' do
        expect(subject.initiator).to eq initiator
      end
    end

    describe 'replier' do
      it 'should not have it' do
        expect(subject.replier).to eq nil
      end
    end

    describe 'receiver' do
      it 'should have it' do
        expect(subject.receiver).to eq receiver
      end
    end

    describe 'system?' do
      it 'should not be' do
        expect(subject.system?).to be_true
      end
    end

    describe 'personal?' do
      it 'should not be' do
        expect(subject.personal?).to_not be_true
      end
    end

    describe 'state' do
      context 'Info (default for system)' do
        its(:state) { should == 'info' }
      end

      context 'Warning' do
        let(:dialog) { create :property_warning_dialog, conversation: conversation }

        its(:state) { should == 'warning' }
      end

      context 'Error' do
        # let(:dialog) { create :error_dialog, conversation: conversation }
        let(:dialog) { create :property_dialog, state: 'error', conversation: conversation }

        its(:state) { should == 'error' }
      end

      context 'Invalid property thread states' do      
        describe 'rejected' do
          it 'should not be allowed' do
            expect { create :property_dialog, state: 'rejected', conversation: conversation }
          end            
        end

        describe 'interested' do
          it 'should not be allowed' do
            expect { create :property_dialog, state: 'interested', conversation: conversation }
          end
        end
      end
    end 

    context 'With messages' do
      before do
        subject.messages << message
      end

      describe 'messages' do
        its(:messages) { should_not be_empty }

        it 'should add the message' do
          expect(subject.messages.last).to eq message
        end
      end
    end
  
    context 'No messages' do
      before do
        subject.messages = []
      end

      describe 'messages' do
        its(:messages) { should be_empty }

        it 'should not have a message' do
          expect(subject.messages.last).to eq nil
        end
      end
    end
  end
end
