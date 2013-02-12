require 'spec_helper'

describe Talk::Property::Conversation do
  subject { conversation }

  let(:dialog)        { create :property_dialog, conversation: conversation }
  let(:message)       { create :message }

  let(:system)        { Account::System.instance }
  let(:tenant)        { create :tenant }
  let(:landlord)      { create :landlord }
  let(:landlord_prop) { create :landlord_w_property }

  let(:property)      { create :valid_property }

  Conversation  = Talk::Property::Conversation
  Dialog        = Talk::Property::Dialog

  Tenant        = Account::Tenant
  Landlord      = Account::Landlord

  let(:clazz)         { Talk::Property::Conversation }

  describe 'between' do
    context 'two conversations: landlord-tenant, landlord-system' do
      before do
        landlord.property = property
        @personal_conversation      = clazz.create tenant:    tenant,   landlord: landlord
        @sys_tenant_conversation    = clazz.create tenant:    tenant,   system: system, property: property       
        @sys_landlord_conversation  = clazz.create landlord:  landlord, system: system
      end      

      it 'should return conversations between tenant and landlord' do
        expect(clazz.between(tenant, landlord).first).to eq(@personal_conversation)
      end

      describe 'reverse args' do
        it 'should return conversations between tenant and landlord' do
          expect(clazz.between(landlord, tenant).first).to eq(@personal_conversation)
        end
      end

      describe 'single tenant account arg' do
        describe 'between_hash' do
          it 'should make a hash with system' do
            expect(clazz.between_hash tenant).to eq(tenant: tenant, system: system)
          end
        end

        it 'should return conversations between tenant and system' do
          expect(clazz.between(tenant).first).to eq(@sys_tenant_conversation)
        end
      end

      describe 'single landlord account arg' do
        describe 'between_hash' do
          it 'should make a hash with system' do
            expect(clazz.between_hash landlord).to eq(landlord: landlord, system: system)
          end
        end

        it 'should return conversations between tenant and system' do
          expect(clazz.for(landlord).first).to eq(@sys_landlord_conversation)
        end
      end
    end

    describe 'constructors' do
      describe 'with_system_about' do
        context 'property' do
          before do
            @result = clazz.with_system_about landlord_prop.property
          end

          it 'should create a conversation' do
            expect(@result).to be_a clazz
          end

          it 'about property' do
            expect(@result.property).to eq landlord_prop.property
          end

          it 'between system and landlord' do
            expect(@result.system?).to be_true
            expect(@result.landlord).to eq landlord_prop.property.landlord
            expect(@result.landlord).to eq landlord_prop.property.owner
          end
        end

        context 'property and tenant' do
          before do
            @result = clazz.with_system_about landlord_prop.property, tenant
          end

          it 'should create a conversation' do
            expect(@result).to be_a clazz
          end

          it 'about property' do
            expect(@result.property).to eq landlord_prop.property
          end

          it 'between system and landlord' do
            expect(@result.system?).to be_true
            expect(@result.tenant).to eq tenant
            expect(@result.landlord).to eq nil
          end
        end
      end

      describe 'about' do
        context 'property and tenant' do
          before do
            @result = clazz.about landlord_prop.property, tenant
          end

          it 'should create a conversation' do
            expect(@result).to be_a clazz
          end

          it 'that is personal' do
            expect(@result.system?).to be_false
            expect(@result.personal?).to be_true
          end

          it 'about property' do
            expect(@result.property).to eq landlord_prop.property
          end

          it 'between tenant' do          
            expect(@result.tenant).to eq tenant
          end

          it 'and landlord' do                    
            expect(@result.landlord).to eq landlord_prop.property.landlord
            expect(@result.landlord).to eq landlord_prop.property.owner
            
            expect(@result.system).to eq nil
          end
        end
      end
    end
  end
end