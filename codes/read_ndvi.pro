;Jiang Zhu, jiang@gina.alaska.edu, 2/22/2011
;This program open one pair of file (ndvi and ndvi.bq files),
;do subset according to ul and lr, fill snow, cloud,bad, and negative reflectance pixels with -4000,
;convert data from -2000 to 10000 (integer )to 0-200 (byte)

 
pro read_ndvi, t_fn, d_fn, ul, lr, rt_fid

;inputs:
;t_fn (file name of a *ndvi.tif file,
;d_fn (file name of a *ndvi_bq.tif file),
;ul (uper left coordinate in unit of meter),
;lf (lower right coorinate in unit of meter).
;output: rt_fid (retuned file descriptor).
;if both ul=lf=0, do not do subset.


;---subseting the file

;ul=[-160.0, 62.0]  ; [lon,lat] of upper left
;lr=[-146.0, 56.0]  ; [lon,lat] of lower right

;--- check t_fid, found map unit of t_fid is meters, so we define ul and lr in meters

;ul=[-206833.75D, 1303877.50D]
;lr=[ 424916.25D,  856877.50D]


if !version.os_family EQ 'Windows' then begin
sign='\'
endif else begin
sign='/'
endelse


;---- initial batch mode

p =strpos(t_fn,sign,/reverse_search)
wrkdir=strmid(t_fn,0,p+1)

;start_batch, wrkdir+'b_log',b_unit

;----test only 

;file_ndvi ='MT3RG_2010_106-112_250m_composite_ndvi.tif'
;file_bq   ='MT3RG_2010_106-112_250m_composite_ndvi_bq.tif'

;---open file ndvi data file, t_fn

envi_open_data_file,t_fn,r_fid=t_fid

;ENVI_OPEN_FILE,t_fn,/no_interactive,R_FID=t_fid

if (t_fid NE -1) then begin

envi_file_query,t_fid,dims=t_dims,nb=t_nb,ns=t_ns,nl=t_nl,data_type=data_dt

endif

;---open file ndvi data quanlity file, d_fn

ENVI_OPEN_FILE,d_fn,R_FID=d_fid

if (d_fid NE -1) then begin
envi_file_query,d_fid,dims=d_dims,nb=d_nb,ns=d_ns,nl=d_nl

endif

;---layer stack the two data and output the data into a out_file

file_id=[t_fid,d_fid]



  nb = t_nb + d_nb
  fid = lonarr(nb)
  pos = lonarr(nb)
  dims = lonarr(5,nb)
  ;
  for i=0L,t_nb-1 do begin
    fid[i] = t_fid
    pos[i] = i
    dims[*,i] = [-1,0,t_ns-1,0,t_nl-1]
  endfor
  ;
  for i=t_nb,nb-1 do begin
    fid[i] = d_fid
    pos[i] = i-t_nb
    dims[*,i] = [-1,0,d_ns-1,0,d_nl-1]
  endfor
  ;
  ; Set the output projection and
  ; pixel size from the TM file. Save
  ; the result to disk and use floating
  ; point output data.
  ;
  out_proj = envi_get_projection(fid=t_fid, $
    pixel_size=out_ps)

  tmp_layer_file = 'layer_'+strtrim(string(t_fid),2)

  out_name = wrkdir+tmp_layer_file

  out_dt = data_dt
  ;
  ; Call the layer stacking routine. Do not
  ; set the exclusive keyword allow for an
  ; inclusive result. Use cubic convolution
  ; for the interpolation method.
  ;
 ; envi_doit, 'envi_layer_stacking_doit', $
 ;   fid=fid, pos=pos, dims=dims, $
 ;   out_dt=out_dt, out_name=out_name, $
 ;   interp=2, out_ps=out_ps, $
 ;   out_proj=out_proj, r_fid=r_fid
  ;

 envi_doit, 'envi_layer_stacking_doit', $
    fid=fid, pos=pos, dims=dims, $
    out_dt=out_dt, out_name=out_name, $
    interp=2, out_ps=out_ps, $
    out_proj=out_proj, r_fid=layer_fid
  ;


;---decide if do subset

if ul EQ 0 and lr EQ 0 then begin ; do not do subset

subset_fid=layer_fid

endif else begin   ; do subset

;----- subseting the file

subset,layer_fid,ul,lr,wrkdir,subset_fid ;after exectuate this sunroutine, return file id of subset_image which is stored in memory

endelse

;---- fill snow,cloud,bad, and negative reflectance pixels with -4000

envi_file_query, subset_fid, DIMS=DIMS, NB=NB, NL=NL, NS=NS
pos = lindgen(nb)

;---- envi_get_data just can get one band each time, so use loop to get all bands
image=intarr(NS, NL, NB)
FOR i=0, NB-1 DO BEGIN
image[*,*,i]= envi_get_data(fid=subset_fid, dims=dims, pos=pos[i])
endfor

image1=image(*,*,0)

;--- set snow(4), cloud(1), bad quality(2),and negative reflectance(3)
;----as a -4000, not the fill value of -2000

bq=image(*,*,1)

bq = bq EQ 0.0 or bq EQ 10.0 ;bq=1 if the pixel is 0 or 10, otherwise bq=0 

image1=image1*bq ; only keep values of the pixels which are good pixels or fill pixels

image1[where(image1 eq 0)]=-4000 ; for snow,cloud,bad,and negative reflectance pixels, set their values to -4000.

;---convert scale from 1/10000 to 0-200,
;---original ndvi data is with 0.0001 scale, now change this scale into 0-200
;---by using formula: byte( (data/100) +100 ), 10,000-->200, 1000->110,
;---0-->100, -1000->90, -2000->80, -10000->0.

image1=byte((image1/100)+100)

;---check if there is any pixel with value in range 60 to 80, for test only puporse

chkidx=where(image1 GT 60b and image1 LT 80b,chk)

if chk GT 0 then begin

print,'check the reason'

endif

;---output data to a file

data_type=1  ; byte type

map_info=envi_get_map_info(fid=subset_fid)

out_name=wrkdir+'good_'+strtrim(string(layer_fid),2)

envi_write_envi_file, image1, data_type=data_type, $
descrip = 'good_image', $
map_info = map_info,out_name=out_name, $
nl=nl, ns=ns, nb=1, r_fid=good_fid


;---return image with file id of good_fid,subsized, and only have good ndvi values

rt_fid=good_fid

;---free memory and also delete temperary files, layer_* and subset_*

image=0
image1=0
bq=0

;---close two file-ids

envi_file_mng, id=layer_fid, /remove,/delete
envi_file_mng, id=subset_fid,/remove,/delete
envi_file_mng,id=t_fid,/remove
envi_file_mng,id=d_fid,/remove


;ENVI_DOIT, 'RESIZE_DOIT', DIMS=dims_ndvi, FID=fid_ndvi, /IN_MEMORY
;
;
;
;---- exit batch mode
;ENVI_BATCH_EXIT

return

end






