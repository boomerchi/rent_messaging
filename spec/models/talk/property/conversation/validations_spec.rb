require 'spec_helper'

describe Talk::Property::Conversation do
  subject { conversation }

  let(:dialog)        { create :property_dialog, conversation: conversation }
  let(:message)       { create :message }

  let(:system)        { Account::System.instance }
  let(:tenant)        { create :tenant }
  let(:landlord)      { create :landlord_w_property }
  let(:property)      { landlord.property }

  let(:landlord_without)  { create :landlord }

  Conversation  = Talk::Property::Conversation
  Dialog        = Talk::Property::Dialog

  Tenant        = Account::Tenant
  Landlord      = Account::Landlord

  let(:clazz)         { Talk::Property::Conversation }

  context 'Validations' do 
    describe 'setup' do
      context 'conversation between tenant and landlord' do
        context 'about property' do 
          it 'should be valid' do
            expect(clazz.create tenant: tenant, landlord: landlord, property: property).to be_valid
          end
        end

        context 'about landlord default property' do 
          before do
            landlord.property = create :property, landlord: landlord
          end

          it 'should be valid' do
            expect(clazz.create tenant: tenant, landlord: landlord).to be_valid
          end
        end

        context 'about landlord default property - but not set!' do 
          it 'should be valid' do
            expect {clazz.create tenant: tenant, landlord: landlord_without}.to raise_error(Property::DefaultNotFoundError)
          end
        end
      end

      context 'conversation only for tenant' do 
        context 'about property' do
          let(:conversation) { clazz.create tenant: tenant, property: property }

          it 'should use system account as the other party' do
            expect(conversation).to be_valid
            expect(conversation.system).to eq(system)
          end
        end

        context 'NOT about a property' do
          let(:conversation) { clazz.create tenant: tenant }

          it 'should use system account as the other party' do
            expect(conversation).to_not be_valid
            expect(conversation.system).to eq(system)
          end
        end
      end

      context 'conversation only for landlord' do         
        context 'about property' do
          let(:conversation) { clazz.create landlord: landlord, property: property }

          it 'should use system account as the other party' do
            expect(conversation).to be_valid
            expect(conversation.system).to eq(system)
          end
        end

        context 'NOT about a property' do
          context 'landlord has no default property' do
            it 'should error when trying to use landlord default property' do
              expect { clazz.create landlord: landlord_without }.to raise_error(Property::DefaultNotFoundError)
            end
          end

          context 'landlord has a default property' do
            let(:conversation) { clazz.create landlord: landlord }

            before do
              landlord.property = property
            end

            it 'should be valid' do
              expect(conversation).to be_valid
            end

            it 'should use system account as the other party' do              
              expect(conversation.system).to eq(system)
            end

            it 'should use landlord default property as the property being talked about' do
              expect(conversation.property).to eq(landlord.the_default_property)
            end
          end
        end
      end

      # context 'system only conversation' do
      #   it 'should not be allowed' do        
      #     expect(clazz.create system: system).to_not be_valid
      #   end
      # end

      # context 'conversation for 3 accounts' do 
      #   it 'should not be allowed' do
      #     expect(clazz.create landlord: landlord, tenant: tenant, system: system).to_not be_valid
      #   end
      # end
    end
  end
end