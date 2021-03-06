;This program realize weighted-least-squre smooth algorithm original developed by Daniel L. Swets,2001
;inputs: vector, number of points before current point, number of points after current point,
;output smoothed vector
;jzhu, 2/8/2011

pro wls_smooth, v, numbf, numaf, y

if min(v) EQ max(v) then begin   ; do not do smooth
y=v
return
endif


;---produce a temperary vector which adds  last num_bf points of the vector before and
; add first num_af points of the vector to the end

num = n_elements(v)

numtmp=numbf+num+numaf

tmpv =fltarr(numtmp)

x =findgen(numtmp)


tmpv(0:numbf-1)= v(num-numbf:num-1)

tmpv(numbf:numbf+num-1)=v

tmpv(numbf+num:numtmp-1)=v(0:numaf-1)



;--- calculate weight, localpeal=1.5, localsloping=0.5, local valley=0.005
;-- the weights of the first and last points are assigned to 0.5

w =fltarr(numtmp) ; store weight

w(*) =0.5  ; default value=0.5

y =fltarr(num) ; store estimated y values



for j=1, numtmp-2 do begin

;--- comapre j-1,j, and j+1 to assign weight

if tmpv(j) GT tmpv(j-1) and tmpv(j) GT tmpv(j+1) then begin

  w(j)=1.5

endif else begin

   if tmpv(j) LT tmpv(j-1) and tmpv(j) LT tmpv(j+1) then begin

    w(j)=0.005

   endif


endelse

endfor

;------ calculate y


for j=numbf+0,numbf+num-1 do begin


sw=total(w(j-numbf:j+numaf))

sy=total(w(j-numbf:j+numaf)*tmpv(j-numbf:j+numaf) )

sx=total(w(j-numbf:j+numaf)*x(j-numbf:j+numaf) )

sxy=total(w(j-numbf:j+numaf)*x(j-numbf:j+numaf)*tmpv(j-numbf:j+numaf) )

sxsqr=total(w(j-numbf:j+numaf)*x(j-numbf:j+numaf)*x(j-numbf:j+numaf) )

b =(sw*sxy-sx*sy)/(sw*sxsqr-sx*sx)

a=(sy-b*sx)/sw

y(j-numbf)=a+b*x(j)

endfor

;-----

return

end