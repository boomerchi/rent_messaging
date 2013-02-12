FactoryGirl.define do

  factory :property_message, class: 'Talk::Property::Message' do
    subject { 'hello' }
    body    { 'hi' }
  end  
end