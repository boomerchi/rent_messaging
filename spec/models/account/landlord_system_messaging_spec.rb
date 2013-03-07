require 'spec_helper'

describe User::Account::Landlord do
  describe User::Account::Landlord::Messaging do
    context 'System messages' do
      subject { landlord }

      let(:landlord)  { create :landlord_w_property }
      let(:system)    { Account::System.instance }    

      its(:conversations) { should be_empty }

      let(:receiver) { landlord }

      describe 'write' do
        it 'landlord can NOT initiate general message dialog to system' do
          expect { subject.write('hello').to(system) }.to raise_error(Talk::Conversation::ReceiverError)
        end

        context 'who has no previous conversation' do
          it 'has a conversation with the landlord' do
            system.conversations_with(receiver).should be_empty
          end
        end

        context 'system has sent general message to landlord' do
          before do
            # contract type?
            system.write('contract aid').to(landlord).send_it!              
          end

          it 'should create system conv' do
            expect(system.write('contract aid').to(landlord).system_conversation).to be_a Talk::System::Conversation
          end

          it 'should create system conv with landlord' do
            expect(system.write('contract aid').to(landlord).system_conversation.account).to eq landlord
          end

          it 'should create system dialog' do
            expect(system.write('contract aid').to(landlord).system_dialog).to be_a Talk::System::Dialog
          end

          it 'should create system dialog with landlord' do
            expect(system.write('contract aid').to(landlord).system_dialog.receiver).to eq landlord
          end

          it 'should create a system dialog with a message' do
            expect(subject.conversation_for(:system).dialogs.first.messages).to_not be_empty
          end

          context 'landlord' do
            it 'should have system conversations' do
              expect(subject.conversations_for :system).to_not be_empty              
            end

            it 'should have exactly 1 system conversation' do
              expect(subject.conversations_for(:system).count).to eq 1
            end

            it 'should have 0 unread property dialogs' do
              expect(subject.total_unread_property_dialogs).to eq 0
            end            

            it 'should have 1 unread dialogs' do
              expect(subject.total_unread_dialogs).to eq 1
            end            

            it 'should have 1 unread :system dialogs' do
              expect(subject.total_unread_dialogs :system).to eq 1
            end

            context '2 more system messages' do
              before do
                # contract type?
                system.write('more contract aid').to(landlord).send_it!
                system.write('bonus').to(landlord).send_it!
              end

              it 'first system dialog should have 3 messages' do
                # puts "dialogs: #{subject.conversation_for(:system).dialogs.inspect}"
                # puts "dialog: #{subject.conversation_for(:system).dialogs.first.inspect}"
                # puts "messages: #{subject.conversation_for(:system).dialogs.first.messages.inspect}"
                expect(subject.conversation_for(:system).dialogs.first.messages.count).to eq 3
              end

              it 'should have system conversations' do
                expect(subject.conversations_for :system).to_not be_empty              
              end

              it 'should have exactly 1 system conversation' do
                expect(subject.conversations_for(:system).count).to eq 1
              end

              it 'should have 1 unread dialogs' do
                expect(subject.total_unread_dialogs).to eq 1
              end            

              it 'should have 1 unread :system dialogs' do
                expect(subject.total_unread_dialogs :system).to eq 1
              end

              it 'should have 3 unread unread_system_messages' do
                expect(subject.unread_system_messages).to eq 3
              end

              context 'and property messages' do
                let(:property) { landlord.property }

                before do
                  system.write('remove bad picture').to(landlord).about(property).send_it!
                end

                it 'should have 1 unread :system dialogs' do
                  expect(subject.total_unread_dialogs :system).to eq 1
                end                

                it 'should have 1 unread :property dialogs' do
                  expect(subject.total_unread_dialogs :system).to eq 1
                end                

                it 'should have 2 unread dialogs' do
                  expect(subject.total_unread_dialogs).to eq 2
                end
              end
            end
          end
        end
      end
    end
  end        
end