require 'spec_helper'

describe Talk::Api::Landlord do
  subject { landlord }

  let(:landlord)  { create :landlord }
  let(:tenant)    { create :tenant }  

  its(:conversations) { should be_empty }

  describe 'write' do
    context 'to tenant' do
      let(:receiver) { tenant }

      it 'can NOT initiate writing to tenant' do
        expect { subject.write('hello').to(receiver)  }.to raise_error(Talk::Conversation::InitiationError)
      end

      context 'who has previously initiated a conversation' do
        it 'has a conversation with the tenant' do
          subject.conversations_with(receiver).should_not be_empty }
        end

        it 'can NOT write general message' do
          expect { subject.write('hello').to(receiver) }.to raise_error(Talk::Conversation::GeneralMessageError)
        end

        context 'about property' do
          before do
            landlord.write('hello you').to(receiver).about(property).send
          end

          it 'adds the message to the latest conversation with the tenant' do
            subject.conversations_with(receiver).dialog.messages.last.body.should == 'hello you' }
          end
        end
      end
    end
  end
end