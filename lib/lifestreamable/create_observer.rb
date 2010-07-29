module Lifestreamable
  class CreateObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def after_create(model)
      if lifestreamable?(model)
        Lifestreamable::Lifestreamer.push :create, get_data(model)
      end
    end
  end
end