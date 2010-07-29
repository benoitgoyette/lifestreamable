module Lifestreamable
  class Observer < ActiveRecord::Observer
    Struct.new('LifestreamData', :reference_type, :reference_id, :owner_type, :owner_id, :stream_type, :object_data_hash)
    
    def add_class_observer(klass)
      self.add_observer!(klass)
    end
    
    # if the option[:when] is not defined, then it's considered true
    def lifestreamable?(model)
      case model.lifestream_options[:when]
        when NilClass, TrueClass, :true, /[tT][rR][uU][eE]/
          true
        when FalseClass, :false, /[fF][aA][lL][sS][eE]/
          false
        when Proc
          model.lifestream_options[:when].call(model)
        when String, Symbol
          model.eval(model.lifestream_options[:when].to_s)
      end 
    end
    
    def get_reference(model)
      [model.class.name, model.id]
    end

    def get_owner(model)
      return_vals = case model.lifestream_options[:owner]
        when Proc
          model.lifestream_options[:owner].call(model)
        when String, Symbol
          model.eval(model.lifestream_options[:owner].to_s)
        else
          raise LifestreamableException.new("The lifestreamable :owner option is invalid")
      end 
      if return_vals.blank?
        LifestreamableException.new("The lifestreamable :owner option Proc must return either an ActiveRecord::Base subclass or an array of [class_name, id]") 
      elsif return_vals.length == 1
        if return_vals.is_a?(ActiveRecord::Base)
          return [return_vals.class.name, return_vals.id] 
        else
          LifestreamableException.new("The lifestreamable :owner option Proc evaluation returned only 1 value, but it's not an ActiveRecord::Base") 
        end
      else
        return_vals[0,2]
      end
    end
    
    def get_stream_type(model)
      case model.lifestream_options[:type]
        when NilClass
          model.class.name.underscore
        when Proc
          model.lifestream_options[:type].call(model)
        when String, Symbol
          if model.respond_to?(model.lifestream_options[:type].to_s)
            model.eval(model.lifestream_options[:type].to_s)
          else
            model.lifestream_options[:type].to_s
          end
        else
          raise LifestreamableException.new("The lifestreamable :type option is invalid")
      end 
    end
    
    def get_lifestream_data(model)
      case model.lifestream_options[:data]
        when Proc
          model.lifestream_options[:data].call(model)
        when String, Symbol
          model.eval(model.lifestream_options[:data].to_s)
        else
          raise LifestreamableException.new("The lifestreamable :data option is invalid")
      end 
    end
    
    def get_data(model)
      reference_type, reference_id = get_reference(model)
      owner_type, owner_id = get_owner(model)
      stream_type = get_stream_type(model)
      data = get_lifestream_data(model).to_yaml
      Struct::LifestreamData.new reference_type, reference_id, owner_type, owner_id, stream_type, data   
    end
    
    def create_instead_of_destroy?(model)
      test_instead_option model.lifestream_options[:create_instead_of_destroy]
    end
    
    
    def update_instead_of_destroy?(model)
      test_instead_option model.lifestream_options[:update_instead_of_destroy]
    end
    
    def create_instead_of_update?(model)
      test_instead_option model.lifestream_options[:create_instead_of_update]
    end
    
    def destroy_instead_of_update?(model)
      test_instead_option model.lifestream_options[:destroy_instead_of_update]
    end

    def test_instead_option(option)
      case option
        when NilClass, FalseClass, :false, /[fF][aA][lL][sS][eE]/
          false
        when TrueClass, :true, /[tT][rR][uU][eE]/
          true
        when Proc
          model.lifestream_options[:when].call(model)
        when String, Symbol
          model.eval(model.lifestream_options[:when].to_s)
      end
    end
    
  end
  class Dummy 
    include Observable
    class << self
      def add_observer(*args)
      end
    end
  end
  
end

class LifestreamableException < Exception 
end
