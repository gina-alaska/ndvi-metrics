#!/bin/bash
#This combines three oneyear data files together.
#inout:file_list, in which are three oneyear files.
#output:a threeyear file
source ./emodis_to_oneyear_env.bash

if [ $# != 1 ]; then
echo " please give a file list name"
exit 1
fi

flist=$1
cd $idl_prog_dir

idl<<EOF
layer_stack,'$flist'
EOF
exit
 
