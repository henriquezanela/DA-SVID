#!/bin/bash

set -e
SH_FOLDER=$PWD

### Start SPIRE environment
sudo cp $LIB_PATH/start_spire_env.sh /spire
sudo bash /spire/start_spire_env.sh

### Create directory
DESTINATION_FOLDER="DASVID_POC_K8S"
cd /
if [ -d $DESTINATION_FOLDER ]; then
  sudo mv $DESTINATION_FOLDER "/old_${DESTINATION_FOLDER}"
fi
sudo mkdir $DESTINATION_FOLDER
sudo git clone https://github.com/marques-ma/DASVID_PoC_V0 -b PoC_ZKP $DESTINATION_FOLDER

### Grab values from config and change in .cfg
CFG_PATH="${DESTINATION_FOLDER}/subject_workload/.cfg"

if test -f "$CFG_PATH"; then
  while IFS= read -r LINE
  do
    if grep -q "OKTA_DEVELOPER_CODE" <<< "$LINE"; then
      OKTA_CODE=${LINE#*=}  
      LINE_MATCH=$(awk '/ISSUER=/{ print NR;}' $CFG_PATH)
      if test $LINE_MATCH -gt 0; then
        NEW_ISSUER="ISSUER=https://dev-${OKTA_CODE}.okta.com/oauth2/default
  "   
        sudo sed -i "$LINE_MATCH c \\$NEW_ISSUER" $CFG_PATH
      else
        trap "\"ISSUER\" string not found in .cfg file." EXIT
      fi
    elif grep -q "CLIENT_ID" <<< "$LINE"; then
      CLIENT_ID=${LINE#*=}
      LINE_MATCH=$(awk '/CLIENT_ID=/{ print NR;}' $CFG_PATH)
      if test $LINE_MATCH -gt 0; then
        NEW_CLIENT_ID="CLIENT_ID=${CLIENT_ID}"
        sudo sed -i "$LINE_MATCH c \\$NEW_CLIENT_ID" $CFG_PATH
      else
        trap "\"CLIENT_ID\" string not found in .cfg file." EXIT
      fi
    elif grep -q "CLIENT_SECRET" <<< "$LINE"; then
      CLIENT_SECRET=${LINE#*=}
      LINE_MATCH=$(awk '/CLIENT_SECRET=/{ print NR;}' $CFG_PATH)
      if test $LINE_MATCH -gt 0; then
        NEW_CLIENT_SECRET="CLIENT_SECRET=${CLIENT_SECRET}"
        sudo sed -i "$LINE_MATCH c \\$NEW_CLIENT_SECRET" $CFG_PATH
      else
        trap "\"CLIENT_SECRET\" string not found in .cfg file." EXIT
      fi
    elif grep -q "HOSTIP" <<< "$LINE"; then
      HOST_IP=${LINE#*=}
      LINE_MATCH=$(awk '/HOSTIP=/{ print NR;}' $CFG_PATH)
      if test $LINE_MATCH -gt 0; then
        NEW_HOST_IP="HOSTIP=${HOST_IP}:8080"
        sudo sed -i "$LINE_MATCH c \\$NEW_HOST_IP" $CFG_PATH
      else
        trap "\"HOSTIP\" string not found in .cfg file." EXIT
      fi 
    else
      continue
    fi
  done < "${SH_FOLDER}/config"
else
  trap ".cfg file not found in ${CFG_PATH}." EXIT
fi

### Building Docker images
echo "Building Docker images."
sudo bash $SH_FOLDER/k8s/build_containers.sh
sleep 2

########################################
#\/ \/ \/ This is startk8s.sh #\/ \/ \/#
########################################
####https://stackoverflow.com/questions/72926905/minikube-start-stuck-pulling-base-image
minikube start \
    --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/sa.key \
    --extra-config=apiserver.service-account-key-file=/var/lib/minikube/certs/sa.pub \
    --extra-config=apiserver.service-account-issuer=api \
    --extra-config=apiserver.service-account-api-audiences=api,spire-server \
    --extra-config=apiserver.authorization-mode=Node,RBAC \
sleep 3

# Continuing the installation based on https://minikube.sigs.k8s.io/docs/start/
kubectl get po -A
minikube kubectl -- get po -A
alias kubectl="minikube kubectl --"

# Based on spire-tutorials repo: https://github.com/spiffe/spire-tutorials.git
cd /spire-tutorials/k8s/quickstart

# Create the namespace:
kubectl apply -f spire-namespace.yaml
sleep 3
kubectl get namespaces

# Create the server’s service account, configmap and associated role bindings as follows:
kubectl apply \
    -f server-account.yaml \
    -f spire-bundle-configmap.yaml \
    -f server-cluster-role.yaml
sleep 3

# Deploy the server configmap and statefulset by applying the following files via minikube kubectl --:
kubectl apply \
    -f server-configmap.yaml \
    -f server-statefulset.yaml \
    -f server-service.yaml
sleep 3
kubectl get statefulset --namespace spire

# To allow the agent read access to the kubelet API to perform workload attestation, 
# a Service Account and ClusterRole must be created that confers the appropriate entitlements 
# to Kubernetes RBAC, and that ClusterRoleBinding must be associated with the service account 
# created in the previous step.
kubectl apply \
    -f agent-account.yaml \
    -f agent-cluster-role.yaml
sleep 3

# Apply the agent-configmap.yaml configuration file to create the agent configmap and deploy the 
# Agent as a daemonset that runs one instance of each Agent on each Kubernetes worker node.
kubectl apply \
    -f agent-configmap.yaml \
    -f agent-daemonset.yaml

# Longer sleep, giving time to initialization
sleep 45

# Check if everything is running
kubectl get daemonset --namespace spire
kubectl get pods --namespace spire

#######################################
#/\ /\ /\ This is startk8s.sh /\ /\ /\#
#######################################


### Create DASVID entries on kubernetes
bash $SH_FOLDER/lib/dasvid_entries.sh


##########################################
#\/ \/ \/ Similar to startapp.sh \/ \/ \/#
##########################################
kubectl delete --all deployments
kubectl delete --all service

minikube image load asserting-wl
cd "/${DESTINATION_FOLDER}/Assertingwl-mTLS"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5

minikube image load subject-wl
cd "/${DESTINATION_FOLDER}/subject_workload"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5

minikube image load target-wl
cd "/${DESTINATION_FOLDER}/target_workload"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5

minikube image load middle-tier
cd "/${DESTINATION_FOLDER}/middle-tier"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 0.5
##########################################
#/\ /\ /\ Similar to startapp.sh /\ /\ /\#
##########################################

sudo bash "/${DESTINATION_FOLDER}/k8s/run_containers.sh"
#kubectl port-forward --address localhost,<IP> pod/<PODNAME> PORT:PORT