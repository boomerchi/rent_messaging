require 'spec_helper'

describe Talk::Api::Landlord::PropertyGroupConversator do
  subject { property_group_conversator }

  let(:clazz)     { Talk::Api::Landlord::PropertyGroupConversator}

  let(:landlord)  { create :landlord }
  let(:tenant)    { create :tenant }  

  let(:property)  { create :property }  

  let(:receiver)  { tenant }
  let(:sender)    { landlord }

  let(:message)   { 'hello' }  

  let(:messenger) { Talk::Api::Landlord::Messenger.new sender, message }  

  let(:property_group_conversator) do
    clazz.new messenger, property
  end

  describe 'init' do
    context 'create with messenger and receiver: tenant ' do
      it 'should not raise error' do
        expect { clazz.new messenger, property }.to_not raise_error
      end

      it 'should create a Messager' do
        expect(clazz.new messenger, property).to be_a clazz
      end
    end

    context 'create with messenger and no property' do
      it 'should raise error' do
        expect { clazz.new messenger, nil }.to raise_error(ArgumentError)
      end
    end

    context 'create with messenger and sender' do
      it 'should raise error' do
        expect { clazz.new messenger, sender }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'initial state' do
    its(:messenger)       { should == messenger }
    its(:receiver)        { should == nil }

    its(:sender)          { should == sender }
    its(:message)         { should be_a Hash }

    its('message.body')   { should == message }
    its('message.type')   { should == :info }
  end

  describe 'API' do
    describe 'property_conversations' do
      context 'no conversations with receiver about this property' do
        describe 'property_conversations' do
          it 'should be empty' do
            expect(subject.property_conversations).to be_empty
          end
        end
      end

      # context 'already existing conversation with receiver about this property' do
      #   before do

      #   end

      #   describe 'property_conversations' do
      #     it 'should not be empty' do
      #       expect(subject.property_conversations).to_not be_empty
      #     end
      #   end
      # end
    end

    describe 'send_it!' do
      it 'should "send" the message' do
        expect { subject.send_it! }.to_not raise_error
      end
    end
  end    
end