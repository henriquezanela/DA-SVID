#!/bin/bash

DIRPATH=/DASVID_POC_K8S

#docker rm $(docker stop $(docker ps -a -q))
#docker rmi -f asserting-wl subject-wl middle-tier target-wl
#docker rmi $(docker images -q)

cd "${DIRPATH}/Assertingwl-mTLS"
docker build . -t asserting-wl
sleep 0.5

cd "${DIRPATH}/subject_workload"
docker build . -t subject-wl
sleep 0.5

cd "${DIRPATH}/target_workload"
docker build . -t target-wl
sleep 0.5

cd "${DIRPATH}/middle-tier"
docker build . -t middle-tier
sleep 0.5
