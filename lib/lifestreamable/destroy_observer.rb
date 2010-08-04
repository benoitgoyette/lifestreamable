module Lifestreamable
  class DestroyObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def before_destroy(model)
      if model.lifestreamable?(:destroy)
        Lifestreamable::Lifestreamer.push model.get_action_instead_of(:destroy), model.get_payload
      end
    end
  end
end
