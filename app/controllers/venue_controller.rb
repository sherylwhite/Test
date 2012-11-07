class VenueController < ApplicationController
  layout 'standard'
  
  def venue
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @venue_list=Venue.find(:all,:order=>:venueName,:conditions=>"venueName!='Not Assigned'")
      @msg=params[:msg]
    end
  end
  
  def process_venue
    action=params[:actionDDM]
    ven_type=params[:venueTypeDDM]
    ven_name=params[:venueName]
    capacity=params[:capacity]
    remarks=params[:remarks].strip
    
    msg=0
    
    if action=="Add"      
      ven_exist=Venue.find_by_sql("Select * from venues where venueName='#{ven_name}'")
        if ven_exist.length>0
          # ADD error, venue name already exists
          msg=1
        else
          ven=Venue.new
          ven.id=ven_name
          ven.venueType=ven_type
          ven.capacity=capacity
          ven.remarks=remarks
          ven.save
          #ADD ok!
          msg=2
        end
        
    elsif action=="Update"
      ven_query=Venue.find(ven_name)
      ven_query.update_attribute :venueType,ven_type
      ven_query.update_attribute :capacity, capacity
      ven_query.update_attribute :remarks, remarks
      
      #UPDATE ok!
      msg=3
    else
      Venue.delete(ven_name)
      
      query=Lesson.find_by_sql("Select * from lessons where possibleVenues like '%#{ven_name}%'")
      
      0.upto(query.length-1) do |q|
        temp_arr=Array.new
        temp_arr=query[q].possibleVenues.split(",")
        pos_vens=""

        0.upto(temp_arr.length-1) do|t|
            
          if temp_arr[t]!=ven_name
            pos_vens+=temp_arr[t]+","
          end            
        end
        
        pos_vens=pos_vens[0,pos_vens.length-1]
        query[q].update_attribute :possibleVenues,pos_vens
            
        end     
      
      #DELETE ok!
      msg=4
    end
      redirect_to :action=>"venue", :msg=>msg
      
  
  end
  
end
