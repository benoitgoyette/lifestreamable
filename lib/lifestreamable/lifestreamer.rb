module Lifestreamable
  # :title: module Lifestreamable::Lifestreamer
  # Module that generates the lifestream. this is done as an after_filter that is added to ActionController::Base.
  # Hence any action that is called in the controller will call this function afterwards. 
  # The Lifestreamable::Lifestreamer.generate_lifestream has a very small footprint when it has nothign to do. 
  #
  # TODO, include support for delayed_jobs to do it asynchronously
  module Lifestreamer
    @@stack=[]
    def self.push(action, lifestream_struct)
      @@stack.push [action, lifestream_struct]
      @@stack.uniq!
    end
    def self.generate_lifestream
      while (lifestream_entry=@@stack.shift)
        begin
          Lifestream.process(lifestream_entry[0], lifestream_entry[1])
        rescue Exception => e
          puts e.message, e.backtrace
          # TODO PUT SOMETHING HERE!!!
        end
      end
    end
    def self.clear
      @@stack.clear
    end
    def self.inspect
      @@stack.inspect
    end
  end
end
ActionController::Base.send(:after_filter, "Lifestreamable::Lifestreamer.generate_lifestream")