require File.dirname(__FILE__) + '/../test_helper'
require 'wait_controller'

# Re-raise errors caught by the controller.
class WaitController; def rescue_action(e) raise e end; end

class WaitControllerTest < Test::Unit::TestCase
  def setup
    @controller = WaitController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
