#!/bin/bash
#this script calcualte ndvi metrics.
#input: a threeyear file name
#outputs: a smooth data file, a metrics file


if [ $# != 1 ];then

echo "input a multiple year data file name"

exit 1

fi


#load environment variabels

source ./emodis_to_oneyear_env.bash

cd $idl_prog

multi_year_file=$1

idl<<EOF
smooth_calculate_metrics_tile,'$multi_year_file'
EOF

exit
