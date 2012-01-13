;jiang Zhu, 2/17/2011,jiang@gina.alaska.edu
;This program calls subroutines to interpolate a three-year time-series data,
;smooth mid-year time-series data, and calculate the metrics for the mid-year time-series data.
;The inputs are: 
;tmp (three-year-time-series-cvector), 
;bnames (three-year-time-series-vector name),
;threshold (fill value for no data, 60b),
;snowcld (fill value for snow and cloud, 60b),
;outputs are:
;mid_interp (mid-year interpolated vector),
;mid_smooth (mod-year smoothed vector),
;mid_bname (mid-year smoothed vector's band names),
;vmetrics (mid-year metrics).
 
;jzhu, 5/5/2011, use the program provided by Amy to do moving smooth and calculate the crossover
 
 

pro time_series_process_nps_noextension,tmp,bnames,threshold,snowcld,mid_interp,mid_smooth,mid_bname,vmetrics

a=-100
sfactor=0.01
ratio=0.3  ;number of valid points(not threshold or snowcld) of mid_year/number of total points of mid_year
metrics_cal_threshold=0.4 ;when ndvi is less than metrics_cal_threshold, do not calculate metrics

;----calls interpol_nonextension_vector to get rid of no-sense points,and intepolate these points. 
;interpol_nonextension_vector,tmp,bnames,threshold,snowcld,tmp_interp,tmp_bname_interp

;----calls interpol_extension_vector, interpolate values of missing days, get rid of nosense points, and interpolate the points.

interpol_extension_vector,tmp,bnames,threshold,snowcld,tmp_interp,tmp_bname_interp,ratio,stnum, ednum, flg_metrics

;if flg_metrics = 1, calculate metrics, if flg_metrics = 0, it indicate there are not enough valid points in mid_year, do not calculate metrics 
 
;---calls user_smooth to do smooth

;user_smooth, tmp_interp, tmp_smooth

;---calls wls_smooth to do smooth. wls_smooth is developed based on the method 
;---that Daniel L. Swets originally developed, except including combined windows

wls_smooth, tmp_interp,2,2,tmp_smooth

;---pick and store only mid-year data from three-year data

mid_idx = where( strmid(tmp_bname_interp,0,1) EQ 1,cnt)

mid_interp=tmp_interp(mid_idx)

mid_smooth= tmp_smooth(mid_idx)

mid_bname= tmp_bname_interp(mid_idx)


if flg_metrics EQ 1 then begin 
    
;--- calculate the metrics of the mid_smooth
;----because mid_smoth,mid_interp are byte (0-200), convert into float [0 - 1]
;----to gurrentee the up and down crossover, make before and after missing periods up

    mid_smooth1=mid_smooth
    
    mid_interp1=mid_interp
    
    len=n_elements(mid_smooth1)
    
    avgst=mean(mid_smooth1(0:stnum-1) )
    
    avged=mean(mid_smooth1(len-ednum:len-1) )
    
    mid_smooth1(0:stnum-1)= reverse(indgen(stnum))*float(2B)/float(stnum) + avgst;
    
    mid_smooth1(len-ednum:len-1)=indgen(ednum)*float(2B)/float(ednum) + avged;
    
    mid_smooth1=( mid_smooth1 +a )*sfactor
    
    mid_interp1=( mid_interp1 +a )*sfactor

user_metrics_nps, mid_smooth1, mid_interp1, mid_bname, metrics_cal_threshold,vmetrics ;vout--smoothed vector, vorg--orginal vector, vmetrics--metrics

endif else begin

vmetrics =fltarr(12) ; if do not calculate metrics, set every element = 0.0

endelse

return

end
