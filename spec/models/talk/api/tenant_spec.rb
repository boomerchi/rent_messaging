require 'spec_helper'

describe Talk::Api::Tenant do
  subject { tenant }

  let(:landlord)  { create :landlord }
  let(:tenant)    { create :tenant }  

  its(:conversations) { should be_empty }

  describe 'write' do
    context 'to landlord' do
      let(:receiver) { landlord }

      it 'can initiate writing' do
        expect { subject.write('hello').to(receiver)  }.to_not raise_error(Talk::Conversation::InitiationError)
      end

      context 'who has no previous conversation' do
        it 'has a conversation with the landlord' do
          subject.conversations_with(receiver).should be_empty }
        end

        it 'can NOT write general message' do
          expect { subject.write('hello').to(receiver) }.to raise_error(Talk::Conversation::GeneralMessageError)
        end

        context 'about property' do
          before do
            subject.write('hello you').to(receiver).about(property).send
          end

          it 'adds the message to the latest conversation with the tenant' do
            subject.conversations_with(receiver).dialog.messages.last.body.should == 'hello you' }
          end
        end
      end
    end
  end
end