# require 'YAML'
module Lifestreamable
  class Lifestream < ActiveRecord::Base
    belongs_to :owner
    belongs_to :object, :polymorphic => true


    def object_data
      YAML.parse(self.object_data_hash)
    end
    alias_method :object_hash, :object_data

    # TODO AJOUTER LE FILTER
    

    class << self
      def find_by_reference_type_and_reference_id_and_stream_type(reference_type, reference_id, stream_type)
        find(:last, :conditions=>["reference_type = ? and reference_id = ? and stream_type = ?", reference_type, reference_id,  stream_type])
      end

      #
      # CREATION DU LIFESTREAM
      #
      def process(action, struct)
        # put explicitly the actions accepted
        case action
          when :create
            create hash_from_struct(struct)
          when :update
            l = Lifestream.find_by_reference_type_and_reference_id_and_stream_type(struct.reference_type, struct.reference_id, struct.stream_type)
            l.update_attributes hash_from_struct(struct) unless l.blank?
          when :destroy
            l = Lifestream.find_by_reference_type_and_reference_id_and_stream_type(struct.reference_type, struct.reference_id, struct.stream_type)
            l.destroy unless l.blank?
          else
            raise LifestreamableException.new "unknown action #{action} in Lifestreamable::Lifestream.process"
        end
      end

protected
      def hash_from_struct(struct)
        h = {}
        struct.each_pair {|k,v| h[k]=v}
        h
      end
    end
  end
end