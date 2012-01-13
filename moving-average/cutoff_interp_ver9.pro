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
 
;jzhu, vcomp_cb include ndvi and bq in one vector

pro cutoff_interp_ver9, vcomp_cb, vcomp_g

;vcomp_cb----vector need processed, which include both ndvi and related quality_flag
;return vcomp_g 
;threshold---if value of element in vcomp are less than threshold, this element needs interpolate,
;ratio---number of valid elements/total number of elements,
;in order to compainto nps data process, data is type, range is 0-200,100-20 are good data,
;80 is fill value, negative ndvi value corresponds to 80-99, 0 ndvi corresponds to 100,
;for 80-89, cahnge them into 100,101,or 102,
;80-89-->100, 90-99->101,100-->102

;default values for threshold, snowcld, and ratio are:
;threshold = 80 ; do not interpolate these points
;snowcld=60; need interpolate these points
;ratio should be 0.5

;0b-valid,1b-cloudy,2b-bad,3b-negative reflectance,4b-snow,10b-fill

;---get valid data vector

num=n_elements(vcomp_cb)

;seperate the combined vector into ndvi and bq vectors

vcomp = vcomp_cb(0: num/2-1)

vcomp_bq=vcomp_cb(num/2:num-1)
 
;different choose in dealinng with no valid points 

;1. interpolate fill, cloudy, and bad points, replace snow and negative reflectance points with randomly 100b to 101.
   
;idxv = where( (vcomp_bq EQ 0b or vcomp_bq EQ 4b ) and vcomp GE 100b , cnt, complement=idx) ;(valid or snow) and positive 



tmpnan=vcomp ; tmpnan will be used to store return vector

idxv = where( (vcomp_bq EQ 0b or vcomp_bq EQ 4b ), cnt, complement=idx) ; valid and snow pixels

;idxv = where( (vcomp_bq EQ 0b ) and ( vcomp GE 100b ) , cnt, complement=idx) ;valid ndvi and positive ndvi 

;cnt is the number of valid pixels which is total number minus number of fill pixels 

;-----initialize randomly 101b to 101b

tmpnan = byte( fix( (randomu(1, n_elements(vcomp) ) )*2 )+100 )


;---use ratio to control if the vector is suitable for calculation of metrics

if cnt GT 0 then begin ;valid number is more than ratio, this pixel is good

;---get the mean of first and last valid as fill value for 1-28, 223-365 days

tmpx=fix(idxv) ;x coordinates values of valid values

tmpv=vcomp(idxv) ; valid values


;---replace negative value (less than 100B) pixels with randomly picked valued in from 101 or 102

;pos_ndvi_idx = where( tmpv LT 100b, pos_ndvi_cnt )

;if pos_ndvi__cnt GT 0 then begin

;fillx=byte( fix( (randomu(1,snowcld_cnt))*2 )+100 )

;tmpv(snowcldidx) =fillx

;endif

;---interpolate the missing points: cloud,bad, fill, and negative reflectance pixels

len=n_elements(vcomp)

tmpu=indgen(len) ; interpolated x coorinidates

;tmpnan=interpol(tmpv,tmpx,tmpu) ;interpolate, IDL provide method

;tmpnan=interpol_line_ver9(tmpv,tmpx,tmpu) ; interpolate by jzhu's method

tmpnan=interpol_line100b(tmpv,tmpx,tmpu)

endif

;---output vector

vcomp_g = tmpnan

return

end
