# :title: Lifestreamable
# == DESCRIPTION:
# 
# Lifestreamable is a rails gem that allows social network life lifestream operations. A lifestream is a series of events that occured and that are related to an owner.
# It has been designed to collect data upfront in model observers to minimize the number of request done at display time. the goal being that if the lifestream dislays several types of data over several different models, then only a single query will be run to get all the data to display instead of querying all data for each model. this radiaclly cuts down on display time.
# This is a port to a gem of the lifestream libraries that have been designed for the sports social network legrandclub.rds.ca
# 
# == INSTALLATION:
# * gem install lifestreamable
# * script/generate lifestreamable_migration
#
# == SYNOPSIS:
# 
# Ths lifestream modules is made up of 2 mixins, the lifestreamable, and lifestreamed modules.
# The lifestreamed module is included for models that own events, while the lifestreamable module is included on each model that triggers the event.
# 
# for example, a user can write posts and comments, we want to report in the user's lifestream that the user has written posts and comments.
# 
# defining the owner class
#     class User < ActiveRecord::Base
#         lifestreamed :order=>'id asc'     # <= overrides the normal order which is 'id desc'
#     end
# 
# defining the event classes
#     class Post < ActiveRecord::Base
#         belongs_to :user
#         has_many :comments
#         lifestreamable :on=>[:create, :update, :destroy], data=>:get_data, :owner=>:user
#     
#         def get_data   # this method must return a data structure that is serializable by YAML
#             {
#                 :user=>{:firstname=>self.user.firstname, :lastname=>self.user.lastname},
#                 :post=>{:title=>self.title}
#             }
#         end
#     end
# 
#     class Comment < ActiveRecord::Base
#         belongs_to :user
#         belongs_to :post
#         # another way to get the data is through a Proc
#         lifestreamable :on=>[:create, :update, :destroy], :owner=>:user, data=> lambda {|model| 
#                     {
#                         :user=>{:firstname=>model.user.firstname, :lastname=>model.user.lastname},
#                         :post=>{:title=>model.post.title},
#                         :comment=>{:body=>model.body}
#                     }
#                 }
#     end
# 
# Whenever a new post is created, it will create a new entry in the lifestream model. To get the lifestream from the owner:
#     user=User.first
# 
#     # get the lifestream for the user
#     lifestream = user.lifestream  #=> returns an array of Lifestreamable::Lifesteam model instances
#     
#     #get the data that was stored 
#     data = lifestream.first.object_data
#     
# 
# == module Lifestreamable 
#
# module for models that trigger lifestream events.
#
# == Usage:
#   class Post < ActiveRecord::Base
#     belongs_to :user
#     lifestreamable :on=>[:create, :update, :destroy], :data=>:get_data, :owner=>:user
#
#     def get_data  # we gather the data here, while we have all this data loaded to avoid having to fetch the models when we'll display the lifestream
#       {:post => {:title => this.title}, :user => {:first_name => self.user.firstname, :last_name => self.user.last_name}}
#     end
#   end
#
# == Options
# Note, when using Proc for the options, the model that triggers the event is always passed to the Proc.
# ex. Proc.new {|model| ... }
# 
# *  :data => Required,  Proc or function name to call to get the data that needs to be lifestreamed, the data should be in a type that is serializable by YAML (Hash, Array and Struct are good)
# *  :on => Required, Array of events that trigger the insertion into the lifestream, acceptable values are: :create, :update, :destroy 
# *  :owner => Required, a String, Symbol, Proc or function name that returns the name of the owner of this event, i.e. the user that triggered the event.
# *  :type => An identifier that represent the type of lifestream that is generated. this is useful when displaying the lifestream to select the view that will be used to display the lifestream event. Can be a String, Symbol, Proc or function name.
# *  :when => An identifier that specifies if the event should be logged. Can be true, false, a Proc or a function name. A method receives the action that triggers the event. the Proc receives the model and the event. Useful in combination with the :on=>[:update] option, we will want to update the lifestream if only a specific field is modified, but not the others.
#         :when=>Proc.new {|model, action| if action == :update ...  }
#         :when=>:when_function
#         def when_function(action)
#           ...
#         end
# *  :filter => A STATIC function that will specify how to filter the data at display time, it may be necessary to remove some data when displaying the lifestream, for example 1- Bob is now friend with Bill and 2- Bill is now friend with Bob, we may want to remove one of the two events. A Proc or function name.
# *  :destroy_instead_of_update => Specifies if the last entry should be destroyed in the lifestream when an :update event is triggered. can be true, false, a Proc or a function name.
# *  :create_instead_of_update => Specifies if a new entry should be created in the lifestream when an :update event is triggered. can be true, false, a Proc or a function name.
# *  :create_instead_of_destroy => Specifies if a new entry should be created in the lifestream when a :destroy event is triggered. can be true, false, a Proc or a function name.
# *  :update_instead_of_destroy => Specifies if a the last entry should be updated in the lifestream when a :destroy event is triggered. can be true, false, a Proc or a function name.
#
#
# == Usage with all options
#   class Post < ActiveRecord::Base
#     belongs_to :user
#     lifestreamable :on=>[:create, :update, :destroy], 
#                    :data => :get_data, 
#                    :owner => :user,
#                    :type => 'Post',
#                    :when => lambda {|model, action|   # when something else than updated_at changes
#                        if action==:update 
#                          (model.changed-['updated_at']).size > 0 
#                        else
#                          true
#                        end
#                      },   
#                    :filter => :lifestream_filter,
#                    :destroy_instead_of_update => Proc.new { |model| model.changed.include?('title') },
#                    :create_instead_of_update => lambda { |model| model.changed.include?('body') },
#                    :create_instead_of_destroy => false,
#                    :update_instead_of_destroy => :false  # this is good also, and so is 'false'
#
#     def get_data     # => we gather the data here, while we have all this data loaded to avoid having to fetch the models when we'll display the lifestream
#       {:post => {:title => this.title}, :user => {:first_name => self.user.firstname, :last_name => self.user.last_name}}
#     end
#
#     def self.lifestream_filter(lifestream)     # <= Note this is a static function
#       #remove all similar events
#        types={}
#        lifestream = lifestream.collect do |l|
#          unless types[l.stream_type]
#            types[l.stream_type]=true
#            l
#          else
#            nil
#          end
#        end
#        lifestream.compact
#     end
#
#   end
#
# == NOTICE
# the insertion into the lifestream is done as an after filter in the controller. when debigging in the console, you may want to generate the lifestream, in this case, call Lifestreamable::Lifestreamer.generate_lifestream

