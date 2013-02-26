require 'spec_helper'

describe Talk::Api::Landlord do
  subject { landlord }

  let(:landlord)  { create :landlord_w_property }
  let(:tenant)    { create :tenant }  
  let(:system)    { Account::System.instance }    
  let(:property)  { landlord.property }  

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
            # tenant initiates
            receiver.write('starting').to(subject).about(property).send_it!

            # convs = Talk::Property::Conversation.between(subject, receiver).first

            # reply
            subject.write('hello you').to(receiver).about(property).send_it!            
          end

          it 'can NOT write general message' do
            expect { subject.write('hello').to(receiver).send_it! }.to raise_error(Talk::Conversation::GeneralMessageError)
          end

          describe 'conversation_with' do
            before do
              @conversation = subject.conversation_with receiver
            end

            it 'should return a single conversation' do
              expect(@conversation).to be_a Talk::Property::Conversation
            end

            it 'originally from tenant' do
              expect(@conversation.initiator).to eq tenant
            end

            it 'to me the landlord' do
              expect(@conversation.receiver).to eq landlord
            end

            it 'about property' do
              expect(@conversation.property).to eq property
            end

            describe 'current_dialog' do
              before do
                @dialog = subject.conversation_with(receiver).current_dialog
              end

              it 'has a dialog' do                
                expect(@dialog).to be_a Talk::Property::Dialog
              end

              it 'of conversation' do                
                expect(@dialog.conversation).to eq @conversation
              end

              describe 'messages' do
                it 'adds the message to the latest conversation with the tenant' do
                  expect(@dialog.messages).to_not be_empty
                end

                describe 'last message' do
                  it 'has added the message as the last message' do
                    expect(@dialog.messages.last.body).to eq 'hello you'
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end