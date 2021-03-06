module Izzle
  module ModelSettings
    class Configurator
      
      attr_accessor :definitions, :aliases
      
      def initialize(klass, name, options)
        @klass = klass
        @name = name
        @definitions = {}
        
        @aliases = []
        if options.has_key?(:aliases)
          @aliases = options[:aliases]
        elsif options.has_key?(:alias)
          @aliases = [options[:alias]]
        end
        @aliases = @aliases.collect{ |a| a.to_s }
      end
      
      def define(name, options = {})
        name = Helpers.normalize(name)
        raise ArgumentError, "class #{@klass} model_settings('#{@name}') already defines '#{name}'" if @definitions.has_key?(name)
        @definitions[name] = Definition.new(name, options)
      end
      
      def do_metaprogramming_magic_aka_define_methods
        
        model_setting_accessors, object_accessors = [], []
        @definitions.values.each do |definition|
          
          model_setting_accessors << <<-end_eval
            def #{@name}_#{definition.name}=(value)
              set_model_setting('#{@name}', '#{definition.name}', value, true)
            end
            def #{@name}_#{definition.name}
              get_model_setting('#{@name}', '#{definition.name}', true)
            end
            def #{@name}_#{definition.name}?
              !!get_model_setting('#{@name}', '#{definition.name}', true)
            end
          end_eval
          
          object_accessors << <<-end_eval
            def #{definition.name}=(value)
              proxy_owner.set_model_setting('#{@name}', '#{definition.name}', value)
            end
            def #{definition.name}
              proxy_owner.get_model_setting('#{@name}', '#{definition.name}')
            end
            def #{definition.name}?
              !!proxy_owner.get_model_setting('#{@name}', '#{definition.name}')
            end
          end_eval
        end
        
        method_aliases = @aliases.inject([]) do |memo, alias_name|
          memo << "alias_method :#{alias_name}, :#{@name}"
          @definitions.values.each do |definition|
            memo << "alias_method :#{alias_name}_#{definition.name}=, :#{@name}_#{definition.name}="
            memo << "alias_method :#{alias_name}_#{definition.name},  :#{@name}_#{definition.name}"
            memo << "alias_method :#{alias_name}_#{definition.name}?, :#{@name}_#{definition.name}?"
          end
          memo
        end
        
        @klass.class_eval <<-end_eval
          # first define the has many relationship
          has_many :#{@name}, :class_name => 'ModelSetting',
                              :as => :model,
                              :extend => AssocationExtension,
                              :dependent => :destroy do
            #{object_accessors.join("\n")}
          end
          
          # now define the model setting accessors
          #{model_setting_accessors.join("\n")}
          
          # define the aliases
          #{method_aliases.join("\n")}
        end_eval
        
      end
      
    end
  end
end
