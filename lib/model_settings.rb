require 'model_settings/association_extension'
require 'model_settings/configurator'
require 'model_settings/definition'
require 'model_settings/errors'
require 'model_settings/helpers'
require 'model_setting'

module Izzle
  
  module ModelSettings
    
    def self.included(klass)
      klass.extend ClassMethods
      klass.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      
      def model_settings(context = nil, options = {})
        context = Helpers.normalize(context)
        
        # initialize the class instance var to hold our configuration info
        class << self
          attr_accessor :model_settings_configurators unless method_defined?(:model_settings_configurators)
        end
        self.model_settings_configurators = {} if self.model_settings_configurators.nil?
        
        # don't let the user redefine a context
        raise ArgumentError, "class #{self} already model_settings('#{context}')" if self.model_settings_configurators.has_key?(context)
        
        
        
        configurator = Configurator.new(self, context, options)
        yield configurator
        configurator.do_metaprogramming_magic_aka_define_methods
        model_settings_configurators[context] = configurator
      end
      
    end
    
    module InstanceMethods
      
      def set_model_setting(context, name, value, do_preprocess = false)
        context = Helpers.normalize(context)
        name = Helpers.normalize(name)
        
        # TODO dry this shit out, it's a copy/paste job with get_model_setting
        
        # check to make sure the context exists
        raise ArgumentError, "model_settings('#{context}') is not defined for class #{self.class}" \
          unless self.class.model_settings_configurators.has_key?(context)
        configurator = self.class.model_settings_configurators[context]
        
        # check to make sure the name of the thing exists
        raise ArgumentError, "'#{name}' not defined for model_settings('#{context}') for class #{self.class}" \
          unless configurator.definitions.has_key?(name)
        definition = configurator.definitions[name]
        
        # do preprocess here, type_check and validate can be done as AR validation in ModelSetting
        value = definition.preprocess.call(value) if do_preprocess and definition.has_preprocess
        
        # invoke the assocation
        things = send(context)
        
        # if thing already exists, update it, otherwise add a new one
        thing = things.detect{ |thing| thing.name == name }
        if thing.blank?
          thing = ModelSetting.new :context => context,
                                   :name => name,
                                   :value => value
          thing.set_model_target(self) # for the bug regarding thing's validation trying to invoke the 'model' assocation when self is a new record
          send("#{context}").send("<<", thing)
        else
          thing.value = value
        end
        
        thing.value
        
      end
      
      def get_model_setting(context, name, do_postprocess = false)
        context = Helpers.normalize(context)
        name = Helpers.normalize(name)
        
        # check to make sure the context exists
        raise ArgumentError, "model_settings('#{context}') is not defined for class #{self.class}" \
          unless self.class.model_settings_configurators.has_key?(context)
        configurator = self.class.model_settings_configurators[context]
        
        # check to make sure the name of the thing exists
        raise ArgumentError, "'#{name}' not defined for model_settings('#{context}') for class #{self.class}" \
          unless configurator.definitions.has_key?(name)
        definition = configurator.definitions[name]
        
        # invoke the association
        things = send(context)
        
        # try to find what they are looking for
        thing = things.detect{ |thing| thing.name == name }
        
        # if the thing isn't found, try to fallback on a default
        if thing.blank?
          # TODO break all these nested if statements out into helper methods, i like prettier code
          # TODO raise an exception if we don't respond to default_through or the resulting object doesn't respond to the context
          if definition.has_default_through and respond_to?(definition.default_through) and (through = send(definition.default_through)).blank? == false
            value = through.send(context)[name]
          elsif definition.has_default_dynamic
            if definition.default_dynamic.instance_of?(Proc)
              value = definition.default_dynamic.call(self)
            else
              # TODO raise an exception if we don't respond to default_dynamic
              value = send(definition.default_dynamic)
            end
          elsif definition.has_default
            value = Marshal::load(Marshal.dump(definition.default)) # BUGFIX deep cloning default values
          else
            value = nil
          end
        else
          value = thing.value
        end
        
        value = definition.postprocess.call(value) if do_postprocess and definition.has_postprocess
        value
      end
      
    end
    
  end
  
end
