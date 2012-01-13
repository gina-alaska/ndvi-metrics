#!/bin/bash
#this script produces one year metrics.
#raw ndvi data are stored in $ndvi_data_dir
#idl programs are in $idl_prog_dir
#scripts are stored in $script_dir
#temperature data are stored in $work_dir
#result data are stores in #result_dir
#input: year
#the script must be run in the current directory.

#define the environment variables

if [ $# !=1 ];then

echo "input year"

exit

fi

year=$1

source ./emodis_to_oneyear_env.bash

#unzip raw data from eMODIS

raw_dir=$ndvi_data_dir
rst_dir=$work_dir/$year


#./unzip_ndvi.bash $raw_dir $rst_dir $year 

#rename the unziped files

#./rename_ndvi.bash $rst_dir

#produce two file name lists, one is flist, another is flist_bq,
#flist includes the ndvi data file names, flist_bq includes ndvi bq file names

cd $rst_dir

ls $PWD/*$year*250m_composite_ndvi.tif>flist1

ls $PWD/*$year*250m_composite_ndvi_bq.tif>flist2

cd $idl_prog_dir

full_path_flist1=$rst_dir/flist1
full_path_flist2=$rst_dir/flist2

cd $idl_prog_dir

idl <<EOF
oneyear, '$year','$full_path_flist1','$full_path_flist2'
EOF

exit  


