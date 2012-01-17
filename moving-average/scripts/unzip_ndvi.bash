#!/bin/bash
#This script accept user's inputs: raw_dir (raw data home directory),rst_dir( result data home directy),year
#it unzip the files

if [$# != 3 ]; then 

echo
echo "this script take three parameters: raw data home directory, result data homedirector,and year"
echo
exit 1

fi

dir_input=$1

dir_output=$2

year=$3


#get each sub direct name

echo "${dir_input}/${year}/"

for fn in $(ls ${dir_input}/${year}/); do

num=`expr $fn : '.*'`

echo $num

echo $fn

if [ $num -eq 7 ] ;then 

doy=`expr $fn : '.....\(..\)'`

else 

doy=`expr $fn : '.....\(...\)'`

fi

echo $doy

filen=$dir_input/$year/$fn/composite250m_TERRA_NDVI_${year}_${doy}.zip

echo 'file name: ' $filen

if [ -f $filen ] ;then

echo 'start to unzip...'

unzip -u $filen -d $dir_output

#doy2=$(( doy +6))
#if  $doy2  -lt 100 ; then
#echo *_$year_$doy-$doy2_250m_composite250m_*
#exit
#mv *_$year_$doy-$doy2_250m_composite250m_* *_$year_0$doy-0${doy2}_250m_composite250m_*
#else if (($doy -lt 100)) && (($doy2 -ge 100)) ;then
#exit
#       mv *_$year_$doy-$doy2_250m_composite250m_* *_$year_0$doy-$doy2_250m_composite250m_*
#     fi 
#fi

echo 'unzip the file:' $filen

fi

done

echo 'finish unzip data...'

exit
