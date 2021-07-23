#!/bin/bash
# ============ 
# Bash configuration
# -e exit on first error
# -u error is variable unset
# -x display commands for debugging
set -eux

# ============================
# NOTES:
# This file goes into Jenkins /usr/local/bin
# Properties (LANGUAGES, STATIC_DEPLOY_PARAMS, DISABLE_MODULES) are set in the project:
#	 - https://github.com/jalogut/magento-2.2-demo/blob/master/config/properties.sh
# TAR excludes also defined in project:
#    - https://github.com/jalogut/magento-2.2-demo/blob/master/config/artifact.excludes
# ============================
WORKING_DIR=`pwd`
#source ${WORKING_DIR}/config/properties.sh
#ARTIFACT_EXCLUDES=${WORKING_DIR}/config/artifact.excludes


MAGENTO_DIR='magento'

BUILD=${WORKING_DIR}

# GET CODE
# git clone not needed for Jenkins
cd ${BUILD}
#composer install --no-dev --prefer-dist --optimize-autoloader --ignore-platform-reqs

# GENERATE FILES
#cd ${BUILD}/${MAGENTO_DIR}
#if [[ -n ${DISABLE_MODULES} ]]; then
#    bin/magento module:disable ${DISABLE_MODULES}
#fi
#bin/magento setup:di:compile
#bin/magento setup:static-content:deploy -f ${LANGUAGES} ${STATIC_DEPLOY_PARAMS}
wget https://www.dropbox.com/s/pr157zr52lqu5qt/magento-1.9.3.7-2017-11-27-05-32-35.tar.gz
tar -xzf magento-1.9.3.7-2017-11-27-05-32-35.tar.gz 
rm magento-1.9.3.7-2017-11-27-05-32-35.tar.gz
cd magento
find var media app/etc -type d -exec chmod 777 {} \;

# CREATE ARTIFACT
cd ${BUILD}
tar  -czf ${ARTIFACT_FILENAME} .

# RETURN TO WORKING DIR
cd ${WORKING_DIR}
