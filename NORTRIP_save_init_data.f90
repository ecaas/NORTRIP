!NORTRIP_save_init_data.f90
    
!Saves initialisation data
    
    subroutine NORTRIP_save_init_data
    
    use NORTRIP_definitions
    
    implicit none
    
    integer :: unit_out=40
    character (256) filename_bin
    character (256) filename_asc
    character (256) filename_temp
    character (256) temp_name
    integer current_date(num_date_index)
    integer tt
    logical :: save_bin=.false.
    integer exists
    integer a(num_date_index)
    
    unit_out=unit_save_init_data
    
    !Leave this if it is not relevant
    if (hours_between_init.le.0) then
	    write(unit_logfile,'(A)') ' WARNING: Not saving data to init file'
        return
    endif
    
    !Open log file
    !if (unit_logfile.gt.0) then
    !    open(unit_logfile,file=filename_log,status='old',position='append')
    !endif

	write(unit_logfile,'(A)') '----------------------------------------------------------------'
	write(unit_logfile,'(A)') 'Saving data to init file (NORTRIP_save_init_data)'
	write(unit_logfile,'(A)') '----------------------------------------------------------------'
 
    !Check that path exists after filling in date stamp
    a=date_data(:,min_time_save)
    call date_to_datestr(a,path_init,temp_name)
    
    inquire(directory=trim(temp_name),exist=exists)
    if (.not.exists) then
        write(unit_logfile,*)'ERROR: Path '//trim(temp_name)//' does not exist.'
        return
    endif

    do ti=min_time,max_time
        
       if (mod(ti,hours_between_init).eq.0) then

            current_date=date_data(:,ti)
            
            !Set the path and file name
            !path_init,filename_init,hours_between_init
            !Set the NORTRIP input initialisation filename using the given dates
            !filename_temp='test_'//filename_init
    
            !Open the outputfile for date
            filename_asc=trim(path_init)//trim(filename_outputdata)//'_init.txt'
            filename_bin=trim(path_init)//trim(filename_outputdata)//'_init.dat'
            call date_to_datestr(current_date,filename_asc,filename_asc)
            call date_to_datestr(current_date,filename_bin,filename_bin)
        
            write(unit_logfile,'(A,A)') ' Saving to: ',filename_asc
            open(unit_out,file=trim(filename_asc),status='replace')
       
            write(unit_out,'(5A16)') 'n_roads','num_track','num_source_all','num_road_meteo','num_moisture'
            write(unit_out,'(5i16)') n_roads,num_track,num_source_all,num_road_meteo,num_moisture
            write(unit_out,'(A)') 'M_road_data'
            do ro=1,n_roads
            do tr=1,num_track
                write(unit_out,'(<num_source_all*num_size>e12.4)') ((M_road_data(s,x,ti,tr,ro),s=1,num_source_all),x=1,num_size)
            enddo
            enddo
        
            write(unit_out,'(A)') 'road_meteo_data'
            do ro=1,n_roads
            do tr=1,num_track
                write(unit_out,'(<num_road_meteo>e12.4)') (road_meteo_data(i,ti,tr,ro),i=1,num_road_meteo)
            enddo
            enddo

            write(unit_out,'(A)') 'g_road_data'
            do ro=1,n_roads
            do tr=1,num_track
                write(unit_out,'(<num_moisture>e12.4)') (g_road_data(m,ti,tr,ro),m=1,num_moisture)
            enddo
            enddo

            !Save the automatic activity time data
            write(unit_out,'(A)') 'time_since_activity_data'
            do ro=1,n_roads
                write(unit_out,'(5e12.4)') time_since_last_salting(ro),time_since_last_binding(ro), &
                    time_since_last_sanding(ro),time_since_last_cleaning(ro),time_since_last_ploughing(ro)
            enddo
            
            
            close(unit_out,status='keep')
        
            if (save_bin) then
                write(unit_logfile,'(A,A)') ' Saving to: ',filename_bin
                open(unit_out,file=trim(filename_bin),form='unformatted',status='replace')
        
                write(unit_out) M_road_data
                write(unit_out) road_meteo_data
                write(unit_out) g_road_data 
        
                close(unit_out,status='keep')
            endif
            
        endif
 
    enddo
     
   ! if (unit_logfile.gt.0) then
    !    close(unit_logfile,status='keep')
   ! endif
   
    end subroutine NORTRIP_save_init_data    