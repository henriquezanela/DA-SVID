#!/bin/bash

Asserting_port=''
Subject_port=8080
MT_port=''
Target_port=''

BASE_DIR=$PWD
cd ..
BASE_DIR=$PWD
## Read config file and copy values to VARs
cp_data_config(){
while IFS= read -r LINE
do
  if grep -q "Asserting-wl port" <<< "$LINE"; then
    Asserting_port=${LINE#*=}
  elif grep -q "Target-wl port" <<< "$LINE"; then
    MT_port=${LINE#*=}
  elif grep -q "Middle-tier-wl port" <<< "$LINE"; then
    Target_port=${LINE#*=}
  else
    continue
  fi
done < "${BASE_DIR}/config"
}
cp_data_config

docker run -p "${Asserting_port}:${Asserting_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d asserting-wl
sleep 1
docker run -p "${Subject_port}:${Subject_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d subject-wl
sleep 1
docker run -p "${MT_port}:${MT_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d middle-tier
sleep 1
docker run -p "${Target_port}:${Target_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d target-wl
sleep 1

### To run manually use below

# docker run -p 8443:8443 -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d asserting-wl

# docker run -p 8080:8080 -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d subject-wl

# docker run -p 8445:8445 -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d middle-tier

# docker run -p 8444:8444 -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d target-wl
