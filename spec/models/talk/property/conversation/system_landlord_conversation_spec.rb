require 'spec_helper'

describe Talk::Property::Conversation do
  subject { conversation }

  let(:dialog)        { create :property_dialog, conversation: conversation }
  let(:message)       { create :message }

  let(:system)        { create :system }
  let(:tenant)        { create :tenant }
  let(:landlord)      { create :landlord }

  Conversation  = Talk::Property::Conversation
  Dialog        = Talk::Property::Dialog

  Tenant        = Account::Tenant
  Landlord      = Account::Landlord

  let(:clazz)         { Talk::Property::Conversation }

  context 'System -> Landlord conversation' do 
    let(:conversation)  { create :system_property_landlord_conversation }

    its(:valid?) { should be_true }

    context 'default dialogs' do
      its(:dialogs) { should_not be_empty }

      describe 'tenant' do
        its(:tenant) { should be_nil }
      end  

      describe 'landlord' do
        its(:landlord) { should be_a Account::Landlord }
      end  
    end

    describe 'initiator' do
      its(:initiator) { should be_an Account::System }
    end

    describe 'type' do
      its(:type) { should == 'system' }
    end

    describe 'system?' do
      its(:system?) { should be_true }
    end

    describe 'replier' do
      its(:replier) { should be_an Account::Landlord }
    end
  end  
end