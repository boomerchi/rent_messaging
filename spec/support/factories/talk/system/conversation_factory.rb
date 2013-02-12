FactoryGirl.define do
  # system -> tenant
  factory :system_tenant_conversation, class: 'Talk::System::Conversation', aliases: [:system_conversation] do  
    ignore do
      dialog_count 0
    end

    type 'system'

    tenant { FactoryGirl.create :tenant }

    after :build do |conversation, evaluator|
      evaluator.dialog_count.times do
        FactoryGirl.create :valid_system_dialog, conversation: conversation
      end
    end
  end

  # system -> landlord
  factory :system_landlord_conversation, class: 'Talk::System::Conversation' do  
    ignore do
      dialog_count 0
    end

    type 'system'

    landlord { FactoryGirl.create :landlord }

    after :build do |conversation, evaluator|
      evaluator.dialog_count.times do
        FactoryGirl.create :valid_system_dialog, conversation: conversation
      end
    end
  end
end