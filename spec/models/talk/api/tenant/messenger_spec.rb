require 'spec_helper'

describe Talk::Api::Tenant::Messenger do
  subject { messenger }

  let(:clazz)     { Talk::Api::Tenant::Messenger }

  let(:landlord)  { create :landlord }
  let(:tenant)    { create :tenant }  
  let(:property)  { create :property }    

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
        expect { clazz.new receiver, message }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'initial state' do
    its(:receiver) { should == nil }
    its(:sender)   { should == sender }

    its(:message)         { should be_a Hash }

    its('message.body')   { should == message }
    its('message.type')   { should == :info }    
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