require 'spec_helper'

describe Talk::Api::Landlord::PropertyConversator do
  subject { property_conversator }

  let(:clazz)     { Talk::Api::Landlord::PropertyConversator}

  let(:landlord)  { create :landlord }
  let(:tenant)    { create :tenant }  
  let(:property)  { create :property }  

  let(:receiver)  { tenant }
  let(:sender)    { landlord }

  let(:message)   { 'hello' }  

  let(:messenger) { Talk::Api::Landlord::Messenger.new sender, message }  

  let(:property_conversator) do
    clazz.new messenger, receiver
  end

  describe 'init' do
    context 'create with messenger and receiver: tenant ' do
      it 'should not raise error' do
        expect { clazz.new messenger, receiver }.to_not raise_error
      end

      it 'should create a Messager' do
        expect(clazz.new messenger, receiver).to be_a clazz
      end
    end

    context 'create with messenger and receiver: sender (landlord)' do
      it 'should raise error' do
        expect { clazz.new messenger, sender }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'initial state' do
    its(:messenger)       { should == messenger }
    its(:receiver)        { should == receiver }

    its(:sender)          { should == sender }
    its(:message)         { should be_a Hash }

    its('message.body')   { should == message }
    its('message.type')   { should == :info }
  end

  describe 'API' do
    describe 'about property' do
      context 'nil property' do
        it 'should raise argument error' do
          expect { subject.about(nil) }.to raise_error(ArgumentError)
        end
      end

      context 'valid property' do
        let(:conversator) { subject.about(property) }

        it 'should return property group conversator' do
          expect(conversator).to be_a Talk::Api::Landlord::PropertyConversator
        end

        it 'should assign the property being talked about' do
          expect(conversator.property).to eq(property)
        end      
      end
    end

    context 'landlord has no properties' do
      context 'no property explicitly being talked about' do
        describe 'property_conversations' do
          it 'should be empty' do
            expect { subject.property_conversations }.to raise_error(Property::DefaultNotFoundError)
          end
        end
      end
    end

    context 'landlord has properties' do
      before do
        landlord.properties << property
      end

      specify { landlord.properties.should_not be_empty }
      specify { landlord.properties.first.should == property }

      context 'no property explicitly being talked about' do
        describe 'property_conversations' do
          context 'none created' do
            it 'should not error - using landlord default property' do
              expect { subject.property_conversations }.to_not raise_error(Property::DefaultNotFoundError)
            end

            it 'should return empty conversations list' do
              expect(subject.property_conversations).to be_empty
            end
          end
        end

        describe 'user_property_conversations' do
          it 'should not have any' do
            expect(subject.user_property_conversations).to be_empty
          end
        end

        describe 'user_property_dialogs' do
          it 'should not have any' do
            expect(subject.user_property_dialogs).to be_empty
          end
        end

        describe 'property_dialog' do
          it 'should not have one' do
            expect(subject.property_dialog).to be_nil
          end
        end      
      end
    end

    describe 'send_it!' do
      it 'should be sent' do
        expect { subject.send_it! }.to raise_error(Talk::Api::DialogNotFoundError)
      end
    end    
  end  
end