module Lifestreamable
  Struct.new('LifestreamData', :reference_type, :reference_id, :owner_type, :owner_id, :stream_type, :object_data_hash)
  TRUE_REGEX = /^[tT][rR][uU][eE]$/
  FALSE_REGEX =  /^[fF][aA][lL][sS][eE]$/
  ACCEPTABLE_OPTIONS = [:data, :on, :owner, :type, :when, :filter, :destroy_instead_of_update, :create_instead_of_update, :create_instead_of_destroy, :update_instead_of_destroy]
  REQUIRED_OPTIONS = [:data, :on, :owner]
  
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

      unknown_keys = options.keys - ACCEPTABLE_OPTIONS
      unless unknown_keys.blank?
        raise LifestreamableException.new("Unknown keys for lifestreamable #{unknown_keys.inspect}") 
      end

      required_keys = REQUIRED_OPTIONS - options.keys
      unless required_keys.blank?
        raise LifestreamableException.new("Some requires option for lifestreamable are missing #{required_keys.inspect}") 
      end

      options[:on].to_a.each do |option_on|
        case option_on
          when :update
            Lifestreamable::UpdateObserver.instance.add_class_observer self.class_name.constantize
          when :create
            Lifestreamable::CreateObserver.instance.add_class_observer self.class_name.constantize
          when :destroy
            Lifestreamable::DestroyObserver.instance.add_class_observer self.class_name.constantize
          else
            raise LifestreamableException.new("option \"#{option_on}\" is not supported for Lifestreamable")
        end
      end
      ACCEPTABLE_OPTIONS.each {|k| @@lifestream_options[k]=options[k] } 

    end
    
    def filter(lifestream)
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

    def lifestreamable?(action)
      case self.lifestream_options[:when]
        when NilClass, TrueClass, :true, TRUE_REGEX
          true
        when FalseClass, :false, FALSE_REGEX
          false
        when Proc
          self.lifestream_options[:when].call(self, action)
        when String, Symbol
          send(self.lifestream_options[:when].to_s, action)
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

class LifestreamableException < Exception
end

ActiveRecord::Base.observers << :"lifestreamable/update_observer"
ActiveRecord::Base.observers << :"lifestreamable/create_observer"
ActiveRecord::Base.observers << :"lifestreamable/destroy_observer"
ActiveRecord::Base.send(:include, Lifestreamable)

