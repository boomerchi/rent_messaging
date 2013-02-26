require 'spec_helper'

describe Account::Tenant do
  describe Account::Tenant::Messaging do
    subject { tenant }

    let(:landlord)  { create :landlord_w_property, property_count: 3 }
    let(:tenant)    { create :tenant }  
    let(:system)    { Account::System.instance }

    let(:property)    {  landlord.properties[0] }
    let(:property1)   { landlord.properties[1] }
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

            context 'system has initiated dialog with tenant about property' do
              before do
                @current_conv = Talk::Property::Conversation.between(subject, receiver, property).first
              end
              
              # it 'should have created a valid property conversation' do
              #   expect(@current_conv).to be_valid
              # end

              # it 'should have property' do
              #   expect(@current_conv.property).to eq property
              # end

              # it 'and tenant' do
              #   expect(@current_conv.tenant).to eq tenant
              # end

              context 'and tenant replies' do
                before do
                  # landlord replies in dialog (1)
                  receiver.write('reply').to(subject).about(property).send_it!
                  receiver.write('another reply').to(subject).about(property).send_it!
                end

                it 'should have 1 conversations with system, about property' do
                  expect(subject.property_conversation(property, receiver)).to be_a Talk::Property::Conversation
                end                            

                context 'and system starts new conversation about another property' do
                  before do
                    # and with landlord about another property (1)
                    subject.write('hello you').to(receiver).about(property1).send_it!
                    receiver.write('starting').to(subject).about(property1).send_it!

                    @conv = subject.property_conversation(property1, receiver)
                  end

                  # it 'should have valid property conversations' do
                  #   subject.property_conversations.each do |conv|
                  #     expect(conv).to be_valid
                  #   end
                  # end  

                  # # RECEIVER is a LANDLORD
                  # it 'should have 2 conversations with landlord, one for each property' do
                  #   expect(subject.conversations_with(receiver).count).to eq 2              
                  # end            

                  # it 'should have 1 conversations with landlord, about property' do
                  #   expect(subject.property_conversation(property, receiver)).to be_a Talk::Property::Conversation
                  # end            

                  # it 'should have 1 conversations with landlord, about property 1' do
                  #   expect(subject.property_conversation(property, receiver)).to be_a Talk::Property::Conversation
                  # end    

                  context 'dialog' do
                    it 'should be unread for subject (tenant)' do
                      expect(@conv.dialogs.first.unread_for? :tenant).to be_true
                    end 

                    it 'should be read for receiver (landlord)' do
                      expect(@conv.dialogs.first.read_for? :landlord).to be_true
                    end 

                    it 'should have unread tenant dialogs' do
                      expect(@conv.unread_dialogs_for :tenant).to_not be_empty
                    end 
                  end

                  it 'should have unread dialogs' do
                    puts "Conv: #{@conv.inspect}"
                    expect(subject.property_conversations.last.unread_dialogs_for :tenant).to_not be_empty
                  end

                  it 'should have the property conversation' do
                    expect(subject.property_conversations.to_a).to include(@conv)
                  end

                  it 'should have 1 unread dialog' do
                    puts "unread: #{subject.unread_property_dialogs.map(&:conversation)}"

                    expect(subject.total_unread_property_dialogs).to eq 1
                  end

                  # it 'should be a personal dialog' do
                  #   expect(subject.unread_property_dialogs.first.conversation.type).to eq 'personal'
                  # end
                  
                  # context 'different properties same landlord' do
                  #   let(:conv)  { subject.property_conversation property, receiver }
                  #   let(:conv1) { subject.property_conversation property1, receiver }

                  #   it 'uses different properties' do
                  #     expect(property).to_not eq property1
                  #   end

                  #   it 'uses different base property conversations' do
                  #     expect(subject.conversations_about property).to_not eq (subject.conversations_about property1)
                  #   end

                  #   it 'should not be the same conversation' do
                  #     expect(conv1).to_not eq conv
                  #   end
                  # end

                  context 'and system also writes about the first property' do
                    before do
                      # system writes about first property (1)
                      system.write('contract aid').to(subject).about(property).send_it!              

                      # puts "tenant property conversations: #{subject.property_conversations.inspect}"
                    end

                    # it 'should have 1 property conversation with system' do
                    #   expect(subject.property_conversation property, system).to be_a Talk::Property::Conversation
                    # end            

                    # it 'should have 1 conversations with system' do
                    #   expect(subject.conversations_with(system).count).to eq 1
                    # end            

                    # it 'should have 1 conversations with system' do
                    #   expect(subject.conversation_with system).to be_a Talk::Property::Conversation
                    # end    

                    # it 'should have 1 conversations with system, about property 1' do
                    #   expect(subject.property_conversation property, system).to be_a Talk::Property::Conversation
                    # end                                                                  

                    # it 'should first have an unread personal dialog' do
                    #   expect(subject.unread_property_dialogs.first.conversation.type).to eq 'personal'
                    # end

                    # it 'and then an unread system dialog' do
                    #   expect(subject.unread_property_dialogs.last.conversation.type).to eq 'system'
                    # end

                    # it 'should have 2 unread property dialogs' do
                    #   puts "unread: #{subject.unread_property_dialogs.map(&:conversation)}"
                    #   expect(subject.total_unread_property_dialogs).to eq 2
                    # end            

                    # it 'should have 2 unread dialogs' do
                    #   expect(subject.total_unread_all_dialogs).to eq 2
                    # end            

                    # it 'should have 2 unread :all dialogs' do
                    #   expect(subject.total_unread_dialogs :all).to eq 2
                    # end            

                    # it 'should have 2 unread :property dialogs' do
                    #   expect(subject.total_unread_dialogs :property).to eq 2
                    # end            

                    # it 'should have 0 unread :system dialogs' do
                    #   expect(subject.total_unread_dialogs :system).to eq 0
                    # end                    
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
