require 'spec_helper'

describe Talk::Api::Landlord do
  subject { landlord }

  let(:landlord)  { create :landlord_w_property }
  let(:tenant)    { create :tenant }  
  let(:system)    { Account::System.instance }    
  let(:property)  { landlord.property }  

  its(:conversations) { should be_empty }

  describe 'unread dialogs' do
    context 'landlord has conversation' do
      context 'with tenant' do
        let(:receiver) { tenant }

        context 'Empty conversation' do
          it 'should have empty conversation' do
            pending 'TODO'
            # expect(subject.conversation_with receiver).to be_empty
          end
        end

        context 'about property' do
          context 'tenant has initiated dialog' do
            before do
              # tenant initiates
              receiver.write('starting').to(subject).about(property).send_it!
            end

            describe 'sender type transformers' do
              describe'reverse' do
                it 'should reverse :tenant into :landlord' do
                  expect(subject.conversation_with(receiver).dialogs.first.reverse :tenant).to eq :landlord
                end

                it 'should reverse :landlord into :tenant' do
                  expect(subject.conversation_with(receiver).dialogs.first.reverse :landlord).to eq :tenant
                end
              end

              describe'normalized' do
                it 'should normalized tenant account into :tenant' do
                  expect(subject.conversation_with(receiver).dialogs.first.normalized(receiver)).to eq :tenant
                end

                it 'should normalized landlord account into :landlord' do
                  expect(subject.conversation_with(receiver).dialogs.first.normalized(subject)).to eq :landlord
                end
              end
            end

            it 'should have empty conversation' do
              expect(subject.conversation_with receiver).to_not be_empty
            end

            it 'not all dialogs should have been read' do
              expect(subject.conversation_with(receiver).all_read_by? :landlord).to be_false
            end

            it 'should have some unread dialogs' do
              expect(subject.conversation_with(receiver).any_unread_by? :landlord).to be_true
            end

            it 'should have unread dialogs' do
              expect(subject.conversation_with(receiver).unread_dialogs_by :landlord).to_not be_empty
            end

            it 'should have exactly 1 unread dialog' do
              expect(subject.conversation_with(receiver).unread_dialogs_count_for(subject)).to eq 1
            end

            it 'should not have any read dialogs' do
              expect(subject.conversation_with(receiver).read_dialogs_by :landlord).to be_empty
            end

            it 'should have 0 read dialogs' do
              expect(subject.conversation_with(receiver).read_dialogs_count_for :landlord).to eq 0
            end            

            context 'and tenant reads it' do
              before do
                 subject.conversation_with(receiver).read_all_dialogs!(:landlord)
              end

              it 'should have no unread dialogs' do                
                expect(subject.conversation_with(receiver).unread_dialogs_by :landlord).to be_empty                
              end   

              it 'should have 1 read dialogs' do
                expect(subject.conversation_with(receiver).read_dialogs_count_for :landlord).to eq 1
              end                         
            end

            context 'and landlord has replied' do
              before do
                subject.write('hello you').to(receiver).about(property).send_it!            
              end

              it 'should have no unread dialogs' do
                expect(subject.conversation_with(receiver).unread_dialogs_by :landlord).to be_empty                
              end

              it 'should have 1 read dialogs' do
                expect(subject.conversation_with(receiver).read_dialogs_count_for :landlord).to eq 1
              end
            end
          end
        end
      end
    end
  end
end