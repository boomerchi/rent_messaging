module BasicDocument
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document
    include ::Concerned
    mongoid_with :timestamps

    before_create :configure!

    after_update do
      set_defaults
    end    
  end

  module ClassMethods
    def defaults
      @defaults ||= []
    end

    def set_default context, fname, value = nil, &block
      raise ArgumentError, "Must take value" unless value || block_given?
      raise ArgumentError, "Must take field name" unless fname
      raise ArgumentError, "Must take context, either" unless contexts.include? context.to_sym

      meth_name = "set_default_#{context}_#{fname}"

      defaults << meth_name

      define_method meth_name do
        ctx = send(context)
        value = block_given? ? instance_eval(&block) : value 
        ctx.send("#{fname}=", value) if ctx.send(fname) == 0
      end
    end

    def delegate_fields *names
      options = names.extract_options!
      names.each do |name|
        delegate name, "#{name}=", to: options[:to]
      end
    end

    def monetize_for *names
      names.flatten.each do |name|
        field name, type: Integer, default: 0
      end
    end

    def mongoid_with *names

      # monetize_orm :mongoid if names.delete(:money)

      names.each do |name|      
        unless name.to_sym == :money
          self.send :include, "Mongoid::#{name.to_s.camelize}".constantize 
        end
      end
    end

    def configure &block
      define_method :configure, &block
    end
  end    

  def set_defaults
    self.class.defaults.each {|meth| send(meth) }
  end

  def configure!
    self.class.all_my_concerns.each do |concern|
      config_meth = "configure_#{concern}"
      send(config_meth) if respond_to? config_meth
    end
    configure if respond_to? :configure
  end
end
