FactoryGirl.define do
  factory :property, class: 'Property' do  
    trait :valid do
      name 'nice property'

      after :build do |property|
        FactoryGirl.create :landlord, property: property
      end      
    end

    factory :valid_property, traits: [:valid]
  end
end
