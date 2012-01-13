;This program do smooth for a multiyear_layer_stack file and calculate metrics, output both smoothed data and metrics data in two seperate files
;inputs: file name of a multiyear_layer_stack file,
;outputs:smoothed data named multiyear_layer_stack_smoothed and metrics file named multiyear_layer_stack_smoothed_metrics

pro smooth_calculate_metrics, filen

;input: filen---multiple-year file, ready to smooth, output file name is filen+'_metrics'

;---- initial envi, 
;test input parameters

filen = '/home/jiang/nps/cesu/modis_ndvi_250m/wrkdir/2010_multiyear_layer_stack'

p =strpos(filen,'/',/reverse_search)

len=strlen(filen)

wrkdir=strmid(filen,0,p+1)

filebasen=strmid(filen,p+1,len-p)

year=strmid(filen, len-4,4)


start_batch, wrkdir+'b_log',b_unit




flg=0;  0----successs, 1--- not sucess






envi_open_file,filen,r_fid=rt_fid


if rt_fid EQ 0 then begin 

flg=1  ; 0---success, 1--- not success

return  ; 

endif

envi_file_query,rt_fid,dims=dims,nb=nb,ns=ns,nl=nl,fname=fn,bnames=bnames

;---- define two output data buff, data_smoothed and data_metrics

data_metrics=fltarr(ns,nl,12) ; 12 metrics stored in 13 bands for each pixel
 
data_metrics_bnames=['onp','onv','endp','endv','durp','maxp','maxv','ranv','rtup','rtdn','tindvi','mflg']

data=intarr(ns,nb) ; BIL format (num of samples, num of bands)

threshold=-2000;  for point with value below threshold, get rid of them


;----j=ns, i=nl, k=nb

for i=0l, nl-1 do begin  ; every line

data=envi_get_slice(/BIL,fid=rt_fid,line=i)

for j=0l, ns-1 do begin

;---- one spectrum process

print, ' process sample:'+strtrim(string(j),2), ', line:'+strtrim(string(i),2)


if j EQ 781 then begin

print,'pause'

endif


tmp=transpose(data(j,*) ) ; band vector

;---- get rid of no-sense points, 

interpol_nonextension_vector,tmp,bnames,threshold,tmp_interp,tmp_bname_interp

user_smooth, tmp_interp, tmp_smooth


;-----only store mid-year data

mid_idx = where( strmid(tmp_bname_interp,0,1) EQ 1,cnt)

mid_interp=tmp_interp(mid_idx)
mid_smooth= tmp_smooth(mid_idx)
mid_bname= tmp_bname_interp(mid_idx)

;----- define data_smoothed to store smoothed data

if i  EQ 0l and j EQ 0l then begin  ; the very first loop, only execuated once

nb_smooth =n_elements(mid_smooth)

bnames_smooth=mid_bname

data_smooth=intarr(ns,nl,nb_smooth)

endif

;----- store each sptectrum into relevant pixel(j,i)

data_smooth(j,i,*)=mid_smooth


;--- calculate metrics of pixel(j,i) -----------------

;---- only get mid-year data to do one-year metrics 

;idx_mid = where(strmid(tmp_bname_interp,0,1) EQ 1 )

;mid_year_bn=tmp_bname_interp(idx_mid)
;mid_year_smooth=tmp_smooth(idx_mid)
;mid_year_interp=tmp_interp(idx_mid)


user_metrics, mid_smooth, mid_interp, mid_bname, vmetrics ; vout--smoothed vector, vorg--orginal vector, vmetrics--metrics

num_out=n_elements(vmetrics)

data_metrics(j,i,0:num_out-1)=vmetrics


endfor  ; sample loop

endfor  ; line loop






;-----output smoothed data and metrics


map_info=envi_get_map_info(fid=rt_fid)

;---- output smooth data

fileout_smoothed = wrkdir+filebasen+'_smoothed'

ENVI_WRITE_ENVI_FILE,data_smooth,out_name= fileout_smoothed,map_info=map_info,bnames= bnames_smooth,$
                     ns=ns,nl=nl,nb=nb_smooth
                     


;-----output metrics data to '_metrics' file

sz =size(data_metrics)

metrics_ns=sz(1)
metrics_nl=sz(2)
metrics_nb=sz(3)

fileout_metrics=wrkdir+filebasen+'_metrics'

ENVI_WRITE_ENVI_FILE,data_metrics,out_name= fileout_metrics,map_info=map_info,bnames=data_metrics_bnames,$
                     ns=metrics_ns,nl=metrics_nl,nb=metrics_nb
                     
;---- exit batch mode

ENVI_BATCH_EXIT


print,'finishing smooth and calculation of metrics ...'


return

end

