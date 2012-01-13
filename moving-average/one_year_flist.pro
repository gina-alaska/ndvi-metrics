;this program accepts user's inputs: data_dir, wrk_dir, year, produces two one-year file lists, flist1 includes one-year NDVI file names, flist2 includes NDVI_bq file names

one_year_flist, data_dir, wrk_dir,year,flist1,flist2

if !version.os_family EQ 'Windows' then begin
cmd ='dir /s/B '
sign='\'
endif else begin
cmd='ls '
sign='/'
endelse

;---- profuce two file lists

flist1=wrkdir+sign+year+'_flist_ndvi'

flist2=wrkdir+sign+year+'_flist_ndvi_bq'

cmd_ndvi= cmd+data_dir+sign+year+sign+'*250m_composite_ndvi.tif >'+flist1

cmd_ndvi_bq = cmd+data_dir+sign+year+sign+'*250m_composite_ndvi_bq.tif >'+flist2

spawn,cmd_ndvi

spawn,cmd_ndvi_bq

return

end
