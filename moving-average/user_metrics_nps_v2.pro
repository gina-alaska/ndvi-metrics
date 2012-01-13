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


;jzhu, 5/5/2011, use program provided by Aym to calculate the moving average and crossover 



pro user_metrics_nps_v2, ndvi, v2, bn, out_v

;---ndvi is smoothed vector, v2 is orginal vector,and bn is band name for ndvi
;---because data have convert from -4000 to 10000 to 0 to 200, 
;---if you want to get the NDVI, you need use equation ndvi=(scaled ndvi+a)*sfactor, where
;---sfactor=0.01, and a=-100
               
;jzhu, 5/12/2011, call computemetics_v2.pro to calculate on, end of season
               
sfactor=0.01
a=-100.0
wl=[18,18] ;decided by Reed, B.C.Measure phenological variability from satellite imagery,1994, 703, J. vegetation Science 5

bpy =(size(ndvi))(1)  ; num of band in one year, 42

CurrentBand=7

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

if min(ndvi) EQ max(ndvi) then begin

 return

endif




metrics=ComputeMetrics_v2(NDVI,v2,wl,bpy,CurrentBand)

;convert sost->onp, sosn->onv, eost->endp,eosn->endv

onp=metrics.sost
onv=metrics.sosn
endp=metrics.eost
endv=metrics.eosn

;---calculate NDVI of onset


;onv=( ndvi(onp)+a )*sfactor

;---calculate NDVI of end-of-greenness

;endv=( ndvi(endp)+a )*sfactor

;---get additional condition to make sure the metrics calculation is resonable. default condition is
;---the end-of-greenness -stsrt-of-grenness must greater than 42 days.
if endp LE -1 or onp LE -1 or endp -onp LE 6 then begin

return

endif 


;---calculate durp, 

durp=metrics.rangen

;durp=(endp-onp) ;  index 
;v2_mx=max( v2(onp:endp) )
;idxp=where(v2 EQ v2_mx) 
;maxp=idxp(0)
;maxv=( v2(maxp)+a )*sfactor      ; ndvi

maxp=metrics.maxt

maxv=metrics.maxn

;---use onp,maxp,endp to judge if the metrics are correct

;condi= onp LT maxp and maxp LT endp
;if condi EQ 0B then begin  ; not valid metrics
;return
;endif

;---continue to calculate other metrics

mflg=1 ; valid metrics

out_v(11)=1 ; valid metrics data flag


;---convert onp, endp, and maxp into day unit, notice add start_day, and use mid-day of the week as the day label

onpday=fix ( strmid( bn(onp),7,3)) ;day

endpday=fix(strmid( bn(endp),7,3)) ;day

maxpday=fix(strmid( bn(maxp),7,3)) ;day


if maxv-onv GE maxv-endv then begin
ranv= maxv-onv                  ; unit ndvi                    
endif else begin
ranv=maxv-endv                  ; unit ndvi          
endelse


;rtup= (maxv-onv)/(maxpday-onpday)    ; unit ndvi/day
;rtdnp=(maxv-endv)/(maxpday-endpday)  ; unit ndvi/day

rtup= metrics.slopeup/100.0    ; positive, ndvi/day

rtdnp=-metrics.slopedown/100.0  ; negative, ndvi/day


;tindvi= total( (v2[onp:endp] + a)*sfactor )*intv_day  ;unit ndvi*day

tindvi=metrics.totalndvi ;ndvi*day

out_v[0]=onpday ;unit day
out_v[1]=onv    ;normalized ndvi
out_v[2]=endpday ;unit day
out_v[3]=endv   ;normoalized ndvi
out_v[4]=endpday-onpday ;unit day
out_v[5]=maxpday ;unit day
out_v[6]=maxv ; normalized ndvi
out_v[7]=ranv; normalized ndvi
out_v[8]=rtup; slopeup, ndvi/day
out_v[9]=rtdnp ;slopedown, ndvi/day 
out_v[10]=tindvi; ndvi*day
 
return

end
 
