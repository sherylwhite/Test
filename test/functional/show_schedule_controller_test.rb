require File.dirname(__FILE__) + '/../test_helper'
require 'show_schedule_controller'

# Re-raise errors caught by the controller.
class ShowScheduleController; def rescue_action(e) raise e end; end

class ShowScheduleControllerTest < Test::Unit::TestCase
  def setup
    @controller = ShowScheduleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
