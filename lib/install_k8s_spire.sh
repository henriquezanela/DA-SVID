#!/bin/bash

# Starting the installation based on https://minikube.sigs.k8s.io/docs/start/
cd /
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
dpkg -i minikube_latest_amd64.deb
rm minikube_latest_amd64.deb

# Cloning spire-tutorials
cd /
git clone https://github.com/spiffe/spire-tutorials.git