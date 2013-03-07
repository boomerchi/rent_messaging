require 'spec_helper'

describe User::Account::Landlord do
  describe User::Account::Landlord::Messaging do
    subject { landlord }

    let(:landlord)  { create :landlord_w_property, property_count: 3 }
    let(:tenant)    { create :tenant }  
    let(:system)    { Account::System.instance }    
    let(:property)  { landlord.properties[0] }  
    let(:property1)  { landlord.properties[1] }  
    let(:property2)  { landlord.properties[2] }

    its(:conversations) { should be_empty }

    describe 'write' do
      context 'to tenant' do
        let(:receiver) { tenant }

        it 'can initiate writing' do
          expect { subject.write('hello').to(receiver) }.to raise_error(Talk::Conversation::InitiationError)
        end

        context 'who has no previous conversation' do
          it 'has a conversation with the landlord' do
            subject.conversations_with(receiver).should be_empty
          end

          context 'about property' do
            before do
              # tenant initiates dialog (1)
              receiver.write('starting').to(subject).about(property).send_it!
              receiver.write('starting').to(subject).about(property).send_it!

              system.write('contract aid').to(subject).about(property).send_it!              
            end

            it 'should have 2 unread property dialogs' do
              expect(subject.total_unread_property_dialogs).to eq 2
            end            

            it 'should have 2 unread dialogs' do
              expect(subject.total_unread_all_dialogs).to eq 2
            end            

            it 'should have 2 unread :all dialogs' do
              expect(subject.total_unread_dialogs :all).to eq 2
            end            

            it 'should have 2 unread :property dialogs' do
              expect(subject.total_unread_dialogs :property).to eq 2
            end            

            it 'should have 0 unread :system dialogs' do
              expect(subject.total_unread_dialogs :system).to eq 0
            end            
          end
        end
      end
    end
  end
end