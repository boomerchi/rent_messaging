module Account
  class System
    include BasicDocument

    include_concerns :messaging # system specific    
  end
end