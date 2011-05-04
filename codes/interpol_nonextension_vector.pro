;This program process a vector, it get rid of no-sense point such as -2000, intepolate with adjunct points
;This program do not call oneyear_extension, that means do not interpolate jan,nov,and dec into feb to oct data series
;do interpolate, interpolate threshold, if all time series are threshold values, means this pixel is not vegitation, perhaps water, do not calcualte metrics of this pixel
;threshold is fill value, do not do interpolate, snowcld=60, need interpolate, for points with 81-100, need interpolate
 

pro interpol_nonextension_vector, v, v_bname, threshold,snowcld,v_interp,v_bname_interp

;input: v--- input vector, return data also stored in v, threshold--- get rid of those points with value below threshold, then interpol
;       v_bname----band names of elements of vector
;output: v_interp---- result vector, v_bname_interp --- result of band names

;----- interpol into a complete year, 52 bands/year, so three year will be 52*3 bands

;-- located start and end idx for three years,

;---- for 7day per period, it has 52 period per year,before calcualte, interpol beginning and ending missing values

;idx=where( strmid(v_bname,0,1) EQ 0,cnt)
;bf_year_bn=v_bname(idx)
;bf_year =v(idx)
;numofbfyr=(size(bf_year))(1)

;idx = where(  strmid(v_bname,0,1) EQ 1, cnt)
;mid_year_bn=v_bname(idx)
;mid_year=v(idx)
;numofmidyr=n_elements(mid_year)

;idx=where(strmid(v_bname,0,1) EQ 2,cnt)
;af_year_bn=v_bname(idx)
;af_year=v(idx)
;numofafyr=n_elements(af_year)

;----- call oneyear_extension
;oneyear_extension, bf_year,bf_year_bn,days_bf
;oneyear_extension, mid_year,mid_year_bn,days_mid
;oneyear_extension,af_year,af_year_bn, days_af

;------ joint three years of vectors

;vcomp=[bf_year,mid_year,af_year]
;vcomp_bn=[bf_year_bn,mid_year_bn,af_year_bn]
;daycom=[days_bf,days_mid,days_af]

;----- cut off no-sense points and interpolate them
;threshold = 0 ; even use threshold = 0, nornal use -2000.
;cutoff_interp,vcomp,threshold
;threshold=-2000   ; -2000 is the fill-value in raw ndvi data file


vcomp=v

vcomp_bn=v_bname

;----- ratio=number of elements with more than threshold/total number of elemtnts, usually set ratio=0.5
;---cutoff_inperp, first cutoff below threshold points, then interpolate these points-------------

ratio1=0.3 ;valid number/total nume is more than 0.6

cutoff_interp, vcomp,threshold,snowcld,ratio1

;---- do filter out the odd points in compv
;ratio2=0.5  ; decided by user,if value of the local low point/minimun of values of two adjunctive points is less than ratio2, this point is odd point
;filter_odd, vcomp,ratio2,rtr

;----- output interpolated data

v_interp=vcomp  ; processed vector to v

v_bname_interp=vcomp_bn ;

return


end