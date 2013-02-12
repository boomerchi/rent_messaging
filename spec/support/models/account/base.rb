module Account
  class Base
    def type
      self.class.to_s.split('::').last.underscore
    end
  end
end