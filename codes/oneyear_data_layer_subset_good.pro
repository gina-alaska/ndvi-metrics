pro oneyear_data_layer_subset_good, flist_ndvi, flist_bq, ul,lr

;This routine open one year files defined in file lists, stack these file, subset, and fill bad data with -2000

;inputs: flist_ndvi_yyyy----file list for one year *ndvi.tif,
;        flist_bq_yyyy -----file list fro one year *nvdi_bq.tif
;        ul-----upper left coordinate in unit of meter
;        lr----lower right cordinate in unit of meter
;

;ul=[-206833.75D, 1303877.50D]
;lr=[ 424916.25D,  856877.50D]
;wrkdir='/home/jiang/nps/cesu/modis_ndvi_250m/wrkdir/'

if !version.os_family EQ 'Windows' then begin
sign='\'
endif else begin
sign='/'
endelse

;p =strpos(flist_ndvi,sign,/reverse_search)
;len=strlen(flist_ndvi)
;wrkdir=strmid(flist_ndvi,0,p+1)
;year=strmid(flist_ndvi,p+1,4)
;cmd1 = 'ls ' +wrkdir+'MT3RG_2010_???-???_250m_composite_ndvi.tif>'+wrkdir+'flist_ndvi'
;cmd2 = 'ls ' +wrkdir+'MT3RG_2010_???-???_250m_composite_ndvi_bq.tif>'+wrkdir+'flist_bq'
;spawn,cmd1
;spawn,cmd2



;---- read these two lists into flist and flist_bq

;openr,u1,wrkdir+'flist_ndvi',/get_lun
;openr,u2,wrkdir+'flist_bq',/get_lun

openr,u1,flist_ndvi,/get_lun

openr,u2,flist_bq ,/get_lun


;---
flist=strarr(420) ; 42/year, 10 years
flistbq=strarr(420);


tmp=' '
j=0L
while not EOF(u1) do begin
readf,u1,tmp

flist(j)=tmp

j=j+1
endwhile


tmp=' '
j=0L
while not EOF(u2) do begin
readf,u2,tmp

flistbq(j)=tmp

j=j+1
endwhile

close,u1
close,u2

flist =flist[where(flist NE '')]
flistbq=flistbq[where(flistbq NE '')]

;---- get the number of files

num=(size(flist))(1)

;---- get workdir and year from mid-year file

p =strpos(flist(1),sign,/reverse_search)

len=strlen(flist(1))

wrkdir=strmid(flist(1),0,p+1)

filen =strmid(flist(1),p+1,len-p)

year=strmid(filen,6,4)



;--- get the num of files in the flist.txt

;spawn,'wc '+wrkdir+'flist.txt > '+wrkdir+'num.txt'
;tmp=' '
;openr,u2,wrkdir+'num.txt',/get_lun
;readf,u2,tmp
;close,u2
;tmp=strmid(tmp,2)
;p=strpos(tmp,' ')
;num=fix(strmid(tmp,0,p))  ; num of files in flist.txt

;---- define a struc to save info of each file

;p={flists,fn:'abc',sn:0,dims:lonarr(5),bn:0L}

;x=create_struct(name=flist,fn,'abc',fid,0L,dims,lonarr(5),bn,0L)

x={flist,fn:'abc',bname:'abc',fid:0L,dims:lonarr(5),pos:0L}

flista=replicate(x,num)


;fn=' '
;fid=0L
;dims=0
;nb=0

for j=0L, num-1 do begin

fn_ndvi = strtrim(flist(j),2)

p=strpos(fn_ndvi, '.tif',/reverse_search)

fn_bq =strmid(fn_ndvi,0,p) +'_bq.tif'

idx =where(flistbq EQ fn_bq,cnt)
if cnt EQ 1 then begin

;---- read ndvi and bq to cut off no-sense points
print, 'process the '+string(j)+' th file: ' +fn_ndvi

;if j EQ 38 then begin
;print,'check 38th file'
;endif

read_ndvi, fn_ndvi,fn_bq,ul,lr,rt_fid

endif else begin

;---- no relative bq file, do not cut off no-sense points
endelse


envi_file_query,rt_fid,dims=dims,nb=nb,fname=fn,data_type=data_dt

p1=strpos(fn_ndvi,sign,/reverse_search)

tmpbname= strmid(fn_ndvi,p1+7,12)

flista[j].fn=fn_ndvi+'.good'
flista[j].bname=tmpbname
flista[j].fid=rt_fid
flista[j].dims=dims
flista[j].pos=0  ; note, each subset data has only one band, which is 0, so you can use this to indicate

endfor

;---- layer stacking------------------

; Set the output projection and
  ; pixel size from the TM file. Save
  ; the result to disk and use floating
  ; point output data.
  ;

  ;fist file id is flist[0].fid

  out_proj = envi_get_projection(fid = flista[0].fid, $
    pixel_size=out_ps)

  out_name = wrkdir+year+'_oneyear_layer_subset_good'

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
    fid=flista.fid, pos=flista.pos, dims=flista.dims,/EXCLUSIVE, $
    out_dt=out_dt, out_name=out_name,out_bname=flista.bname, $
    interp=2, out_ps=out_ps, $
    out_proj=out_proj, r_fid=tot_layer_fid


;---- delete good_* files


for j=0L,num-1 do begin

envi_file_mng,id=flista[j].fid,/remove,/delete

endfor


print,'finishing data layer stacking, subset, mask good ndvi data...'

return

end