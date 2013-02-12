FactoryGirl.define do

  factory :message, class: 'Talk::Message' do  
    subject { 'hello' }
    body    { 'hi' }

    trait :valid do
    end

    factory :valid_message, traits: [:valid] 
  end  
end