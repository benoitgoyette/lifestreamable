module Lifestreamable
  class UpdateObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def after_update(model)
      puts "CALLING LIFESTREAM_UPDATE_OBSERVER AFTER SAVE!!!!"
      if model.lifestreamable?
        Lifestreamable::Lifestreamer.push model.lifestream_type.to_sym => model
      end
    end
  end
end