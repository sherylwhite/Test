require File.dirname(__FILE__) + '/../test_helper'
require 'subject_list_controller'

# Re-raise errors caught by the controller.
class SubjectListController; def rescue_action(e) raise e end; end

class SubjectListControllerTest < Test::Unit::TestCase
  def setup
    @controller = SubjectListController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
