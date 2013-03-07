FactoryGirl.define do
  # system -> tenant
  factory :landlord_account, class: 'User::Account::Landlord', aliases: [:landlord] do  
    trait :valid do
      name 'landlord'
    end

    trait :w_property do
      ignore do
        property_count 0
      end

      after :build do |landlord, evaluator|
        if evaluator.property_count == 0
          landlord.property = FactoryGirl.create(:property, landlord: landlord, owner: landlord)
        end

        evaluator.property_count.times do
          landlord.properties << FactoryGirl.create(:property, landlord: landlord, owner: landlord)
        end
      end
    end

    factory :landlord_w_property, traits: [:valid, :w_property]

    factory :valid_landlord_account, traits: [:valid]
  end
end
