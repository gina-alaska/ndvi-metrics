;user_metrics.pro 
;Author: jiang zhu, 2/17/2011, jiang@gina.alaska.edu
;This program calculates the metrics of a time-series vector.
;inputs are v (smoothed vector),v2 (original vector),bn (band name vector).
;output is out_v(a 12-element vector).
;out_v=[onp,onv,endp,endv,durp,maxp,maxv,ranv,rtup,rtdn,tindvi,mflg]
;The 12 elements are:
;0=onp(time of onset of greenness),
;1=onv(NDVI value at onset),
;2=endp(time of end of greenness),
;3=endv(NDVI value at end),
;4=Durp(duration of greenness),
;5=Maxp(Time of maximum NDVI),
;6=maxv(Maximum NDVI Value),
;7=ranv(range of NDVI values),
;8=rtup(rate of grrenup),
;9=rtdn(rate of senescense),
;10=tindvi(time-integrated NDVI),
;11=mflg(data valid flag,0--no-sense metrics,1--valid metrics)


pro user_metrics, v, v2, bn, out_v

;---v is smoothed vector, v2 is orginal vector,and bn is band name for v
;---because data have convert from -4000 to 10000 to 0 to 200, 
;---if you want to get the NDVI, you need use equation ndvi=(scaled ndvi+a)*sfactor, where
;---sfactor=0.01, and a=-100
               
sfactor=0.01
a=-100.0


;---user may set the vaid index range for metrics calculation purpose.
;---if the idx_max_v less than cutoff_bg or greater than numofvecor-cutoff_ed,
;---then do not calculate the metrics.The default cutoff_bg=6, cutoff_ed=4

cutoff_bg=6 ; if the max point is less than cutoff_bg or great than numofvecor-cutoff_ed, do not calculate metrics 

cutoff_ed=4

;---get the day between two 7-day band

intv_day = fix( strmid( bn(1),7,3 ) )-fix(strmid( bn(0),7,3 ) ) 

;This is the interval days between two measurement weeks. The band name format is:n-yyyy-ddd-ddd.

start_day =fix(strmid( bn(0),7,3) ) ; this is the first date of the first measurement week

;---define out_v 

out_v=fltarr(12) ; used to store metrics, initial value out_v(*)=0

;---inital metrics valid flag

mflg=0    ; initial value 0, 0---not valid metrics, 1-- valid metrics

;---sometimem elements in v have the same values, or max(v)*sfactor LT 0.5, do not calculate metrics,return

;if min(v) EQ max(v) or max(v)*sfactor LT 0.5 then begin  ; retun, mflg=0, when v(*)=-2000, 

if min(v) EQ max(v) then begin

 return

endif




;---if maximun value of v occur at beginning (< cutoff_bg) or ending (> numofvector-cutoff_ed),
;---do not calculate the metrics

idx_v_mx= where(v EQ max(v),cnt2)

idx_v_mx_first =idx_v_mx(0)

idx_v_mx_last=idx_v_mx( n_elements(idx_v_mx)-1 )

numofv=n_elements(v)

if idx_v_mx_first LT cutoff_bg or idx_v_mx_last GT numofv-cutoff_ed then begin

return

endif

;---w is the number of moveing average points, default value is 21,could be a input parameter
 
w= 21; time inteval is 7 days, 21*7=147 days,it is also points, acording to reed,B.C,1994, 144 days

day_intval=intv_day ; 7 days interval between two times

sz=size(v)

fwv=fltarr(sz(1))  ; store fowrawd moving average

bwv=fltarr(sz(1))  ; store backword moving average

 
;-----calculate forward and backward moving average
wf=21 ; 
fwv = ts_smooth(v,wf,/forward)  ; used to calculate endofgreen

wb=21 ;
bwv = ts_smooth(v,wb,/backward) ; used to calculate startofgreen



;----- calculate backword moving average


;for j=0, num-1 do begin

;if j LE num-1-w then begin

