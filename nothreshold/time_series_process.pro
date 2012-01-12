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
 

pro time_series_process,tmp,bnames,threshold,snowcld,mid_interp,mid_smooth,mid_bname,vmetrics

;----calls interpol_nonextension_vector to get rid of no-sense points,and intepolate these points. 

interpol_nonextension_vector,tmp,bnames,threshold,snowcld,tmp_interp,tmp_bname_interp

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

;--- calculate the metrics of the mid_smooth

user_metrics, mid_smooth, mid_interp, mid_bname, vmetrics ;vout--smoothed vector, vorg--orginal vector, vmetrics--metrics

return

end
