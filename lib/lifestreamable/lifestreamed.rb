module Lifestreamable
  module Lifestreamed
    def self.included(base)
      base.extend LifestreamedClassMethods
    end

    module LifestreamedClassMethods
      @@lifestreamed_options={}

      def lifestreamed_options
        @@lifestreamed_options
      end
  
      def lifestreamed(*options)
        include LifestreamedInstanceMethods
        @@lifestreamed_options = options[0].blank? ? {} : options[0].to_options.clone if options[0]
      end

    end

    module LifestreamedInstanceMethods
      def lifestreamed_options
        self.class.lifestreamed_options
      end
      
      def lifestream(*options)
        opt, do_filter = get_options_and_filter(options[0])
        lifestream = Lifestreamable::Lifestream.find_lifestream_for_owner(self, opt) 
        do_filter ? filter(lifestream) : lifestream
      end
      
      def group_lifestream(group, *options)
        opt, do_filter = get_options_and_filter(options[0])
        lifestream = Lifestreamable::Lifestream.find_lifestream_for_group(self, group, opt)
        do_filter ? filter(lifestream) : lifestream
      end
      
    private
    
      def get_options_and_filter(options)
        opt = options.blank? ? {} : options.to_options
        order_opt = get_order_option(opt.has_key?(:order) ? opt[:order] : self.lifestreamed_options[:order] )
        opt[:order]= order_opt unless order_opt.blank?
        filter_option = opt.has_key?(:filter) ? opt.delete(:filter) : self.lifestreamed_options[:filter]
        do_filter = get_filter_option( filter_option )
        [opt, do_filter]
      end

      def get_filter_option(option)
        puts "getting filter option"
        case option
          when NilClass, FalseClass, :false, Lifestreamable::FALSE_REGEX
            false
          when TrueClass, :true, Lifestreamable::TRUE_REGEX
            true
          when Proc # make sure we return true/false
            option.call(self) == true
          when String, Symbol  # make sure we return true/false
            send(option.to_s) == true
        end  
      end
      
      def get_order_option(option)
        case option
          when Proc
            option.call(self)
          when String, Symbol
            if self.respond_to?(option.to_s)
              send(option.to_s)
            else
              option.to_s
            end
        end 
      end
      
      def filter(lifestream)
        lf = lifestream.clone
        types = lf.collect {|l| l.reference_type}
        types.uniq!
        types.each {|l| 
          lf = l.constantize.filter(lf) if l.constantize.respond_to?('filter')}
        lf
      end
      
    end
  end
end
ActiveRecord::Base.send(:include, Lifestreamable::Lifestreamed)
