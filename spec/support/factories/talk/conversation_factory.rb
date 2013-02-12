FactoryGirl.define do
  # generic
  factory :conversation, class: 'Talk::Conversation' do  
    ignore do
      dialog_count 1
    end

    after :build do |conversation, evaluator|
      evaluator.dialog_count.times do
        FactoryGirl.create :valid_dialog, conversation: conversation
      end
    end
  end
end
