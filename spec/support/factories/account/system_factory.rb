FactoryGirl.define do
  # system -> tenant
  factory :system_account, class: 'Account::System', aliases: [:system] do  
    trait :valid do
    end

    factory :valid_system_account, traits: [:valid]
  end
end
