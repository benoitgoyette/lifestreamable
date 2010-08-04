module Lifestreamable
  class CreateObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def after_create(model)
      if model.lifestreamable?(:create)
        Lifestreamable::Lifestreamer.push model.get_action_instead_of(:create), model.get_payload
      end
    end
  end
end