module Account
  class System < Base
    include Singleton
    include BasicDocument

    field :name, default: 'system'

    def name= value
      raise ArgumentError, "Can only be system" unless value == 'system'
      super(value)
    end
  end
end