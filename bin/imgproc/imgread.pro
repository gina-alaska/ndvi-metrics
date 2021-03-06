;===   IMGREAD   ============================================
; This function reads in an image of x samples and y lines.
; If the FLOAT flag is set, it reads images as floating point
; otherwise it reads as byte (unsigned character). 
; If the ORDER flag is set, it reads the image in so that the
; first line is at the bottom.
; The ONEBAND flag is only available if nbands is ommited
; from the argument list.  If both are omitted, it assumes
; the number of bands is #lines/#samples (as in the AVHRR
; chips)

; nbands can be used with the /ORDER flag to flip the order
; on individual bands (eg imgread(file, 100, 1200, 12, /ORDER))
; This will read in a 100x1200 image and flip every 100x100
; block.

; NOTE: the image dimension conventions and nbands aren't  
; fully functional 
;============================================================

FUNCTION   imgread, filename, x, y, nbands, nsites, ORDER = order , I2 = i2

case N_PARAMS() of
  3: begin
       nbands = 1
       ydim = y/nbands
       nsites = 1
     end
  4: begin
       nbands = nbands
;       ydim = y/nbands
       ydim = y
       nsites = 1
       data = bytarr(x,y, /NoZero)
       tmp = bytarr(x,y, /NoZero)
     end
;  5: begin
;       nbands = nbands
;       ydim = y/nbands
;       nsites = nsites
;       xdim = x/nsites
;       data = bytarr(x,ydim,nbands, /NoZero)
;       tmp = bytarr(x,ydim,nbands, /NoZero)
;     end
  else: MESSAGE, 'Wrong number of arguments in IMGREAD'
endcase

;  FLIP READ ORDER
if(KEYWORD_SET(ORDER)) then $
   RotIdx = 7 $
else $
   RotIdx = 0

;  IS DATA BYTE OR I*2
if(KEYWORD_SET(I2)) then begin
  data = intarr(x,y*nbands, /NoZero)
  tmp = intarr(x,y*nbands, /NoZero)
endif else begin 
  data = bytarr(x,y*nbands, /NoZero)
  tmp = bytarr(x,y*nbands, /NoZero)
endelse

openr, LUN, filename, /GET_LUN
if(KEYWORD_SET(I2)) then begin
  pix = assoc(LUN,intarr(x,y*nbands, /NoZero)) 
endif else begin
  pix = assoc(LUN,bytarr(x,y*nbands, /NoZero)) 
endelse

tmp(*,*) = pix(0)

for i = 0, nbands - 1 do begin
   data(*, i*ydim:(i+1)*ydim-1) = rotate( tmp(*, i*ydim:(i+1)*ydim-1), RotIdx) 
end

FREE_LUN, LUN

return, data
end
