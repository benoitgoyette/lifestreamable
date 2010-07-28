module Lifestreamable
  class DestroyObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def before_destroy(model)
      puts "CALLING LIFESTREAM_DESTROY_OBSERVER AFTER SAVE!!!!"
      
     # Lifestream.destroy_model_lifestream model
    end
  end
end
