PRO   pickpoints, number, x, y, DEVICE=device, DATA=data

device =  KEYWORD_SET(DEVICE)
data = KEYWORD_SET(DATA)

IF(Data) THEN BEGIN
  x=fltarr(number+1) 
  y=fltarr(number+1) 
ENDIF ELSE BEGIN
 x=intarr(number+1) 
 y=intarr(number+1) 
ENDELSE

i=0
cursor, x0, y0, /wait, data = data, device=device
x(i) = x0
y(i) = y0
x(number) = x0
y(number) = y0
print, i, x(i), y(i)
wait,1 
for i = 1, number-1 do begin

   cursor, x0, y0, /wait, data = data, device=device
   wait, 1
   x(i) = x0
   y(i) = y0
print, i, x(i), y(i)
plots, [x(i), x(i-1)], [y(i),y(i-1)], color=rgb(255,255,255)

endfor

plots, [x(number), x(number-1)], [y(number),y(number-1)], color=rgb(255,255,255)

end
