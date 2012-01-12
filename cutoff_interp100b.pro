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
 
; jzhu, modify from cutoff_interp.pro, interpolate all pints with value of 100B.

pro cutoff_interp100b, vcomp,threshold,snowcld

;vcomp----vector need processed, return vector is also by this vector,
;threshold--fill value=80b, snowcld value=60b, positive ndvi value=100b

num_vcomp=n_elements(vcomp)

idxv = where(vcomp GE 100B, cnt, complement=idx) 

;cnt is the number of valid points with positive value

if cnt LE 0 then begin  ; not interpolate 

return

endif

                                                   
tmpnan=vcomp ; tmpnan will be used to store return vector

tmpv=vcomp(idxv) ; valid values

;---interpolate the missing points which have threshold value.

tmpu=indgen(num_vcomp) ; interpolated x coorinidates

;tmpnan=interpol(tmpv,tmpx,tmpu) ;interpolate, IDL provide method

tmpnan=interpol_line(tmpv,idxv,tmpu) ; interpolate by jzhu's method

;---output vector

vcomp=tmpnan

return

end
