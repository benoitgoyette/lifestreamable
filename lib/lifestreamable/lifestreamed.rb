module Lifestreamable
  module Lifestreamed
    def self.included(base)
      base.extend LifestreamedClassMethods
    end

    module LifestreamedClassMethods
      @@lifestreamed_options={}

      def lifestreamed_options
        @@lifestream_options
      end
  
      def lifestreamed(*options)
        include InstanceMethods
        @@lifestreamed_options = options[0].to_options.clone if options[0]
      end
    end

    module LifestreamedInstanceMethods
      def lifestreamed_options
        self.class.lifestreamed_options
      end
    end
  end
end
ActiveRecord::Base.send(:include, Lifestreamable::Lifestreamed)
