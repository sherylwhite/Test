require File.dirname(__FILE__) + '/../../bdrb_test_helper'
class TpsBgrb < Test::Unit::TestCase
  def start_workder    
    MiddleMan.new_worker(:worker => :tps_worker, :worker_key => 'abc123')
    puts "Worker started!"
  end
  def stop_worker
    MiddleMan.worker(:tps_worker, 'abc123').delete
    render :text => "worker deleted"
  end
end