;This program process a vector, it get rid of no-sense point such as -2000 (80), intepolate with adjunct points
;This program do not call oneyear_extension, that means do not interpolate jan,nov,and dec into feb to oct data series
;do interpolate, interpolate threshold, if all time series are threshold values, means this pixel is not vegitation, perhaps water, do not calcualte metrics of this pixel
;threshold is fill value, do not do interpolate, snowcld=60, need interpolate, for points with 81-100, need interpolate
 

pro interpol_noextension_1y_vector, mid_year,mid_year_bn,threshold,snowcld,v_interp,v_bname_interp,ratio,flg_metrics

;input: mid_year--- input vector, return data stored in v_interp, threshold--- get rid of those points with value below threshold, then interpol
;       mid_year_bn----band names of elements of vector
;output: v_interp---- result vector, v_bname_interp --- result of band names

;----- interpol into a complete year, 52 bands/year, so three year will be 52*3 bands

;-- located start and end idx for three years,

;---- for 7day per period, it has 52 period per year, before calcualte, interpol beginning and ending missing values

flg_metrics= 0 ; initial not calculate metrics 

;------ determine if calculate metrics

numofmidyr=n_elements(mid_year)

idxv=where( (mid_year NE threshold) and (mid_year NE snowcld) and (mid_year GT 100),cntv )

if float(cntv)/float(numofmidyr) GE ratio then begin  

flg_metrics=1 ; need calculate metrics

endif
 
vcomp=mid_year

vcomp_bn=mid_year_bn

;----- ratio=number of elements with more than threshold/total number of elemtnts, usually set ratio=0.5
;---cutoff_inperp, first cutoff below threshold points, then interpolate these points-------------

cutoff_interp, vcomp,threshold,snowcld

;---- do filter out the odd points in compv
;ratio2=0.5  ; decided by user,if value of the local low point/minimun of values of two adjunctive points is less than ratio2, this point is odd point
;filter_odd, vcomp,ratio2,rtr

;----- output interpolated data

v_interp=vcomp  ; processed vector to v

v_bname_interp=vcomp_bn ;

return

end
