FactoryGirl.define do

  factory :dialog, class: 'Talk::Dialog' do  
    trait :valid do
      after :build do |dialog|
        FactoryGirl.create :message, dialog: dialog
      end
    end

    factory :valid_dialog, traits: [:valid] 
  end  
end