require 'spec_helper'

describe Talk::Property::Dialog do
  subject { dialog }

  let(:conversation)  { create :property_conversation, property: property }
  let(:property)      { create :valid_property }

  let(:initiator)     { conversation.tenant }
  let(:replier)       { conversation.landlord }  
  let(:receiver)      { conversation.landlord }

  context 'Personal Tenant <-> Landlord' do
    let(:dialog) { create :valid_property_dialog, conversation: conversation, message_count: 2 }

    its(:valid) { should be_true }

    describe 'conversation' do
      its(:conversation) { should be_a Talk::Property::Conversation }

      it 'should have it' do
        expect(subject.conversation).to eq conversation
      end
    end 

    describe 'type' do
      its(:type) { should == 'personal' }
    end 

    describe 'property' do
      it 'should have it' do
        expect(subject.property).to eq property
      end
    end

    describe 'initiator' do
      it 'should have it' do
        expect(subject.initiator).to eq initiator
      end
    end

    describe 'replier' do
      it 'should have it' do
        expect(subject.replier).to eq replier
      end
    end

    describe 'receiver' do
      it 'should have it' do
        expect(subject.receiver).to eq receiver
      end
    end

    describe 'system?' do
      it 'should not be' do
        expect(subject.system?).to_not be_true
      end
    end

    describe 'personal?' do
      it 'should not be' do
        expect(subject.personal?).to be_true
      end
    end

    describe 'state' do
      context 'Interested (default for property)' do
        its(:state) { should == 'interested' }
      end

      context 'Rejected' do
        let(:dialog) { create :rejected_dialog, conversation: conversation }

        its(:state) { should == 'rejected' }
      end

      context 'Invalid system thread states' do      
        describe 'info' do
          it 'should not be valid' do
            expect { create :property_dialog, state: 'info', conversation: conversation }.to raise_error
          end
        end

        describe 'warning' do
          it 'should not be valid' do
            expect { create :property_dialog, state: 'warning', conversation: conversation }.to raise_error
          end
        end

        describe 'error' do
          it 'should not be valid' do
            expect { create :property_dialog, state: 'error', conversation: conversation }.to raise_error
          end
        end
      end      
    end 

    context 'With messages' do
      before do
        subject.messages.create subject: 'blip'
      end

      describe 'messages' do
        its(:messages) { should_not be_empty }

        it 'should add the message' do
          expect(subject.messages.last.subject).to eq 'blip'
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
          expect(subject.messages.first).to eq nil
        end
      end
    end
  end
end
