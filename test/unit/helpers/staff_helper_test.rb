require File.dirname(__FILE__) + '/../../test_helper'
require 'pp'

class StaffHelperTest < HelperTestCase

  include StaffHelper

  def test_import
    #test_excel_init
    #import
  end
  #fixtures :users, :articles
  def test_excel_init    
    excel_init("/home/projects/rr/tps/public/files/StaffDetails.xls")
    # test whether the the excel_init function recognized the columns correctly 
    assert_equal(0, @subject_col)
    assert_equal(2, @lec_col)
    assert_equal(5, @tut_col)
    assert_equal(8, @lab_col)
    
    assert_equal(2, @first_row)
    assert_equal(635, @last_row)
  end
  
  def test_recognize_semesters
    #test_excel_init
    #recognize_semesters
  end
  
  def test_process_region
    #test_excel_init
    #process_region(4, 19)
    #process_region(633, 635)
  end
  
  def test_process_staff_col
    #test_excel_init
    #pp process_staff_col(633, 635, 2)  
    #pp process_staff_col(633, 635, 5)  
    #pp process_staff_col(633, 635, 8)  
  end
  
  def test_process_staff_region
    #test_excel_init
    #pp process_staff_region(633, 635)
  end
  
  def test_import
    test_excel_init
    import
  end
  
  def setup
    super
  end
  def teardown
    super
  end
end
