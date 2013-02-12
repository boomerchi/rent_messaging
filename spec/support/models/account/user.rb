module Account
  class User < Base
    include BasicDocument
    
    field :name
  end
end
