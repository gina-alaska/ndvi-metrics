#!/bin/bash
#this script stack three one-year-files togethere to get a three-year-file
#inputs:year,before_year_file, current_year_file,after_year_file,output_dir
#output:three-year-file

#check if input parameters are correct

if [ $# != 5 ];then
echo
echo "input year,file_before_year, file_current_year, file_after_year, output_dir"
echo
exit 1
fi
year=$1
file_before=$2
file_current=$3
file_after=$4
output_dir=$5
#define the environment variables

source ./modis_ndvi_env_v2.bash

#construct a flist which includes three files, save to $dir_wrk

cd $dir_wrk

echo $file_before >${year}_multiyer_flist
echo $file_current>>${year}_multiyer_flist
echo $file_after>>${year}_multiyer_flist

flist=$dir_wrk/${year}_multiyr_flist

cd $dir_idl

#idl <<EOF
#layer_stack, '$flist','$output_dir'
#EOF

idl<<EOF
tst,'$flist','$output_dir'
EOF

exit 0  


