require File.dirname(__FILE__) + '/../test_helper'
require 'shared_code_controller'

# Re-raise errors caught by the controller.
class SharedCodeController; def rescue_action(e) raise e end; end

class SharedCodeControllerTest < Test::Unit::TestCase
  def setup
    @controller = SharedCodeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
