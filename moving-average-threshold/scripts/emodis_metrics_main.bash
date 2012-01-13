#!/bin/bash
#this script do calculate oneyear ndvi metrics from eMODIS data to final one-year- metrics file
#input parameter: year

#define the environment variables

source ./emodis_to_oneyear_env.bash
#year1=$1
#year2=$2
#year3=$3

year1=2009
year2=2010
year3=2011

emodis_to_oneyear.bash $year1
emodis_to_oneyear.bash $year2
emodis_to_oneyear.bash $year3

# construct a flist which includes three consecutive years of files name

ls $work_dir/$year1/${year1}_oneyear_layer_stack_0_200_set_snow_cloud_n4000  >flist
ls $work_dir/$year2/${year2}_oneyear_layer_stack_0_200_set_snow_cloud_n4000 >>flist
ls $work_dir/$year3/${year3}_oneyear_layer_stack_0_200_set_snow_cloud_n4000 >>flist

#combine three one-year files to a three-year file

oneyear_to_threeyear.bash $flist

#calculate the $year2 ndvi metrics

mtfile= $work_dir/${year2}_multiyear_layer_stack_0_200_set_snow_cloud_n4000

ndvimetrics.bash $mtfile

exit

