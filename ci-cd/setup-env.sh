#!/bin/sh
# Copyright (c) 2018, WSO2 Inc. (http://wso2.com) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

GET_DISTRO_FROM_CUSTOM_LOCATION=true
CUSTOM_DISTRO_LOCATION="http://10.100.5.112:8000/ballerina-tools-pack.zip"

# Create a temp directory
mkdir tmp
cd tmp

if [ "$GET_DISTRO_FROM_CUSTOM_LOCATION" = true ]; then

echo "Downloding the distribution from custom location : " $CUSTOM_DISTRO_LOCATION
wget $CUSTOM_DISTRO_LOCATION

else

# This is triggered from fetch-artifacts.sh
JENKINS_BASE_URL="https://wso2.org/jenkins/job/ballerina-platform/job/ballerina"
#Get the Latest Successful Build URL from JENKINS
#https://wso2.org/jenkins/job/ballerina-platform/job/ballerina/org.ballerinalang$ballerina/api/xml
latest_successfull_build=$(curl -s "$JENKINS_BASE_URL/api/xml?xpath=//lastStableBuild/url")
echo "Latest successful build ID : " $latest_successfull_build

#Extract the URL from the latest_successfull_build
latest_successfull_build_url=$(echo $latest_successfull_build | sed -n 's:.*<url>\(.*\)</url>.*:\1:p')
echo "Latest Successful Build URL : "$latest_successfull_build_url

# Get the relativePath of the distribution pack
dirtribution_url=$(curl -s -G $latest_successfull_build_url"org.ballerinalang\$ballerina-tools/api/xml" -d "xpath=//artifact[2]/relativePath")
# Extracting the relative path to the distribution pack
downloadable_url=$(echo $dirtribution_url | sed -n 's:.*<relativePath>\(.*\)</relativePath>.*:\1:p')

echo "Downloadable URL : " $latest_successfull_build_url"org.ballerinalang\$ballerina-tools/artifact/"$downloadable_url
wget $latest_successfull_build_url"org.ballerinalang\$ballerina-tools/artifact/"$downloadable_url

fi

# Unzip the ballerina distribution
unzip -q ballerina-tools-*.zip

# Remove the ballerina zip file
rm -rf ballerina-tools-*.zip

# Rename the unzip directory
mv ballerina-tools-* ballerina

chmod +x ballerina/bin/ballerina