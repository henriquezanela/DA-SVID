#!/bin/bash

DIRPATH=/DASVID_POC_DOCKER

#docker stop $(docker ps -a -q)

#docker rmi -f asserting-wl subject-wl middle-tier target-wl

#docker rm $(docker stop $(docker ps -a -q)) && docker rmi $(docker images -q)

cd "${DIRPATH}/Assertingwl-mTLS"
docker build . -t asserting-wl
sleep 2

cd "${DIRPATH}/subject_workload"
docker build . -t subject-wl
sleep 2

cd "${DIRPATH}/target_workload"
docker build . -t target-wl
sleep 2

cd "${DIRPATH}/middle-tier"
docker build . -t middle-tier
sleep 2

### To run manually use below

# cd "/DASVID_POC_DOCKER/Assertingwl-mTLS"
# docker build . -t asserting-wl

# cd "/DASVID_POC_DOCKER/subject_workload"
# docker build . -t subject-wl

# cd "/DASVID_POC_DOCKER/target_workload"
# docker build . -t target-wl

# cd "/DASVID_POC_DOCKER/middle-tier"
# docker build . -t middle-tier