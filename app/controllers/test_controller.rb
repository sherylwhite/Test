class TestController < ApplicationController
  def start_worker
    MiddleMan.new_worker(:worker => :tps_worker, :worker_key => 'abc123')
    render :text => "Worker started!"
  end
  def stop_worker
    MiddleMan.worker(:tps_worker, 'abc123').delete
    render :text => "worker stopped!"
  end
  def status
    @percent_complete = MiddleMan.worker(:tps_worker, 'abc123').ask_result(:percent_complete)
    if request.xhr?
      if @percent_complete == 100
        render :update do |page|
          flash[:notice] = "Importing is completed"
          page.redirect_to :action=>"index"
        end
      else
        render :update do |page|
          page[:workingStatus].setStyle :width => "#{@percent_complete*4}px"
          page[:workingStatus].replace_html "#{@percent_complete}%"
        end
      end
    end
  end
end
