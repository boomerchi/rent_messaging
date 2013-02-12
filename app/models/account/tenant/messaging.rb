class Account::Tenant
  module Messaging
    extend ActiveSupport::Concern

    included do
      include ::Talk::Api::Tenant      
    end
  end
end

