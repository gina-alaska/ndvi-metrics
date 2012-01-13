#!/bin/bash
#This script accept user's inputs: raw_dir (raw data home directory),rst_dir( result data home directy),year
#it unzip the files and store in $dir_output/$year
#for example:
#dir_input=/mnt/pod/ndvi_emodis_archive/emodis/Alaska/historical/TERRA
#dir_output=/home/jiang/nps/cesu/modis_ndvi_250m/wrkdir
#year=2010

if [ $# != 3 ]; then 

echo
echo "this script take three parameters: raw data home directory, result data homedirector,and year"
echo
exit 1

fi

dir_input=$1

dir_output=$2

year=$3


mkdir -p $dir_output/$year

#get each sub direct name

echo "${dir_input}/${year}/"

cd $dir_input/$year

ls -d comp_*>subdirlist

while read line
do

echo $line

for fn in $(ls ${dir_input}/${year}/${line}/*NDVI*QKM*.zip); do

echo $fn
echo 'start to unzip...'

unzip -u $fn -d $dir_output/$year


done

done < subdirlist

echo 'finish unzip data...'

exit
