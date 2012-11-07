class Staff2Worker < BackgrounDRb::MetaWorker
  include Staff2Helper
  set_worker_name :staff2_worker
  set_no_auto_load(true)
  
  def create(args = nil)
    logger.info "Worker started"
    
    excel_init("public/files/SubjectGroup.xls");
    # test whether the the excel_init function recognized the columns correctly 
  
    logger.info "Finish excel init procedure"
    import
    logger.info "Finish import data"
  end
  
  def import
    logger.info "Importing ..."
    subject_regions = recognize_course()
    logger.info subject_regions.size
    Thread.new do
   		cache[:percent_complete] = 100;
      # go through each region iteratively.
      0.upto(subject_regions.size - 2) do |current_region|
		logger.info subject_regions[current_region]
        cache[:percent_complete] = ((current_region+1)*100)/(subject_regions.size - 1)
        process_region(subject_regions[current_region], subject_regions[current_region+1])
        sleep(0.1)
      end
    end
  end
end