require 'spec_helper'

describe Talk::Property::Conversation do
  subject { conversation }

  let(:dialog)        { create :property_dialog, conversation: conversation }
  let(:message)       { create :message }

  let(:system)        { Account::System.instance }
  let(:tenant)        { create :tenant }

  let(:landlord)      { create :landlord }
  let(:property)      { create :valid_property }

  let(:landlord_w_property) { create :landlord_w_property }
  let(:landlord_property)   { landlord_w_property.property }

  Conversation  = Talk::Property::Conversation
  Dialog        = Talk::Property::Dialog

  Tenant        = Account::Tenant
  Landlord      = Account::Landlord

  let(:clazz)         { Talk::Property::Conversation }

  describe 'class methods' do
    context 'landlord, system and property owned by landlord' do
      let(:landlord) { landlord_w_property }
      let(:property) { landlord_property }

      describe 'get_landlord' do
        it 'should find first' do
          expect(clazz.get_landlord landlord, system).to eq landlord
        end

        it 'should find last' do
          expect(clazz.get_landlord system, landlord).to eq landlord
        end
      end

      describe 'no_landlord?' do
        it 'should be false' do
          expect(clazz.no_landlord? landlord, system).to be_false
        end
      end

      describe 'has_landlord?' do
        it 'should be true' do
          expect(clazz.has_landlord? landlord, system).to be_true
        end          
      end        

      describe 'landlord_property?' do
        it 'should be false' do
          expect(clazz.landlord_property? landlord, system, property).to be_true
        end
      end

      describe 'ignore_property?' do
        it 'should not be ignored' do
          expect(clazz.ignore_property? landlord, system, property).to be_false
        end
      end

      describe 'query_hash' do
        it 'should make a hash' do
          expect(clazz.query_hash system, landlord, property).to eq(property: property, landlord: landlord, system: system)
        end
      end        

      describe 'between_hash' do
        it 'should add property to hash' do
          expect(clazz.between_hash landlord, system, property).to eq(property: property, landlord: landlord, system: system)
        end
      end
    end

    context 'landlord, system and property not owned by landlord' do
      let(:landlord) { landlord_w_property }

      describe 'ignore_property?' do    
        it 'should be ignored' do      
          expect(clazz.ignore_property? landlord, system, property).to be_true
        end
      end

      describe 'query_hash' do
        it 'should make a hash' do
          expect(clazz.query_hash system, landlord, property).to eq(property: property, landlord: landlord, system: system)
        end
      end                

      describe 'between_hash' do
        it 'should raise InvalidProperty error' do
          expect { clazz.between_hash landlord, system, property}.to raise_error(Talk::Property::Conversation::InvalidProperty)
        end
      end
    end

    context 'landlord, system and property owned by other landlord' do
      let(:landlord)        { landlord_w_property }
      let(:other_landlord)  { create :landlord_w_property }
      let(:property)        { other_landlord.property }

      describe 'ignore_property?' do     
        it 'should be ignored' do     
          expect(clazz.ignore_property? landlord, system, property).to be_true
        end
      end

      describe 'query_hash' do
        it 'should make a hash' do
          expect(clazz.query_hash system, landlord, property).to eq(property: property, landlord: landlord, system: system)
        end
      end        

      describe 'between_hash' do
        it 'should raise InvalidProperty error' do
          expect { clazz.between_hash landlord, system, property }.to raise_error(Talk::Property::Conversation::InvalidProperty)
        end
      end
    end

    context 'tenant, system and property' do
      describe 'ignore_property?' do     
        it 'should be ignored' do     
          expect(clazz.ignore_property? tenant, system, property).to be_false
        end
      end

      describe 'query_hash' do
        it 'should make a hash' do
          expect(clazz.query_hash system, tenant, property).to eq(property: property, tenant: tenant, system: system)
        end
      end

      describe 'between_hash' do
        it 'should raise InvalidProperty error' do
          expect(clazz.between_hash tenant, system, property).to eq(tenant: tenant, system: system, property: property)
        end
      end
    end

    context 'landlord, tenant and property owned by landlord' do
      let(:landlord) { landlord_w_property }
      let(:property) { landlord_property }

      describe 'get_landlord' do
        it 'should find first' do
          expect(clazz.get_landlord landlord, tenant).to eq landlord
        end

        it 'should find last' do
          expect(clazz.get_landlord tenant, landlord).to eq landlord
        end
      end

      describe 'no_landlord?' do
        it 'should be false' do
          expect(clazz.no_landlord? landlord, tenant).to be_false
        end
      end

      describe 'landlord_property?' do
        it 'should be false' do
          expect(clazz.landlord_property? landlord, tenant, property).to be_true
        end
      end

      describe 'ignore_property?' do
        it 'should not be ignored' do
          expect(clazz.ignore_property? landlord, tenant, property).to be_false
        end
      end

      describe 'query_hash' do
        it 'should make a hash' do
          expect(clazz.query_hash landlord, tenant, property).to eq(property: property, tenant: tenant, landlord: landlord)
        end
      end                

      describe 'between_hash' do
        it 'should add property to hash' do
          expect(clazz.between_hash landlord, tenant, property).to eq(property: property, landlord: landlord, tenant: tenant)
        end
      end
    end

    context 'landlord, tenant and property not owned by landlord' do
      let(:landlord) { landlord_w_property }

      describe 'ignore_property?' do    
        it 'should be ignored' do      
          expect(clazz.ignore_property? landlord, tenant, property).to be_true
        end
      end

      describe 'query_hash' do
        it 'should make a hash' do
          expect(clazz.query_hash landlord, tenant, property).to eq(property: property, tenant: tenant, landlord: landlord)
        end
      end                

      describe 'between_hash' do
        it 'should raise InvalidProperty error' do
          expect { clazz.between_hash landlord, tenant, property}.to raise_error(Talk::Property::Conversation::InvalidProperty)
        end
      end
    end

    context 'landlord, system and property owned by other landlord' do
      let(:landlord)        { landlord_w_property }
      let(:other_landlord)  { create :landlord_w_property }
      let(:property)        { other_landlord.property }

      describe 'ignore_property?' do     
        it 'should be ignored' do     
          expect(clazz.ignore_property? landlord, tenant, property).to be_true
        end
      end

      describe 'query_hash' do
        it 'should make a hash' do
          expect(clazz.query_hash landlord, tenant, property).to eq(property: property, tenant: tenant, landlord: landlord)
        end
      end        

      describe 'between_hash' do
        it 'should raise InvalidProperty error' do
          expect { clazz.between_hash landlord, tenant, property }.to raise_error(Talk::Property::Conversation::InvalidProperty)
        end
      end
    end
  end
end