;bwv(j)=mean(v[j:j+w])

;endif else begin

;bwv(j)=mean(v[j:num-1])

;endelse

;endfor


;---start to retrieve onp

onflg=0
onp=0
onv=0.0

idxofmaxv = idx_v_mx_first ;

;--- calculate dev, the derivative of v

dev=deriv(v)

;---get the index of the maximum value in dev

dev_mx=max( dev(cutoff_bg:idxofmaxv) )

idx_dev_mx = where(dev EQ dev_mx) ; possible onp

;---get diffv, the diferance between v and backward moving average

diffv=v-bwv  ; difference between v-bwv

;---get dediffv, the derivative of diffv

dediffv=deriv(diffv) ;dediffv ;derivative of diffv

;----get the points where dev and dediff are maxmiun before v arrives maximun

dediffv_mx =max( dediffv(cutoff_bg:idxofmaxv ) )

idx_dediffv_mx=where( dediffv EQ dediffv_mx ); where dediffv arrive maximun, possible onp

idxofdevmx=max(idx_dev_mx)

idxofdediffvmx=max(idx_dediffv_mx)

;---get idx_smaller and idx_greater, they are possible indice

idx_possi_greater=max( [idxofdevmx, idxofdediffvmx] )

idx_possi_smaller=min( [idxofdevmx, idxofdediffvmx] )

;---get the max idx there diffv are negative within the range of cutoff_bg to idx_possi_greater

possi_onp=0 ; initial value

find_cross=0; flag to indicate found the cross point, 0--not found, 1--found

idx1 = where(diffv(cutoff_bg:idx_possi_greater ) LE 0 ,cnt1) 

if cnt1 GT 0 then begin   ; found negative values in diffv betrween cutoff_bg to idx_possi_greater

;----idx should add cutoff_bg

idx1=idx1+cutoff_bg       

idx_diffv_st=idx1( n_elements(idx1)-1 )

diffv_st=diffv(idx_diffv_st)

; idx_diffv_st+1 is the possible onp

;--- check v(idx_diffv_st+1) is possitive, otherwise, look for higher idx to get the first point with positive v value

for kk=idx_diffv_st+1, idx_possi_greater do begin

if v(kk) GT 0.0 then begin  ; found correct onp

possi_onp=kk

find_cross=1

break

endif

endfor

endif

;---compare three possible onp values, idx_dev_mx, idx_dediffv_mx, and possi_onp to get the correct one

if find_cross EQ 1 then begin ;found cross point, pick from three points

if possi_onp LT idx_possi_smaller then begin
   
   onp=idx_possi_smaller

endif else begin
 
  if possi_onp GE idx_possi_smaller and possi_onp LE idx_possi_greater then begin
     onp=possi_onp
  endif else begin
     onp=idx_possi_greater
  endelse


endelse

endif else begin ; do not find cross point, pick from two points

onp=idx_possi_smaller

endelse

;---calculate NDVI of onset

onv=( v(onp)+a )*sfactor


;---start to retrieve endp and endv

endflg=0

endp=0

endv=0.0

numofv=n_elements(v)

;----get the points where dev and dediff are maxmiun after v arrives maximun


diffv=v-fwv

dediffv=deriv(diffv)

idxofmaxv = idx_v_mx_last

dev_min =min( dev(idxofmaxv:numofv-cutoff_ed) );

idx_dev_min=where(dev EQ dev_min ) ; where dev arrive maximun, possible endp

dediffv_min =min(dediffv(idxofmaxv:numofv-cutoff_ed) );

idx_dediffv_min=where(dediffv EQ dediffv_min); where dediff arrive maximun, possible endp

idxofdevmin=min(idx_dev_min)

idxofdediffvmin=min(idx_dediffv_min)

idx_possi_smaller=min([ idxofdevmin,idxofdediffvmin] )

idx_possi_greater=max([ idxofdevmin,idxofdediffvmin] )

