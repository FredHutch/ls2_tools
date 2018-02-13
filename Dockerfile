FROM fredhutch/ls2_easybuild_foss:2016b

# easyconfig to build 
ARG EB_NAME
ENV EB_NAME=${EB_NAME}

# required OS packages for the build
ENV INSTALL_OS_PKGS "awscli build-essential pkg-config libssl-dev unzip libc6-dev"
# os pkg list to be removed after the build - in EasyBuild, the 'dummy' toolchain requires build-essential
# also, the current toolchain we are using (foss-2016b) does not actually include 'make'
# removing build-essential will mean the resulting container cannot build additional software
ENV UNINSTALL_OS_PKGS "build-essential"
# switch to our non-root user
USER neo
# copy in AWS Batch's "fetch-and-run" for S3-based scripts
COPY aws-batch-helpers/fetch-and-run/fetch_and_run.sh /home/neo/fetch_and_run.sh
# copy in easyconfigs (so many due to missing dependencies in existing easyconfigs)
COPY easyconfigs/* /app/fh_easyconfigs/
# R sources that cannot be programmatically downloaded
COPY sources/* /app/sources/
COPY install.sh /app
# run script to download larger sources
RUN /bin/bash /app/sources/download_sources.sh
# install build-essential, build R, remove build-essential
# EVERYTHING beyond build-essential needs to be moved into EB!!!
USER root
RUN mkdir /opt/software /var/tmp/build && chown neo:neo /opt/software /var/tmp/build
RUN apt-get update -y && apt-get install -y $INSTALL_OS_PKGS 
RUN  su -c "/bin/bash /app/install.sh" neo &&
 module use /app/modules/all && \
 module load EasyBuild" # && \
 . /app/sources/dev_env.sh && \
 cd /app/fh_easyconfigs && \
 eb -l $EASYCONFIG_NAME --robot"
#USER root
#RUN  apt-get remove -y --purge $UNINSTALL_OS_PKGS && \
# apt-get autoremove -y
