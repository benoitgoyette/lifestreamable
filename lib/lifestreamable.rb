$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require File.join(File.dirname(__FILE__),'lifestreamable/lifestreamable')
require File.join(File.dirname(__FILE__),'lifestreamable/lifestreamed')

module Lifestreamable
  VERSION = '0.0.1'
end