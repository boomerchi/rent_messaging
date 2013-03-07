require 'spec_helper'

describe Talk::Api::Tenant::Messenger do
  subject { messenger }

  let(:clazz)     { Talk::Api::Tenant::Messenger }

  let(:landlord)  { create :landlord_w_property }
  let(:tenant)    { create :tenant }  
  let(:property)  { landlord.property }    

  let(:landlord_without_property)  { create :landlord }

  let(:sender)    { tenant }
  let(:receiver)  { landlord }

  let(:message)   { 'hello' }  

  let(:messenger) do
    clazz.new sender, message
  end

  describe 'init' do
    context 'create with landlord account and message text' do
      it 'should not raise error' do
        expect { clazz.new sender, message }.to_not raise_error
      end

      it 'should create a Messager' do
        expect(clazz.new sender, message).to be_a clazz
      end
    end

    context 'create with tenant account and message text' do
      it 'should raise error' do
        expect { clazz.new receiver, message }.to raise_error(Talk::Conversation::SenderError)
      end
    end
  end

  describe 'initial state' do
    it 'should not set receiver' do
      expect(subject.receiver).to be_nil
    end

    it 'should set sender' do
      expect(subject.sender).to eq sender
    end

    its(:message)  { should be_a Hash }

    context 'message' do
      subject { messenger.message }

      it 'should have a body' do
        expect(subject.body).to eq message
      end

      it 'should be :info type' do
        expect(subject.type).to eq :info
      end
    end
  end

  describe 'API' do
    describe 'about property' do
      let(:conversator) { subject.about(property) }

      it 'should return property group conversator' do
        expect(conversator).to be_a Talk::Api::Tenant::PropertyGroupConversator
        expect(conversator.messenger).to eq(messenger)
        expect(conversator.property).to eq(property)
      end      
    end

    describe 'to receiver' do 
      let(:receiver)    { landlord_without_property }
      let(:conversator) { subject.to(receiver) }

      it 'should return property conversator' do
        expect(conversator).to be_a Talk::Api::Tenant::PropertyConversator
      end

      it 'should encapsulate the messenger' do
        expect(conversator.messenger).to be_a Talk::Api::Tenant::Messenger
        expect(conversator.messenger).to eq(messenger)
      end

      it 'should not have a property' do
        expect { conversator.property }.to raise_error(Property::DefaultNotFoundError)
      end
    end    
  end    
end