#!/bin/bash

#rename file name of *.ndvi.tif and *.bq.tif with 250m

if [$# != 1 ]; then

echo "one input parameter needed: dir_of_unzipped_file"

exit 1

fi


dir_wrk=$1

cd $dir_wrk

ls  MT3RG_????_??-??_250m_composite_ndvi.tif >tmplist

#sed -n '/MT3RG_2010_..-.._250m_composite_ndvi.tif/p' $dir_wrk/flist >tmp

for i in $(ls MT3RG_????_??-??_250m_composite_ndvi.tif ) ;do

yyyy=`expr $i : '......\(....\)'`
doy1=`expr $i : '...........\(..\)'`
doy2=`expr $i : '..............\(..\)'`

echo $yyyy
echo $doy1
echo $doy2

mv $i MT3RG_${yyyy}_0${doy1}-0${doy2}_250m_composite_ndvi.tif

done


# rename ??-??? files

ls  MT3RG_????_??-???_250m_composite_ndvi.tif >tmplist

#sed -n '/MT3RG_????_..-.._250m_composite_ndvi.tif/p' $dir_wrk/flist >tmp

for i in $(ls MT3RG_????_??-???_250m_composite_ndvi.tif ) ;do

yyyy=`expr $i : '......\(....\)'`
doy1=`expr $i : '...........\(..\)'`
doy2=`expr $i : '..............\(...\)'`

echo $yyyy
echo $doy1
echo $doy2

mv $i MT3RG_${yyyy}_0${doy1}-${doy2}_250m_composite_ndvi.tif


done


# rename ndvi_bq.tif 

#ls  MT3RG_????_??-??_250m_composite_ndvi_bq.tif >tmplist1

#sed -n '/MT3RG_????_..-.._250m_composite_ndvi.tif/p' $dir_wrk/flist >tmp

for i in $(ls MT3RG_????_??-??_250m_composite_ndvi_bq.tif ) ;do

yyyy=`expr $i : '......\(....\)'`
doy1=`expr $i : '...........\(..\)'`
doy2=`expr $i : '..............\(..\)'`

echo $yyyy
echo $doy1
echo $doy2

mv $i MT3RG_${yyyy}_0${doy1}-0${doy2}_250m_composite_ndvi_bq.tif
done 


# rename ??-??? files

ls  MT3RG_????_??-???_250m_composite_ndvi.tif >tmplist

#sed -n '/MT3RG_????_..-.._250m_composite_ndvi.tif/p' $dir_wrk/flist >tmp

for i in $(ls MT3RG_????_??-???_250m_composite_ndvi_bq.tif ) ;do

yyyy=`expr $i : '......\(....\)'`
doy1=`expr $i : '...........\(..\)'`
doy2=`expr $i : '..............\(...\)'`

echo $yyyy
echo $doy1
echo $doy2

mv $i MT3RG_${yyyy}_0${doy1}-${doy2}_250m_composite_ndvi_bq.tif

done

exit
