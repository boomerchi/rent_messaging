require 'spec_helper'

describe Talk::Api::System do
  subject { system }

  let(:landlord)  { create :landlord_w_property }

  let(:system)    { Account::System.instance }    
  let(:property)  { landlord.property }  

  its(:conversations) { should be_empty }

  describe 'write' do
    context 'to system' do
      let(:receiver) { landlord }

      it 'uses a System messenger' do      
        expect(subject.write 'hello').to be_a Talk::Api::System::Messenger
      end

      it 'can initiate writing' do
        expect { subject.write('hello').to(receiver) }.to_not raise_error(Talk::Conversation::InitiationError)
      end

      it 'uses a System Conversator' do
        expect(subject.write('hello').to(receiver)).to be_a Talk::Api::System::Conversator
      end

      it 'uses a System Property Conversator' do
        expect(subject.write('hello').to(receiver).about(property)).to be_a Talk::Api::System::PropertyConversator
      end

      context 'and there is a previous conversation' do
        it 'returns and adds to the previous conversation with the landlord' do
          subject.conversations_with(receiver).should be_empty
        end
      end

      context 'who has no previous conversation' do
        it 'has a conversation with the landlord' do
          subject.conversations_with(receiver).should be_empty
        end

        context 'Sending general message' do
          it 'can write general message' do
            expect { subject.write('hello').to(receiver).send_it! }.to_not raise_error(Talk::Conversation::GeneralMessageError)
          end

          it 'creates the message in the general system messages' do
            pending 'todo'
          end
        end

        context 'about property' do
          before do
            subject.write('hello you').to(receiver).about(property).send_it!
          end

          describe 'conversation_with' do
            before do
              @conversation = subject.conversation_with receiver
            end

            it 'should be valid' do
              expect(@conversation).to be_valid
            end

            it 'should return a single conversation' do
              expect(@conversation).to be_a Talk::Property::Conversation
            end

            it 'originally from tenant' do
              expect(@conversation.initiator).to eq system
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
                it 'adds the message to the latest conversation with the landlord' do
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