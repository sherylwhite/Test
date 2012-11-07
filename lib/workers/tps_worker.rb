class TpsWorker < BackgrounDRb::MetaWorker
  include StaffHelper
  set_worker_name :tps_worker
  set_no_auto_load(true)
  
  def create(args = nil)
    logger.info "Worker started"
    
    excel_init("public/files/StaffDetails.xls")
    # test whether the the excel_init function recognized the columns correctly 
  
    logger.info "Finish excel init procedure"
    import
    logger.info "Finish import data"
  end
  
  def import
    semester_regions = recognize_semesters()
    logger.info semester_regions.size
    Thread.new do
      # go through each region iteratively.
      0.upto(semester_regions.size - 2) do |current_region|
        cache[:percent_complete] = ((current_region+1)*100)/(semester_regions.size - 1)
        process_region(semester_regions[current_region], semester_regions[current_region+1])
        sleep(0.1)
      end
    end
  end
end

