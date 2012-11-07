require File.dirname(__FILE__) + '/../test_helper'
require 'staff2_controller'

# Re-raise errors caught by the controller.
class Staff2Controller; def rescue_action(e) raise e end; end

class Staff2ControllerTest < Test::Unit::TestCase
  def setup
    @controller = Staff2Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
