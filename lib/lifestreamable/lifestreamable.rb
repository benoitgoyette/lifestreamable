
# #############################################################
# #############################################################
# Pour le lifestream, on ajoute une methode a ActiveRecord::Base
# pour savoir si on doit effacer une entree du lifestream a la
# place de faire un update.
# comme dans le cas de detail.youtube_username, si on efface
# la valeur, on veut effacer l'entree dans le lifestream.
# Meme chose pour l'insert, si on change le youtube user name,
# on veut que ca insere une nouvelle rangee dans le lifestream.
# #############################################################
# #############################################################

module Lifestreamable
  puts "loading module lifestreamable"
  
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    @@lifestream_options={}
  
    def lifestream_options
      @@lifestream_options
    end
    
    def lifestreamable(options)
      include InstanceMethods

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
      @@lifestream_options = {:data=>options[:data], :on=>options[:on], :type=>options[:type], :owner=>options[:owner], :when=>options[:when], :filter=>options[:filter]
        :destroy_instead_of_update=>options[:destroy_instead_of_update], :create_instead_of_update=>options[:create_instead_of_update],
        :create_instead_of_destroy=>options[:create_instead_of_destroy], :update_instead_of_destroy=>options[:update_instead_of_destroy]}
    end
    
  end
  
  module InstanceMethods
    def lifestream_options
      self.class.lifestream_options
    end
    
  end
end

ActiveRecord::Base.observers << :"lifestreamable/update_observer"
ActiveRecord::Base.observers << :"lifestreamable/create_observer"
ActiveRecord::Base.observers << :"lifestreamable/destroy_observer"
ActiveRecord::Base.send(:include, Lifestreamable)