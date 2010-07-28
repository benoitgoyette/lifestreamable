
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

  #Methode pour modifier le contenu du lifestream avant l'affichage
  # toute classe qui veut filtrer le contenu peut le faire en
  #surchargeant cette classe.
  module ClassMethods
    @@lifestream_options={}
  
    def lifestream_options
      @@lifestream_options
    end
    
    def lifestreamable(options)
      include InstanceMethods
      
      options.to_options
      options_on = [options[:on]].flatten
      options_callback = options[:for]
      options_filter = options[:filter]
      options_order = options[:order] # either asc or desc

      options_on.each do |option_on|
        case option_on
          when :update
            Lifestreamable::UpdateObserver.instance.add_class_observer self.class_name.constantize
          when :create
            Lifestreamable::CreateObserver.instance.add_class_observer self.class_name.constantize
          when :destroy
            Lifestreamable::DestroyObserver.instance.add_class_observer self.class_name.constantize
          else
            raise Exception.new("option \"#{option_on}\" is not supported for Lifestream")
        end
      end
      
      @@lifestream_options = {:for=>options[:for], :filter=>options[:filter], :order=>options[:order], :on=>options_on }

    end
  end
  
  module InstanceMethods
    def lifestream_options
      self.class.lifestream_options
    end
    
    def delete_instead_of_update?(type)
      false
    end

    def insert_instead_of_update?(type)
      false
    end

    def <=>(a)
      # Ordre inverse!, on veut sorter a l'envers
      if @@lifestream_options[:order] == :desc
        a.created_at <=> self.created_at
      else
        self.created_at <=> a.created_at
      end

    end

    def lifestream_data(type)
      nil
    end

    def base_lifestream_data(type)
      data = {
        'stream_type' => type.to_s,
        'object' => self
      }
      if self.respond_to?(:profil_id)
        data.merge!('profil_id' => self.profil_id )
      elsif self.respond_to?(:profil)
        data.merge!('profil_id' => self.profil.id )
      else
        raise 'error, unable to find profil.id for lifestream in get_lifestream_data'
      end
      data
    end

    #Methode pour savoir dans quelle condition on doint entrer les donnees dans le lifestreams
    # si la methode n'est pas surchargee, rien n'est entree dans le lifestream
    def lifestreamable?
      true
    end

    def lifestream_type
      self.class.name.underscore.to_sym
    end
    
  end
end

ActiveRecord::Base.observers << :"lifestreamable/update_observer"
ActiveRecord::Base.observers << :"lifestreamable/create_observer"
ActiveRecord::Base.observers << :"lifestreamable/destroy_observer"
ActiveRecord::Base.send(:include, Lifestreamable)