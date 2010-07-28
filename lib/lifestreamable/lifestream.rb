# require 'YAML'
module Lifestreamable
  class Lifestream < ActiveRecord::Base
    belongs_to :owner
    belongs_to :object, :polymorphic => true


    def object_data
      YAML.parse(self.object_data_hash)
    end
    alias_method :object_hash, :object_data

    #
    # AFFICHAGE DU LIFESTREAM
    #

    def self.find_by_object_type_and_object_id_and_stream_type(object_type, object_id, stream_type)
      # return WillPaginate::Collection.new(1,1,0) {|c|[]} if Features.off?('lifestream','output')  #disable du lifestream
      # # on code la fonction pour eviter de tomber dans le method missing de RoR qui est plus lent
      # # en ordre de date de creation descendant, plus recent en premier.
      # return [] if Features.off?('lifestream', 'output')

      find(:first, :conditions=>["object_type = ? and object_id = ? and stream_type = ?", object_type, object_id,  stream_type])
    end

    def self.owner_stream(owner, page, per_page)
      order = 'id DESC'
      conditions = ["owner = ?", owner ]
      res = find(:all, :conditions=>conditions, :per_page=>per_page||LF_PER_PAGE, :offset=>(page*per_page)||0, :limit=>per_page, :order => order)
      filter(res)
    end

    #TODO revoir cette query avec la nouvelle colonne owner
    # def self.network_stream( network, page, per_page)
    #   order = 'id DESC'
    #   conditions = ["owner_id in (?)", network.collect(|o| o.id)]
    #   res = find(:all, :conditions=>conditions, :per_page=>per_page||LF_PER_PAGE, :offset=>(page*per_page)||0, :limit=>per_page, :order => order)
    #   filter(res)
    # end

    def self.filter(lifestream)
      lf = lifestream.clone
      types = lf.collect {|l| l.object_type}
      types.uniq!
      types.each {|l| lf = l.constantize.filter(lf) if l.constantize.respond_to?('filter')}
      lf
    end

    #
    # CREATION DU LIFESTREAM
    #
    def self.create_model_lifestream(hash)
      puts ">>>>>>> 1"
      type = hash.keys.shift
      puts ">>>>>>> 2"
      model = hash.values.shift
      puts ">>>>>>> 3 #{model.inspect}"
      # begin
      #   model.reload
      # rescue Exception=>e
      #   raise e
      #   puts ">>>>>>> #{e.message}"
      # end
      puts ">>>>>>> 4"
      ls_data = nil
      callback = model.lifestream_options[:for].to_s
      puts ">>>>>>> 5 #{callback} #{model.methods.sort.inspect}"
      # ls_data = model.lifestream_data(type) if model.respond_to?('lifestream_data')
      if model.respond_to?(callback)
      ls_data = model.instance_eval(callback) 
      end      
      puts ">>>>>>> 6"
      unless ls_data.blank?
        data = model.base_lifestream_data(type).merge(ls_data)
        puts ">>>>>>> 7"
        unless data.blank?
          data['object_data_hash'] = data['object_data_hash'].to_yaml
      puts ">>>>>>> 8"
          l = Lifestream.find_by_object_type_and_object_id_and_stream_type(object_type, object_id, data['stream_type'])
      puts ">>>>>>> 9"
          if l.blank? || model.insert_instead_of_update?(type)
            Lifestream.create(data)
      puts ">>>>>>> 10"
          else
            if model.delete_instead_of_update?(type)
              l.destroy
      puts ">>>>>>> 11"
            else
              l.update_attributes(data)
      puts ">>>>>>> 12"
            end
          end
        end
      end
    end

    def self.destroy_model_lifestream(hash)
      # return true  if Features.off?('lifestream','input')
      type = hash.keys.shift
      model = hash.values.shift
      if model.respond_to?('get_lifestream_data')
        data = model.get_lifestream_data(type)
        unless data.blank?
          object_type = data['object_type'] || data['object'].class.name
          object_id = data['object_id'] || data['object'].id
          l = Lifestream.find_by_object_type_and_object_id_and_stream_type(object_type, object_id, data['stream_type'])
          l.destroy unless l.blank?
        end
      end
    end

  end
end