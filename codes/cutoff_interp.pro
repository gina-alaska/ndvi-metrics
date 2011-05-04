;Jiang Zhu, jiang@gina.alaska.edu, 2/22/2011
;This program get rid off the points with value equal to threshold, 
;cahnge values to 101b or 102b of the points that their values are equal to snowcld,
;then interpol the vector.
;inputs are:
;vcomp (a three-year-time-series vector),
;threshold (fill value for missing pixel in 0-200, default is 80b ),
;snowcld (fill value for snoe,cloud,bad, and negative reflectance pixelin 0-200, default is 60b),
;ratio (to control if is sutable to calculate metrics)
;output:interpolated vector is returned in vcomp 
 

pro cutoff_interp, vcomp,threshold,snowcld,ratio

;vcomp----vector need processed, return vector is also by this vector,
;threshold---if value of element in vcomp are less than threshold, this element needs interpolate,
;ratio---number of valid elements/total number of elements,
;in order to compainto nps data process, data is type, range is 0-200,100-20 are good data,
;80 is fill value, negative ndvi value corresponds to 80-99, 0 ndvi corresponds to 100,
;for 80-89, cahnge them into 100,101,or 102,
;80-89-->100, 90-99->101,100-->102

;default values for threshold, snowcld, and ratio are:
;threshold = 80 ; do not interpolate these points
;snowcld=60; need interpolate these points
;ratio1 should be 0.5

;---get valid data vector

num_vcomp=n_elements(vcomp)

idxv = where(vcomp NE threshold, cnt, complement=idx)

tmpnan=vcomp ; tmpnan will be used to store return vector

tmpnan(*)=threshold ; initial value is fill value

;---use ratio to control if the vector is suitable for calculation of metrics

if cnt GE 1 and float(cnt)/float(num_vcomp) GE ratio then begin ; valid number is more than ratio, this pixel is good

;---get the mean of first and last valid as fill value for 1-28, 223-365 days

tmpx=fix(idxv) ;x coordinates values of valid values

tmpv=vcomp(idxv) ; valid values

;---replace 81-89 with 100, 90-99 with 101, and 100 with 102
;---this process corresponds to nps 69band_fill
;tmpv[where(tmpv GE 61b and tmpv LT 90b)]=100b
;tmpv[where(tmpv GE 90b and tmpv LT 100b)]=101b
;tmpv[where(tmpv EQ 100b)]=102b
;------------------------------------

;---replace 60 (snow and cloud fill value) to 99  with randomly picked valued in from 101 or 102

snowcldidx=where(tmpv LT 100b,snowcld_cnt)

;---another condition to decide if the vector is suitable for calculation of metrics
;---if negative ndvi points (their values are in 61 to 99) plus snow, cloud, bad, 
;---negative reflectance points (their values are 60) are greater than 50% of total valid points,
;---this vector is not suitable for metrics calculation
 
if (snowcld_cnt GT 0) and (float(cnt-snowcld_cnt)/float(cnt) GT 0.2 ) then begin  ; number of positive point/number of valid points great than 50% 

fillx=byte( fix( (randomu(1,snowcld_cnt))*3 )+100 )

tmpv(snowcldidx) =fillx

;---interpolate the vector

len=n_elements(vcomp)

tmpu=indgen(len) ; interpolated x coorinidates

;tmpnan=interpol(tmpv,tmpx,tmpu) ;interpolate

tmpnan=interpol_line(tmpv,tmpx,tmpu) ; interpolate by jzhu's method

endif


endif 

;---output vector

vcomp=tmpnan

return

end
