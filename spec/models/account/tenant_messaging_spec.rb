require 'spec_helper'

describe User::Account::Tenant do
  describe User::Account::Tenant::Messaging do
    subject { tenant }

    let(:landlord)  { create :landlord_w_property, property_count: 3 }
    let(:tenant)    { create :tenant }  
    let(:system)    { Account::System.instance }

    let(:property)  {  landlord.properties[0] }
    let(:property1)  { landlord.properties[1] }
    let(:property2)   { landlord.properties[2] }

    let(:landlord_property)    { landlord.property }

    let(:sender)   { subject }

    describe 'write' do
      context 'to landlord' do
        let(:receiver) { landlord }
        let(:property) { landlord_property }

        it 'can initiate writing' do
          expect { subject.write('hello').to(receiver) }.to_not raise_error(Talk::Conversation::InitiationError)
        end

        context 'who has no previous conversation' do
          it 'has a conversation with the landlord' do
            subject.conversations_with(receiver).should be_empty
          end

          context 'about property' do
            before do
              subject.write('hello you').to(receiver).about(property).send_it!
            end

            context 'landlord' do
              it 'should have 1 unread dialog' do
                expect(receiver.unread_property_dialogs).to_not be_empty
              end
            end

            context 'tenant' do
              it 'should have 1 read dialog' do
                expect(receiver.read_property_dialogs).to_not be_empty
              end
            end

            context 'system has initiated dialog with tenant about property' do
              before do
                @current_conv = Talk::Property::Conversation.between(sender, receiver, property).first
              end
              
              it 'should have created a valid property conversation' do
                expect(@current_conv).to be_valid
              end

              it 'should have property' do
                expect(@current_conv.property).to eq property
              end

              it 'and tenant' do
                expect(@current_conv.tenant).to eq tenant
              end

              context 'and tenant replies' do
                before do
                  # landlord replies in dialog (1)
                  receiver.write('reply').to(subject).about(property).send_it!
                  receiver.write('another reply').to(subject).about(property).send_it!

                  @conv = subject.property_conversation(property, receiver)
                end

                it 'should have 1 conversations with system, about property' do
                  expect(@conv).to be_a Talk::Property::Conversation
                end

                context 'dialog' do
                  it 'should be unread for subject (tenant)' do
                    expect(@conv.dialogs.first.unread_for? :tenant).to be_true
                  end 

                  it 'should be read for receiver (landlord)' do
                    expect(@conv.dialogs.first.read_for? :landlord).to be_true
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
