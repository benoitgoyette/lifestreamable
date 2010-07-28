module Lifestreamable
  class Observer < ActiveRecord::Observer
    def add_class_observer(klass)
      self.add_observer!(klass)
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

