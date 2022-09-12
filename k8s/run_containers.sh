#!/bin/bash

Asserting_port=8443
Subject_port=8080
MT_port=8445
Target_port=8444

docker run -p "${Asserting_port}:${Asserting_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d asserting-wl
sleep 1
docker run -p "${Subject_port}:${Subject_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d subject-wl
sleep 1
docker run -p "${MT_port}:${MT_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d middle-tier
sleep 1
docker run -p "${Target_port}:${Target_port}" -v /tmp/spire-agent/public/api.sock:/tmp/spire-agent/public/api.sock -d target-wl
sleep 1
