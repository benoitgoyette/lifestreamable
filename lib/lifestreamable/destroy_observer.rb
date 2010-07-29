module Lifestreamable
  class DestroyObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def before_destroy(model)
      puts "CALLING LIFESTREAM_DESTROY_OBSERVER AFTER SAVE!!!!"
      if lifestreamable?(model)
        if create_instead_of_destroy?(model)
          Lifestreamable::Lifestreamer.push :create, get_data(model)
        elsif update_instead_of_destroy?(model)
          Lifestreamable::Lifestreamer.push :update, get_data(model)
        else
          Lifestreamable::Lifestreamer.push :destroy, get_data(model)
        end
      end
    end
  end
end
