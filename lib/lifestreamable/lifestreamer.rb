module Lifestreamable
  module Lifestreamer
    @@stack=[]
    def self.push(hash)
      @@stack.push hash
      @@stack.uniq!
    end
    def self.generate_lifestream
      while (hash=@@stack.shift)
        begin
          puts "LIFESTREAMER::GENERATE_LIFESTREAM  #{hash.inspect}"
          Lifestream.create_model_lifestream hash
        rescue Exception => e
          puts e.message, e.backtrace
          # PUT SOMETHING HERE!!!
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