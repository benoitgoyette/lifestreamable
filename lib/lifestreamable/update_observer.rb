module Lifestreamable
  class UpdateObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def after_update(model)
      if model.lifestreamable?(:update)
        Lifestreamable::Lifestreamer.push model.get_action_instead_of(:update), model.get_payload
      end
    end
  end
end

