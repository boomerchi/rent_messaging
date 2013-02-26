require 'spec_helper'

describe Talk::Api::Tenant do
  subject { tenant }

  let(:landlord)  { create :landlord_w_property, property_count: 3 }
  let(:tenant)    { create :tenant }  

  let(:property)    { landlord.properties[0] }
  let(:property1)   { landlord.properties[1] }
  let(:property2)   { landlord.properties[2] }

  let(:landlord_property)    { landlord.property }

  describe 'write' do
    context 'to landlord' do
      let(:receiver) { landlord }

      it 'can initiate writing' do
        expect { subject.write('hello').to(receiver) }.to_not raise_error(Talk::Conversation::InitiationError)
      end

      context 'who has no previous conversation' do
        it 'has a conversation with the landlord' do
          subject.conversations_with(receiver).should be_empty
        end

        it 'can NOT write general message' do
          expect { subject.write('hello').to(receiver).send_it! }.to raise_error(Talk::Conversation::GeneralMessageError)
        end

        context 'about property' do
          before do
            subject.write('hello you').to(receiver).about(property).send_it!
          end

          describe 'conversation_with' do
            before do
              @conversation = subject.property_conversation(property, receiver)
            end

            it 'should return a single conversation' do
              expect(@conversation).to be_a Talk::Property::Conversation
            end

            it 'originally from me the tenant' do
              expect(@conversation.initiator).to eq subject
            end

            it 'to the landlord receiver' do
              expect(@conversation.receiver).to eq receiver
            end

            it 'about property' do
              expect(@conversation.property).to eq landlord_property
            end

            context 'last conversation with landlord' do
              describe 'current_dialog' do
                before do
                  @dialog = subject.conversation_with(receiver, :last).current_dialog
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

      context 'who has a 2 conversations with different landlord properties' do
        before do
          subject.write('hello you').to(receiver).about(property).send_it!
          subject.write('greetings sir').to(receiver).about(property1).send_it!          
        end

        it 'should have 2 conversations with landlord, one for ech property' do
          expect(subject.conversations_with(receiver).count).to eq 2              
        end            

        it 'should have 1 conversations with landlord, about property' do
          expect(subject.property_conversation(property, receiver)).to be_a Talk::Property::Conversation
        end            

        it 'should have 1 conversations with landlord, about property 1' do
          expect(subject.property_conversation(property1, receiver)).to be_a Talk::Property::Conversation
        end            
      end
    end
  end
end