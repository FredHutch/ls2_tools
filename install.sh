#!/bin/bash

set -x
set -e

# variables used: EB_NAME

# try to preserve group write here
umask 002

# load modules
source /app/lmod/lmod/init/bash
module use /app/modules/all

# load Easybuild
module load EasyBuild

# environment for development
#
export EASYBUILD_INSTALLPATH_SOFTWARE=/opt/software
export EASYBUILD_BUILDPATH=/var/tmp/build

# build the easyconfig file
for easyconfig in /app/fh_easyconfigs; do
    echo Building: $easyconfig
    eb -l ${easyconfig}.eb --robot
done
