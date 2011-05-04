;this program to interpolate, input,v, xin, xout, 
;xin, xout are idx

function interpol_line, v, xin,xout

; convert v,xin,xout from type into float

v=float(v)

;xin=float(xin)
;xout=float(xout)

numout=n_elements(xout)

y=fltarr(numout)   ; store output


numin=n_elements(xin)



;---- first idxin(0)


;--- interpol v(xin(0)) to y(0) to y(xin(0) )
 for k=xout(0),xin(0) do begin
  y(k)=v(0)
 endfor

 

for j=0, numin-2 do begin

if xin(j+1) - xin(j) GT 1 then begin

b=( v(j + 1 ) - v( j ) )/ ( float(xin(j+1)) -float(xin(j))  ) 

a= ( v( j ) ) - b*xin(j)

for k=xin(j)+1, xin(j+1) do begin

y( k )= a+b*xout(k) 

endfor

endif else begin   ; xin(j) and xin(j+1) are adjunctive

y( xin(j) )= v(j)

y( xin(j+1) )=v( j+1 )

endelse

endfor

;--- process last point of v

;if xin(numin-1) LT xout(numout-1) then begin

;--- fill with the last v(xin(numin-1)

for k=xin(numin-1)+1, xout(numout-1) do begin

y(k)=v(numin-1 )

endfor

 
return, y 

end


