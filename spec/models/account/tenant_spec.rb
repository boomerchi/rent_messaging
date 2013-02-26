require 'spec_helper'

describe Account::Tenant do
  subject { tenant }

  let(:tenant)  { create :tenant }

  let(:system_conversation)   { create :system_property_tenant_conversation }
  let(:landlord_conversation) { create :property_conversation }

  its(:valid?) { should be_true }

  describe 'property_conversation' do
    context 'One system-property conversation' do
      let(:system) { system_conversation.system }

      it 'should return conversation with system' do
        expect(subject.property_conversation system ).to_not be_empty
      end
    end

    context 'One landlord-property conversation' do
      let(:landlord)  { landlord_conversation.landlord }

      it 'should return conversation with landlord' do
        expect(subject.property_conversation landlord ).to_not be_empty
      end
    end
  end
end
