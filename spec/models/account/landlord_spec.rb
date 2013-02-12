require 'spec_helper'

describe Account::Landlord do
  subject { landlord }

  let(:landlord)  { create :landlord_w_property }

  its(:valid?) { should be_true }

  specify { subject.property.should be_a(Property) }

  specify { subject.property.owner.should == subject }
end



