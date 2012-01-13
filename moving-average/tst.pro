pro tst, flist_ndvi, flist_bq, ul_lon,ul_lat,lr_lon,lr_lat
print, flist_ndvi, flist_bq, ul_lon,ul_lat,lr_lon,lr_lat
openw,10,'tst_rst'
printf,10, flist_ndvi, flist_bq, ul_lon,ul_lat,lr_lon,lr_lat
close,10
end
