module Lifestreamable
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