# Pour le lifestream, on ajoute une methode a ActiveRecord::Base
# pour savoir si on doit effacer une entree du lifestream a la
# place de faire un update.
# comme dans le cas de detail.youtube_username, si on efface
# la valeur, on veut effacer l'entree dans le lifestream.
# Meme chose pour l'insert, si on change le youtube user name,
# on veut que ca insere une nouvelle rangee dans le lifestream.

module Lifestreamable
  Struct.new('LifestreamData', :reference_type, :reference_id, :owner_type, :owner_id, :stream_type, :object_data_hash)
  TRUE_REGEX = /^[tT][rR][uU][eE]$/
  FALSE_REGEX =  /^[fF][aA][lL][sS][eE]$/
  
  def self.included(base)
    base.extend LifestreamableClassMethods
  end

  module LifestreamableClassMethods
    @@lifestream_options={}
  
    def lifestream_options
      @@lifestream_options
    end
    
    def lifestreamable(options)
      include LifestreamableInstanceMethods

      options.to_options
      options[:on].each do |option_on|
        case option_on
          when :update
            Lifestreamable::UpdateObserver.instance.add_class_observer self.class_name.constantize
          when :create
            Lifestreamable::CreateObserver.instance.add_class_observer self.class_name.constantize
          when :destroy
            Lifestreamable::DestroyObserver.instance.add_class_observer self.class_name.constantize
          else
            raise Exception.new("option \"#{option_on}\" is not supported for Lifestreamable")
        end
      end
      @@lifestream_options = {:data=>options[:data], :on=>options[:on], :type=>options[:type], :owner=>options[:owner], :when=>options[:when], :filter=>options[:filter],
        :destroy_instead_of_update=>options[:destroy_instead_of_update], :create_instead_of_update=>options[:create_instead_of_update],
        :create_instead_of_destroy=>options[:create_instead_of_destroy], :update_instead_of_destroy=>options[:update_instead_of_destroy]}
    end
    
    def filter(lifestream)
      puts "in lifestreamable.filter"
      option = self.lifestream_options[:filter]
      lifestream = case option
        when Proc
          option.call(self, lifestream)
        when String, Symbol
          send(option.to_s, lifestream) if respond_to?(option.to_s)
        else
          lifestream
      end 
      lifestream
    end

  end

  module LifestreamableInstanceMethods
    def lifestream_options
      self.class.lifestream_options
    end

    def lifestreamable?
      case self.lifestream_options[:when]
        when NilClass, TrueClass, :true, TRUE_REGEX
          true
        when FalseClass, :false, FALSE_REGEX
          false
        when Proc
          self.lifestream_options[:when].call(self)
        when String, Symbol
          send(self.lifestream_options[:when].to_s)
      end 
    end
    
    def get_payload
      reference_type, reference_id = get_reference
      owner_type, owner_id = get_owner
      stream_type = get_stream_type
      data = get_lifestream_data.to_yaml
      Struct::LifestreamData.new reference_type, reference_id, owner_type, owner_id, stream_type, data   
    end
    
    def get_action_instead_of(action)
      case action
        when :create
          :create
        when :update
          if test_instead_option(lifestream_options[:create_instead_of_update])
            :create
          elsif test_instead_option(lifestream_options[:destroy_instead_of_update]) 
          :destroy 
          else
            :update
          end
        when :destroy
          if test_instead_option(lifestream_options[:create_instead_of_destroy])
            :create 
          elsif test_instead_option(lifestream_options[:destroy_instead_of_destroy])
            :update 
          else  
            :destroy
          end
        else
          raise LifestreamableException.new("The action #{action.to_s} is not a valid type of action")
      end
    end

protected    
    # if the option[:when] is not defined, then it's considered true
    def get_reference
      [self.class.name, self.id]
    end

    def get_owner
      return_vals = case self.lifestream_options[:owner]
        when Proc
          self.lifestream_options[:owner].call(self)
        when String, Symbol
          send(self.lifestream_options[:owner].to_s)
        else
          raise LifestreamableException.new("The lifestreamable :owner option is invalid")
      end 
      
      case return_vals
        when NilClass
          LifestreamableException.new("The lifestreamable :owner option Proc must return either an ActiveRecord::Base subclass or an array of [class_name, id]") 
        when Array
          if return_vals.length == 1
            if return_vals.is_a?(ActiveRecord::Base)
              return [return_vals.class.name, return_vals.id] 
            else
              LifestreamableException.new("The lifestreamable :owner option Proc evaluation returned only 1 value, but it's not an ActiveRecord::Base") 
            end
          else
            return_vals[0,2]
          end
        when ActiveRecord::Base
          return [return_vals.class.name, return_vals.id] 
      end
    end
    
    def get_stream_type
      case self.lifestream_options[:type]
        when NilClass
          self.class.name.underscore
        when Proc
          self.lifestream_options[:type].call(self)
        when String, Symbol
          if self.respond_to?(self.lifestream_options[:type].to_s)
            send(self.lifestream_options[:type].to_s)
          else
            self.lifestream_options[:type].to_s
          end
        else
          raise LifestreamableException.new("The lifestreamable :type option is invalid")
      end 
    end
    
    def get_lifestream_data
      case self.lifestream_options[:data]
        when Proc
          self.lifestream_options[:data].call(self)
        when String, Symbol
          send(self.lifestream_options[:data].to_s)
        else
          raise LifestreamableException.new("The lifestreamable :data option is invalid")
      end 
    end
    
private
    def test_instead_option(option)
      case option
        when NilClass, FalseClass, :false, FALSE_REGEX
          false
        when TrueClass, :true, TRUE_REGEX
          true
        when Proc
          option.call(self)
        when String, Symbol
          send(option.to_s)
      end == true  # make sure we return true/false
    end
  end
end

ActiveRecord::Base.observers << :"lifestreamable/update_observer"
ActiveRecord::Base.observers << :"lifestreamable/create_observer"
ActiveRecord::Base.observers << :"lifestreamable/destroy_observer"
ActiveRecord::Base.send(:include, Lifestreamable)