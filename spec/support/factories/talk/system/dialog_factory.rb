FactoryGirl.define do

  factory :system_dialog, class: 'Talk::System::Dialog' do 
    ignore do
      message_count 0
    end

    trait :valid do
      after :build do |dialog, evaluator|
        evaluator.message_count.times do
          dialog.messages << FactoryGirl.create(:system_message, dialog: dialog)
        end
      end
    end

    trait :rejected do
      state 'rejected'  
    end

    trait :accepted do
      state 'accepted'  
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