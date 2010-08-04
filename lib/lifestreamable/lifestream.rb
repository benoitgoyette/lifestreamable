module Lifestreamable
  class Lifestream < ActiveRecord::Base
    DEFAULT_LIMIT_PER_PAGE = 25
    DEFAULT_PAGE = 0
    
    belongs_to :owner, :polymorphic => true
    belongs_to :reference, :polymorphic => true


    def object_data
      YAML.load(self.object_data_hash)
    end
    alias_method :object_hash, :object_data

    class << self
      #
      # CREATION DU LIFESTREAM
      #
      def process(action, struct)
        # put explicitly the actions accepted
        puts "calling process #{action} #{struct.inspect}"
        case action
          when :create
            create get_payload(struct)
          when :update
            l = Lifestream.find_by_reference_type_and_reference_id_and_stream_type(struct.reference_type, struct.reference_id, struct.stream_type)
            l.update_attributes get_payload(struct) unless l.blank?
          when :destroy
            l = Lifestream.find_by_reference_type_and_reference_id_and_stream_type(struct.reference_type, struct.reference_id, struct.stream_type)
            l.destroy unless l.blank?
          else
            raise LifestreamableException.new "unknown action #{action} in Lifestreamable::Lifestream.process"
        end
      end


      # FINDERS 

      def find_by_reference_type_and_reference_id_and_stream_type(reference_type, reference_id, stream_type)
        find(:last, :conditions=>['reference_type = ? and reference_id = ? and stream_type = ?', reference_type, reference_id,  stream_type])
      end
      
      def find_lifestream_for_owner(owner, *options)
        opts = get_options_for_find owner, options[0]
        results = find :all, opts
      end

      def find_lifestream_for_group(owner, group, *options)
        opts = get_options_for_group_find owner, group, options[0]
        results = find :all, opts
      end

    protected

      def get_options_for_find(owner, options)
        opt = options.blank? ? {} : options.to_options
        set_basic_options!(opt)
        cond = get_condition_for_find(owner)
        opt[:conditions] = if opt[:conditions].blank?
          cond
        else
          cond[0]+= " AND #{opt[:conditions][0]}"
          cond += opt[:conditions][1..-1]
          cond
        end
        opt
      end
      
      def get_options_for_group_find(owner, group, options)
        opt = options.blank? ? {} : options.to_options
        set_basic_options!(opt)
        cond = get_condition_for_group_find(owner, group)
        opt[:conditions] = if opt[:conditions].blank?
          cond
        else
          cond[0]+= " AND #{opt[:conditions][0]}"
          cond += opt[:conditions][1..-1]
          cond
        end
        opt
      end
      
      def set_basic_options!(opt)
        opt[:limit]=opt[:per_page] ? opt.delete(:per_page) : DEFAULT_LIMIT_PER_PAGE
        opt[:offset]=opt[:page] ? (opt.delete(:page)-1)*opt[:limit] : DEFAULT_PAGE
        opt[:order]=opt[:order] ? opt[:order] : 'id desc'
      end

      def get_condition_for_find(owner)
        ['owner_type = ? and owner_id = ? ', owner.class.name, owner.id]
      end
      
      def get_condition_for_group_find(owner, group)
        ['owner_type = ? and owner_id in (?) ', owner.class.name, [owner.id] + group]
      end
      
      def get_payload(struct)
        hash_from_struct(struct)
      end
    
      def hash_from_struct(struct)
        h = {}
        struct.each_pair {|k,v| h[k.to_sym]=v}
        h
      end
    
    end
  end
end