possi_endp = numofv-cutoff_ed ;initial value


;---check crosss points v cross over bwv from below to up in the range of idx_dediffv to numofv-1

;---if there is negative value in diffv betrween idx_dediffv to numofv-1, choose between idx_dediffv to where negative value

idx1=where(diffv(idx_possi_smaller:numofv-cutoff_ed) LE 0.0,cnt1)

possi_endp =0 ; initial value

find_cross =0; 0--not find cross, 1--found cross


if cnt1 GT 0 then begin ; have negative value of diffv, that is to say, have cross over

idx1 = idx1 + idx_possi_smaller  ; idx1 change into index which corresponds to diffv

end_idx =idx1(0)

;--- found positive value of v from idx1(0)-1 to idx_possi_smaller

for kk= idx1(0)-1, idx_possi_smaller, -1 do begin

if v(kk) GT 0.0 then begin  ; found possi_endp

possi_endp=kk

find_cross=1 ; found cross point

break

endif

endfor

endif  

;----- choose endp among three possible postions, idx_possi_smaller, idx_possi_greater, and possi_endp

if find_cross EQ 1 then begin  ; found cross point, pick from three points

 if possi_endp GE idx_possi_greater then begin

 endp=idx_possi_greater

 endif else begin

   if possi_endp LT idx_possi_greater and possi_endp GE idx_possi_smaller then begin

    endp=possi_endp

   endif else begin

    endp=idx_possi_smaller

   endelse

 endelse

endif else begin  ; not find cross point, pick from two points

endp=idx_possi_smaller

endelse 

;---calculate NDVI of end-of-greenness

endv=( v(endp)+a )*sfactor

;---get additional condition to make sure the metrics calculation is resonable. default condition is
;---the end-of-greenness -stsrt-of-grenness must greater than 42 days.

if endp-onp LE 6 then begin ;this condition may be change, 6*7=42 days

return

endif

;---calculate durp, 

durp=(endp-onp) ;  index 

v2_mx=max( v2(onp:endp) )

idxp=where(v2 EQ v2_mx) 

maxp=idxp(0)

maxv=( v2(maxp)+a )*sfactor      ; ndvi


;---use onp,maxp,endp to judge if the metrics are correct

;condi= onp LT maxp and maxp LT endp
;if condi EQ 0B then begin  ; not valid metrics
;return
;endif

;---continue to calculate other metrics

mflg=1 ; valid metrics

out_v(11)=1 ; valid metrics data flag


;---convert onp, endp, and maxp into day unit, notice add start_day, and use mid-day of the week as the day label



;onpday=fix(onp*intv_day+start_day+(intv_day)/2)

onpday=fix( strmid( bn(onp),7,3) +(intv_day)/2.0 )

;endpday=fix(endp*intv_day+start_day+(intv_day)/2 )

endpday=fix(strmid( bn(endp),7,3)+(intv_day)/2.0 )

;maxpday=fix(maxp*intv_day+start_day+(intv_day)/2)

maxpday=fix(strmid( bn(maxp),7,3) +(intv_day)/2.0 )



if maxv-onv GE maxv-endv then begin
ranv= maxv-onv                  ; unit ndvi                    
endif else begin
ranv=maxv-endv                  ; unit ndvi          
endelse

rtup= (maxv-onv)/(maxpday-onpday)    ; unit ndvi/day

rtdnp=(maxv-endv)/(maxpday-endpday)  ; unit ndvi/day

tindvi= total( (v2[onp:endp] + a)*sfactor )*intv_day  ;unit ndvi*day

out_v[0]=onpday ;unit day
out_v[1]=onv
out_v[2]=endpday ;unit day
out_v[3]=endv
out_v[4]=endpday-onpday ;unit day
out_v[5]=maxpday
out_v[6]=maxv
out_v[7]=ranv
out_v[8]=rtup
out_v[9]=rtdnp
out_v[10]=tindvi
 
return

end 
 
 
 
