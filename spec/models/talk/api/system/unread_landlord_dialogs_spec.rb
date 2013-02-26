require 'spec_helper'

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

            it 'should have system initiator' do
              expect(@conversation.initiator).to eq subject
            end

            it 'should not have replier (since never allowed to reply system)' do
              expect(@conversation.replier).to eq nil
            end

            it 'should have landlord receiver' do
              expect(@conversation.receiver).to eq receiver
            end

            describe 'sender type transformers' do
              describe'reverse' do
                it 'should reverse :tenant into :landlord' do
                  expect(subject.conversation_with(receiver).dialogs.first.reverse :system).to eq :landlord
                end
              end

              describe'normalized' do
                it 'should normalized tenant account into :tenant' do
                  expect(subject.conversation_with(receiver).dialogs.first.normalized(subject)).to eq :system
                end

                it 'should normalized landlord account into :landlord' do
                  expect(subject.conversation_with(receiver).dialogs.first.normalized(receiver)).to eq :landlord
                end
              end
            end            

            it 'should not have empty conversation' do
              expect(@conversation).to_not be_empty
            end

            it 'not all dialogs should have been read' do
              expect(@conversation.all_read_by? :landlord).to be_false
            end

            it 'should have some unread dialogs' do
              expect(@conversation.any_unread_by? :landlord).to be_true
            end

            it 'should have unread dialogs' do
              expect(@conversation.unread_dialogs_by :landlord).to_not be_empty
            end

            it 'should have exactly 1 unread dialog' do
              expect(@conversation.unread_dialogs_count_for(receiver)).to eq 1
            end

            context 'system' do
              it 'should have exactly 1 unread dialog' do
                expect(@conversation.unread_dialogs_count_for(subject)).to eq 0
              end
            end

            it 'should not have any read dialogs' do
              expect(@conversation.read_dialogs_by :landlord).to be_empty
            end

            it 'should have 0 read dialogs' do
              expect(@conversation.read_dialogs_count_for :landlord).to eq 0
            end            

            context 'and tenant reads it' do
              before do
                 @conversation.read_all_dialogs!(:landlord)
              end

              it 'should have no unread dialogs' do                
                expect(@conversation.unread_dialogs_by :landlord).to be_empty                
              end   

              it 'should have 1 read dialogs' do
                expect(@conversation.read_dialogs_count_for :landlord).to eq 1
              end                         
            end

            context 'and system has writes again' do
              before do
                subject.write('hello you').to(receiver).about(property).send_it!            
              end

              it 'should have no unread dialogs' do
                expect(@conversation.unread_dialogs_by :system).to be_empty                
              end

              it 'should have 1 read dialogs' do
                expect(@conversation.read_dialogs_count_for :system).to eq 1
              end

              it 'landlord should have 1 unread dialogs' do
                expect(@conversation.unread_dialogs_count_for :landlord).to eq 1
              end                         
            end
          end
        end
      end
    end
  end
end