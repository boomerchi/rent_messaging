FactoryGirl.define do
  # system -> tenant
  factory :tenant_account, class: 'User::Account::Tenant', aliases: [:tenant] do  
    trait :valid do
      name 'tenant'
    end

    factory :valid_tenant_account, traits: [:valid]
  end
end
