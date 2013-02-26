require 'spec_helper'

require 'spec_helper'

describe Talk::Api::System do
  subject { system }

  let(:tenant)    { create :tenant }
  let(:landlord)  { create :landlord_w_property }

  let(:system)    { Account::System.instance }    
  let(:property)  { landlord.property }  

  its(:conversations) { should be_empty }

  describe 'write' do
    context 'to system' do
      let(:receiver) { tenant }

      context 'system and landlord each have written in unread dialog' do
        before do
          system.write('hello you').to(receiver).about(property).send_it!

          receiver.write('interested').to(landlord).about(property).send_it!            
          landlord.write('hello there').to(receiver).about(property).send_it!            

          @system_conversation    = system.conversation_with receiver
          @landlord_conversation  = landlord.conversation_with receiver

          # puts "landlord: #{@landlord_conversation.dialogs.first.inspect}"
          # puts "system: #{@system_conversation.dialogs.first.inspect}"                  
        end

        describe 'tenant receiver' do
          it 'landlord conv has 1 unread property tenant dialog' do
            expect(@landlord_conversation.unread_dialogs_count_for :tenant).to eq 1
          end

          it 'system conv has 1 unread property tenant dialog' do
            expect(@system_conversation.unread_dialogs_count_for :tenant).to eq 1
          end

          it 'tenant has 2 unread property dialogs' do                    
            expect(receiver.unread_property_dialogs.count).to eq 2
          end

          it 'tenant has 2 unread dialogs' do                    
            expect(receiver.total_unread_dialogs).to eq 2
          end
        end
      end
    end
  end
end