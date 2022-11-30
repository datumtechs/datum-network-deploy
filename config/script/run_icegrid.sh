#!/bin/bash

script_dir=$(dirname $0)
bin_dir=$script_dir
lib_dir=$script_dir/../lib
# Get the channel SDK installation directory (without Spaces)
sdk_install_dir=`pip show datum-network-channel-sdk | grep Location:`
if [ $? == 0 ]; then
    sdk_install_dir=${sdk_install_dir#*Location: }
    lib_dir=$sdk_install_dir/channel_sdk/lib
fi
echo lib_dir:$lib_dir

config_dir=$script_dir/../config
config_file=${config_dir}/config.gridregistry
data_dir=deploy/lmdb/registry
mkdir -p $data_dir
log_dir=${script_dir}/../logs
datefmt=$(date +'%Y%m%d%H%M%S')
mkdir -p ${log_dir}

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$lib_dir
echo "current log file: ${log_dir}/icegrid-${datefmt}.log"
$bin_dir/icegridregistry --Ice.Config=$config_file

exit 0
