FactoryGirl.define do
  factory :property_dialog, class: 'Talk::Property::Dialog' do
    ignore do
      message_count 0
    end

    trait :valid do
      after :build do |dialog, evaluator|
        evaluator.message_count.times do
          dialog.messages << FactoryGirl.create(:property_message, dialog: dialog)
        end
      end
    end

    trait :rejected do
      state 'rejected'  
    end

    trait :accepted do
      state 'accepted'  
    end

    factory :valid_property_dialog, traits: [:valid] 

    factory :rejected_dialog, traits: [:rejected] 
    factory :accepted_dialog, traits: [:accepted] 

    trait :info do
      state 'info'
    end
 
    trait :warning do
      state 'warning'
    end

    trait :error do
      state 'error'
    end

    factory :property_info_dialog,     traits: [:info]
    factory :property_warning_dialog,  traits: [:warning]
    factory :property_error_dialog,    traits: [:error]

  end  
end