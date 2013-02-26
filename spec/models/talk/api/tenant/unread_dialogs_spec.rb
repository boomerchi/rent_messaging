require 'spec_helper'

describe Talk::Api::Landlord do
  subject { tenant }

  let(:landlord)  { create :landlord_w_property }
  let(:tenant)    { create :tenant }  
  let(:system)    { Account::System.instance }    
  let(:property)  { landlord.property }  

  its(:conversations) { should be_empty }

  describe 'unread dialogs' do
    context 'tenant has conversation' do
      context 'with landlord' do
        let(:receiver) { landlord }

        context 'about property' do
          context 'tenant has initiated dialog' do
            before do
              # tenant initiates
              subject.write('question').to(receiver).about(property).send_it!

              # landlord replies
              receiver.write('answer').to(subject).about(property).send_it!
            end

            context 'tenant' do
              it 'should have empty conversation' do
                expect(subject.conversation_with receiver).to_not be_empty
              end

              it 'not all dialogs should have been read' do
                expect(subject.conversation_with(receiver).all_read_by? :tenant).to be_false
              end

              it 'should have some unread dialogs' do
                expect(subject.conversation_with(receiver).any_unread_by? :tenant).to be_true
              end

              it 'should have unread dialogs' do
                expect(subject.conversation_with(receiver).unread_dialogs_by :tenant).to_not be_empty
              end

              it 'should have exactly 1 unread dialog' do
                expect(subject.conversation_with(receiver).unread_dialogs_count_for(subject)).to eq 1
              end

              it 'should have 0 read dialogs' do
                expect(subject.conversation_with(receiver).read_dialogs_count_for :tenant).to eq 0
              end
            end

            context 'landlord' do
              describe 'my property conversations should be' do                
                it "with me" do
                  subject.property_conversations.each do |conv|
                    expect(conv.tenant).to eq subject
                  end
                end

                it "about property" do
                  subject.property_conversations.each do |conv|
                    expect(conv.property).to eq property
                  end
                end
              end

              describe 'conversation should be' do
                it 'between landlord and me' do
                  expect(subject.conversation_with(receiver).landlord).to eq landlord
                end

                it 'and me' do
                  expect(subject.conversation_with(receiver).tenant).to eq subject
                end
              end

              it 'should have no unread dialogs' do
                expect(subject.conversation_with(receiver).unread_dialogs_by :landlord).to be_empty
              end

              it 'should have exactly 1 read dialog' do
                expect(subject.conversation_with(receiver).read_dialogs_count_for :landlord).to eq 1
              end
            end

            context 'and tenant writes again (has replied)' do
              before do
                subject.write('reply').to(receiver).about(property).send_it!
              end

              it 'tenant should have no unread dialogs' do
                expect(subject.conversation_with(receiver).unread_dialogs_by :tenant).to be_empty
              end

              context 'landlord' do
                it 'should have unread dialogs' do
                  expect(subject.conversation_with(receiver).unread_dialogs_by :landlord).to_not be_empty
                end

                it 'should have exactly 1 unread dialog' do
                  expect(subject.conversation_with(receiver).unread_dialogs_count_for :landlord).to eq 1
                end
              end
            end
          end
        end
      end
    end
  end
end