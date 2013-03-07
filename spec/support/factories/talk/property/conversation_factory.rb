FactoryGirl.define do
  # tenant <-> landlord
  factory :property_conversation, class: 'Talk::Property::Conversation' do  
    ignore do
      dialog_count 0
    end

    property  { FactoryGirl.create :valid_property }

    tenant    { FactoryGirl.create :tenant }
    landlord  { FactoryGirl.create :landlord }

    after :build do |conversation, evaluator|
      evaluator.dialog_count.times do
        FactoryGirl.create :valid_property_dialog, conversation: conversation
      end
    end
  end

  # system -> tenant
  factory :system_property_tenant_conversation, class: 'Talk::Property::Conversation' do  
    ignore do
      dialog_count 0
    end

    property  { FactoryGirl.create :valid_property }

    system    { Account::System.instance }
    tenant    { FactoryGirl.create :tenant }

    after :build do |conversation, evaluator|
      evaluator.dialog_count.times do
        FactoryGirl.create :valid_property_dialog, conversation: conversation
      end
    end
  end

  # system -> landlord
  factory :system_property_landlord_conversation, class: 'Talk::Property::Conversation' do  
    ignore do
      dialog_count 0
    end

    property  { FactoryGirl.create :valid_property }

    system    { Account::System.instance }
    landlord  { FactoryGirl.create :landlord_w_property }

    after :build do |conversation, evaluator|
      evaluator.dialog_count.times do
        conversation.property = conversation.landlord.property if conversation.landlord
        FactoryGirl.create :valid_property_dialog, conversation: conversation
      end
    end
  end
end