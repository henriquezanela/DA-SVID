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

### Running startk8s.sh
echo "Running startk8s"
sudo bash $SH_FOLDER/k8s/startk8s.sh

### Create DASVID entries on kubernetes
bash $SH_FOLDER/lib/dasvid_entries.sh

### Running startapp.sh
sudo bash $SH_FOLDER/lib/startapp.sh

#Run this for each asserting,middle tier, subject, target wl with proper ports and pod names
#kubectl port-forward --address localhost,<IP> pod/<PODNAME> PORT:PORT