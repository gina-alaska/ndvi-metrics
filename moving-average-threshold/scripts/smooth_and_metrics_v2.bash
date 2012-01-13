#!/bin/bash
#this script acceppt a three-year-file, smooth the file and calculate metrics
#inputs:three_year_file
#outputs: a one-year-smoothed file, an one-year-metrics file, save in the same directory as input three-year-file

#check input parameters

if [ $# != 1 ];then
echo
echo "input three-year-file, ouput_dir"
echo
exit 1
fi

filen=$1

#check if the filen exists

if [ ! -f "$filen" ];then
echo
echo "input the file  does not exist"
echo 
fi




#define the environment variables

source ./modis_ndvi_env_v2.bash

cd $dir_idl

#idl<<EOF
#smooth_calculate_metrics_tile_ver15,'$filen'
#EOF

idl<<EOF
tst,'$filen','bbbb'
EOF


exit 0

