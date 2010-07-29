module Lifestreamable
  class UpdateObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def after_update(model)
      if lifestreamable?(model)
        if create_instead_of_update?(model)
          Lifestreamable::Lifestreamer.push :create, get_data(model)
        elsif destroy_instead_of_update?(model)
          Lifestreamable::Lifestreamer.push :destroy, get_data(model)
        else
          Lifestreamable::Lifestreamer.push :update, get_data(model)
        end
      end
    end
  end
end