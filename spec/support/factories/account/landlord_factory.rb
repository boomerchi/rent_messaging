FactoryGirl.define do
  # system -> tenant
  factory :landlord_account, class: 'Account::Landlord', aliases: [:landlord] do  
    trait :valid do
      name 'landlord'
    end

    trait :w_property do
      after :build do |landlord, evaluator|
        landlord.property = FactoryGirl.create :property, landlord: landlord, owner: landlord
      end
    end

    factory :landlord_w_property, traits: [:valid, :w_property]

    factory :valid_landlord_account, traits: [:valid]
  end
end
