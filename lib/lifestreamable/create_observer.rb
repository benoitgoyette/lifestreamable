module Lifestreamable
  class CreateObserver < Lifestreamable::Observer
    observe :"lifestreamable/dummy"
    def after_create(model)
      puts "CALLING LIFESTREAM_CREATE_OBSERVER AFTER SAVE!!!!"
      if model.lifestreamable?
        Lifestreamable::Lifestreamer.push model.lifestream_type.to_sym => model
      end
    end
    def add_class_observer(klass)
      self.add_observer!(klass)
    end
  end
end