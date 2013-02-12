require 'spec_helper'

describe Talk::Property::Conversation do
  subject { conversation }

  let(:dialog)        { create :property_dialog, conversation: conversation }
  let(:message)       { create :message }

  let(:system)        { Account::System.instance }
  let(:tenant)        { create :tenant }
  let(:landlord)      { create :landlord }
  let(:landlord_prop) { create :landlord_w_property }
  let(:property)      { create :property }

  let(:sender)        { tenant }
  let(:receiver)      { landlord }

  Conversation  = Talk::Property::Conversation
  Dialog        = Talk::Property::Dialog

  Tenant        = Account::Tenant
  Landlord      = Account::Landlord

  let(:clazz)         { Talk::Property::Conversation }

  context 'Tenant <-> Landlord conversation' do 
    let(:conversation)  { create :property_conversation }

    it 'should be valid' do
      expect(conversation).to be_valid
    end

    context 'always at least one dialog per default' do
      its(:dialogs)       { should_not be_empty }
      its('dialogs.size') { should == 1 }

      describe 'tenant' do
        its(:tenant) { should be_a Account::Tenant }
      end  

      describe 'landlord' do
        its(:landlord) { should be_a Account::Landlord }
      end  
    end

    context 'with extra dialogs' do
      before do
        conversation.dialogs << dialog
      end

      describe 'dialogs' do
        its(:dialogs) { should_not be_empty }
        its('dialogs.size') { should == 2 }

        it 'should add the dialog' do
          expect(subject.dialogs.first).to be_a Talk::Property::Dialog
          expect(subject.dialogs.last).to eq(dialog)
        end
      end
    end

    describe 'initiator' do
      its(:initiator) { should be_an Account::Tenant }
    end

    describe 'system?' do
      its(:system?) { should be_false }
    end

    describe 'replier' do
      it 'should have the landlord as replier' do
        expect(subject.replier).to be_a Account::Landlord
      end
    end   

    context 'no conversations' do
      describe 'scopes' do
        describe 'latest' do
          it 'should return latest first' do
            expect(clazz.latest).to be_empty
          end
        end

        describe 'oldest' do
          it 'should return oldest first' do
            expect(clazz.oldest).to be_empty
          end
        end

        describe 'between' do
          it 'should return no conversations between tenant and landlord' do
            expect(clazz.between tenant, landlord).to be_empty
          end
        end
      end

      describe 'create_between' do
        before do
          landlord.property = property
          @result = clazz.create_between(tenant, landlord)
        end

        it 'should create a conversation' do          
          expect(@result).to be_a clazz
        end
        
        it 'should be between landlord' do
          expect(@result.landlord).to eq(landlord)
        end

        it 'and tenant' do
          expect(@result.tenant).to eq(tenant)
        end

        it 'about property' do
          expect(@result.property).to eq(property)
        end

        it 'should be valid' do
          expect(@result).to be_valid
        end

        it 'should be persisted' do
          expect(@result).to be_persisted
        end
      end

      describe 'init_between' do
        before do
          landlord.property = property
          @result = clazz.init_between(tenant, landlord)
        end

        it 'should return a new (initialized) conversation between tenant and landlord' do
          expect(@result).to be_a clazz
        end

        it 'should be between landlord' do
          expect(@result.landlord).to eq(landlord)
        end

        it 'and tenant' do
          expect(@result.tenant).to eq(tenant)
        end

        it 'about property' do
          expect(@result.property).to eq(property)
        end        

        it 'should be valid' do
          expect(@result).to be_valid
        end

        it 'should not be persisted' do
          expect(@result).to_not be_persisted
        end
      end
    end

    context 'two conversations between tenant and landlord' do
      before do
        landlord.property = property
        @conversation = clazz.create tenant: tenant, landlord: landlord
        @conversation2 = clazz.create tenant: tenant, landlord: landlord
      end

      describe 'latest' do
        let(:latest) { Talk::Property::Conversation.latest }

        it 'should return latest first' do          
          latest.first.created_at.should > latest.last.created_at
        end
      end

      describe 'oldest' do
        let(:oldest) { Talk::Property::Conversation.oldest }

        it 'should return oldest first' do          
          oldest.first.created_at.should < oldest.last.created_at
        end
      end

      describe 'between' do
        before do
          landlord.property = property
          @result = clazz.between tenant, landlord
        end

        it 'should return conversations between tenant and landlord' do
          expect(@result.first).to eq(@conversation)
        end
      end

      describe 'create_between' do
        before do
          @result = clazz.create_between tenant, landlord
        end

        it 'should return conversations between tenant and landlord' do
          expect(@result).to eq(@conversation)
        end
      end

      describe 'init_between' do
        before do
          @result = clazz.init_between tenant, landlord
        end

        it 'should return the conversations between tenant and landlord' do
          expect(@result).to eq(@conversation)
        end
      end
    end
  end
end