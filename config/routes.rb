ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
   map.with_options(:controller=>'tps') do |tps|
    tps.connect 'tps/venue', :controller=>'venue', :action=>'venue'
    tps.connect 'tps/subject', :controller=>'subject', :action=>'subject'
    tps.connect 'tps/ref_subject', :controller=>'ref_subjects', :action=>'ref_subject'
    tps.connect 'tps/staff', :controller=>'staff', :action=>'staff'
    tps.connect 'tps/subject_list', :controller=>'subject_list', :action=>'subject_list'
    tps.connect 'tps/shared_code', :controller=>'shared_code', :action=>'shared_code'
    tps.connect 'tps/schedule', :controller=>'schedule', :action=>'schedule'
    tps.connect 'tps/schedule_staff', :controller=>'schedule', :action=>'schedule_staff'
    tps.connect 'tps/by_subjects', :controller=>'show_schedule', :action=>'by_subjects'
    tps.connect 'tps/by_staffs', :controller=>'show_schedule', :action=>'by_staffs'
    tps.connect 'tps/by_venues', :controller=>'show_schedule', :action=>'by_venues'
    tps.connect 'tps/by_groups', :controller=>'show_schedule', :action=>'by_groups'
    tps.connect 'tps/stars', :controller=>'stars',:action=>'stars'
    tps.connect 'tps/update_stars', :controller=>'stars',:action=>'update_stars'
    tps.connect 'tps/import_staff', :controller=>'staff',:action=>'import_staff'
    tps.connect 'tps/import_staff2', :controller=>'staff2',:action=>'import_staff'
    tps.connect 'tps/stars_printout', :controller=>'print_out', :action=>'stars_printout' 
    tps.connect 'tps/subject_index_printout', :controller=>'print_out', :action=>'subject_index_printout' 
    tps.connect 'tps/subject_printout', :controller=>'print_out', :action=>'subject_printout' 
    tps.connect 'tps/subject_list_printout', :controller=>'print_out', :action=>'subject_list_printout' 
    tps.connect 'tps/venue_clash_printout', :controller=>'print_out', :action=>'venue_clash_printout'        
    tps.connect 'tps/tt_excel_printout', :controller=>'print_out', :action=>'tt_excel_printout'
    tps.connect 'tps/sub_grp_excel_printout', :controller=>'print_out', :action=>'sub_grp_excel_printout' 
    tps.connect 'tps/grp_stat_printout', :controller=>'print_out', :action=>'grp_stat_printout' 
    tps.connect 'tps/db_switch', :controller=>'db_switch', :action=>'db_switch'
    tps.connect 'tps/user', :controller=>'user', :action=>'user'
    
  end
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
 
  
end
