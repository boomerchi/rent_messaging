require 'spec_helper'

describe Talk do
  describe 'Property Message' do
    subject { message }

    let(:message)       { create :property_message, dialog: dialog }
    let(:dialog)        { create :property_dialog, conversation: conversation }
    let(:conversation)  { create :property_conversation, landlord: property.landlord }
    let(:property)      { create :valid_property }

    describe 'dialog' do
      its(:dialog) { should be_a Talk::Property::Dialog }

      it 'should have a dialog' do
        expect(subject.dialog).to eq dialog
      end
    end

    describe 'conversation' do
      its(:conversation) { should be_a Talk::Property::Conversation }

      it 'should have a conversation' do
        expect(subject.conversation).to eq conversation
      end
    end

    describe 'property' do
      its(:property) { should be_a Property }
    end

    describe 'spam!' do
      context 'not marked as spam' do
        it 'should not be spam' do
          expect(subject.spam?).to be_false
        end
      end

      context 'marked as spam' do
        before do
          subject.spam!
        end

        it 'should be spam' do
          expect(subject.spam?).to be_true
        end
      end
    end

    describe 'it should have' do
      it 'state info' do
        expect(subject.state).to eq 'info'
      end

      it 'type personal' do
        expect(subject.type).to eq 'personal'
      end
    end
  end
end