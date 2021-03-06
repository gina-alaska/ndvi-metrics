;this program produce one year ndvi data. It accepts one year ndvi files, get only good pixel which indicated in each related quality file, then
;layer these gooded data together into a yearly-good data. When user input ul and lr, it also do subsize of the data. But normally we need do
;whole alaska region data( with ul=0 and lr=0)

;oneyear_main_yyyy.pro

year='2010'

wrkdir='/home/jiang/nps/cesu/modis_ndvi_250m/wrkdir/'

;wrkdir='c:\nps\modis_ndvi_250m\'

;----- produce two file lists

flist1=wrkdir+year+'_flist_ndvi'
flist2=wrkdir+year+'_flist_ndvi_bq'

if !version.os_family EQ 'Windows' then begin

cmd ='dir /s/B '
sign='\'

endif else begin

cmd='ls '
sign='/'
endelse

cmd_ndvi = cmd+wrkdir+year+ sign+'*'+year+'*250m_composite_ndvi.tif >'+flist1

cmd_ndvi_bq = cmd+wrkdir+year+sign+'*'+year+'*250m_composite_ndvi_bq.tif >'+flist2

spawn,cmd_ndvi

spawn,cmd_ndvi_bq

;---- call oneyaet_data_layer_subset

;---- subset coorninates-------------

;----lon and lat, decided by SWAN

;ul=[-160, 62]

;lr=[-146, 56]

ul=0 & lr=0


;ul=[-206833.75D, 1303877.50D]
;lr=[ 424916.25D,  856877.50D]
;flist1=wrkdir+'flist_ndvi_'+year
;flist2=wrkdir+'flist_ndvi_bq_'+year


;------ open envi-----

start_batch, wrkdir+'b_log',b_unit


oneyear_data_layer_subset_good, flist1,flist2,ul,lr


envi_batch_exit

print,'finish one year data preparation...'

end

