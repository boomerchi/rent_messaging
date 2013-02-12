FactoryGirl.define do

  factory :system_dialog, class: 'Talk::System::Dialog' do 
    trait :valid do
      after :build do |dialog|
        FactoryGirl.create :message, dialog: dialog
      end
    end

    trait :info do
      state 'info'
    end
 
    trait :warning do
      state 'warning'
    end

    trait :error do
      state 'error'
    end

    factory :valid_system_dialog, traits: [:valid] 

    factory :info_dialog,     traits: [:info]
    factory :warning_dialog,  traits: [:warning]
    factory :error_dialog,    traits: [:error]
  end
end