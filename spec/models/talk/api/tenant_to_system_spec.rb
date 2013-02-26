require 'spec_helper'

describe Talk::Api::Tenant do
  subject { tenant }

  let(:tenant)    { create :tenant }  
  let(:system)    { Account::System.instance }    
  let(:property)  { create :valid_property }  

  its(:conversations) { should be_empty }

  describe 'write' do
    context 'to system' do
      let(:receiver) { system }

      context 'who has no previous conversation' do
        it 'has a conversation with the landlord' do
          subject.conversations_with(receiver).should be_empty
        end

        it 'landlord can NOT write message' do
          expect { subject.write('hello').to(receiver).send_it! }.to raise_error(ArgumentError)
        end

        context 'system initiated conversation' do
          before do
            # tenant initiates
            receiver.write('starting').to(subject).about(property).send_it!
          end

          it 'landlord can NOT write message' do
            expect { subject.write('hello').to(receiver).send_it! }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end