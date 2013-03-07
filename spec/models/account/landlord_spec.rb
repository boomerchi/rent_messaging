require 'spec_helper'

describe User::Account::Landlord do
  subject { landlord }

  let(:landlord)  { create :landlord_w_property }

  its(:valid?) { should be_true }

  context 'landlord property' do
    subject { landlord.property }

    it 'should be a property' do
      expect(subject).to be_a Property
    end

    it 'should have an owner' do
      expect(subject.owner).to eq landlord
    end
  end
end