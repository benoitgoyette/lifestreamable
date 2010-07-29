require File.dirname(__FILE__) + '/test_helper.rb'

class TestLifestreamable < Test::Unit::TestCase

  def setup
  end
  
  test "Create class" do
    assert Lifestream.new
    
  end
  

end
