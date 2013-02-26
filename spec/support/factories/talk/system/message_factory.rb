FactoryGirl.define do

  factory :system_message, class: 'Talk::System::Message' do
    subject { 'hello' }
    body    { 'hi' }
  end  
end