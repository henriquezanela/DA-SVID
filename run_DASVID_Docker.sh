#!/bin/bash

set -e
BASE_DIR=$PWD #Save current directory
DESTINATION_FOLDER="DASVID_POC_DOCKER"

### Start SPIRE environment
sudo cp $BASE_DIR/lib/start_spire_env.sh /spire
echo -e "\n\nCopy the commands below and run them in another terminal"
echo "cd /spire"
echo "sudo bash start_spire_env.sh"
read -rsn1 -p"Now press any key to continue... "
##########

### Create directory
create_new_directory(){
if [ -d /$DESTINATION_FOLDER ]; then
  sudo mkdir "/old_${DESTINATION_FOLDER}"
  sudo mv /$DESTINATION_FOLDER "/old_${DESTINATION_FOLDER}"
fi
sudo mkdir /$DESTINATION_FOLDER
sudo git clone https://github.com/marques-ma/DASVID_PoC_V0 -b docker_vr /$DESTINATION_FOLDER
}
create_new_directory

check_exist_.cfg(){
CFG_PATH="/${DESTINATION_FOLDER}/Assertingwl-mTLS/.cfg"
if [ ! -f "$CFG_PATH" ]; then
  trap "$CFG_PATH file does not exist." EXIT
fi

CFG_PATH="/${DESTINATION_FOLDER}/middle-tier/.cfg"
if [ ! -f "$CFG_PATH" ]; then
  trap "$CFG_PATH file does not exist." EXIT
fi

CFG_PATH="/${DESTINATION_FOLDER}/subject_workload/.cfg"
if [ ! -f "$CFG_PATH" ]; then
  trap "$CFG_PATH file does not exist." EXIT
fi

CFG_PATH="/${DESTINATION_FOLDER}/target_workload/.cfg"
if [ ! -f "$CFG_PATH" ]; then
  trap "$CFG_PATH file does not exist." EXIT
fi
}
check_exist_.cfg

### Grab values from *config* and change all required .cfg files
OKTA_CODE=""
CLIENT_ID=""
CLIENT_SECRET=""
HOST_IP=""
ASSERTING_PORT=""
TARGET_PORT=""
MIDDLE_TIER_PORT=""

## Read config file and copy values to VARs
cp_data_config(){
while IFS= read -r LINE
do
  if grep -q "OKTA_DEVELOPER_CODE" <<< "$LINE"; then
    OKTA_CODE=${LINE#*=}
  elif grep -q "CLIENT_ID" <<< "$LINE"; then
    CLIENT_ID=${LINE#*=}
  elif grep -q "CLIENT_SECRET" <<< "$LINE"; then
    CLIENT_SECRET=${LINE#*=}
  elif grep -q "HOSTIP" <<< "$LINE"; then
    HOST_IP=${LINE#*=}
  elif grep -q "Asserting-wl port" <<< "$LINE"; then
    ASSERTING_PORT=${LINE#*=}
  elif grep -q "Target-wl port" <<< "$LINE"; then
    TARGET_PORT=${LINE#*=}
  elif grep -q "Middle-tier-wl port" <<< "$LINE"; then
    MIDDLE_TIER_PORT=${LINE#*=}
  else
    continue
  fi
done < "${BASE_DIR}/config"
}
cp_data_config

## \/ Change .cfg file of Subject Workload
CFG_PATH="/${DESTINATION_FOLDER}/subject_workload/.cfg"

LINE_MATCH=$(awk '/ISSUER=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  TMP_VAR="ISSUER=https://dev-${OKTA_CODE}.okta.com/oauth2/default"
  sudo sed -i "$LINE_MATCH c \\$TMP_VAR" $CFG_PATH
else
  trap "\"ISSUER=\" string not found in .cfg file." EXIT
fi

LINE_MATCH=$(awk '/CLIENT_ID=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  TMP_VAR="CLIENT_ID=${CLIENT_ID}"
  sudo sed -i "$LINE_MATCH c \\$TMP_VAR" $CFG_PATH
else
  trap "\"CLIENT_ID=\" string not found in .cfg file." EXIT
fi

LINE_MATCH=$(awk '/CLIENT_SECRET=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  TMP_VAR="CLIENT_SECRET=${CLIENT_SECRET}"
  sudo sed -i "$LINE_MATCH c \\$TMP_VAR" $CFG_PATH
else
  trap "\"CLIENT_SECRET=\" string not found in .cfg file." EXIT
fi

LINE_MATCH=$(awk '/HOSTIP=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  TMP_VAR="HOSTIP=${HOST_IP}:8080"
  sudo sed -i "$LINE_MATCH c \\$TMP_VAR" $CFG_PATH
else
  trap "\"HOSTIP=\" string not found in .cfg file." EXIT
fi

LINE_MATCH=$(awk '/ASSERTINGWLIP=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  ASSERTINGWLIP="ASSERTINGWLIP=${HOST_IP}:${ASSERTING_PORT}"
  sudo sed -i "$LINE_MATCH c \\$ASSERTINGWLIP" $CFG_PATH
else
  trap "\"ASSERTINGWLIP=\" string not found in .cfg file." EXIT
fi

LINE_MATCH=$(awk '/TARGETWLIP=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  TARGETWLIP="TARGETWLIP=${HOST_IP}:${TARGET_PORT}"
  sudo sed -i "$LINE_MATCH c \\$TARGETWLIP" $CFG_PATH
else
  trap "\"TARGETWLIP=\" string not found in .cfg file." EXIT
fi

LINE_MATCH=$(awk '/MIDDLETIERIP=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  MIDDLETIERIP="MIDDLETIERIP=${HOST_IP}:${MIDDLE_TIER_PORT}"
  sudo sed -i "$LINE_MATCH c \\$MIDDLETIERIP" $CFG_PATH
else
  trap "\"MIDDLETIERIP=\" string not found in .cfg file." EXIT
fi
## /\Change .cfg file of Subject Workload
########################################
##\/ Change .cfg file of Middler-Tier Workload
CFG_PATH="/${DESTINATION_FOLDER}/middle-tier/.cfg"

LINE_MATCH=$(awk '/ASSERTINGWLIP=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  ASSERTINGWLIP="ASSERTINGWLIP=${HOST_IP}:${ASSERTING_PORT}"
  sudo sed -i "$LINE_MATCH c \\$ASSERTINGWLIP" $CFG_PATH
else
  trap "\"ASSERTINGWLIP=\" string not found in .cfg file." EXIT
fi

LINE_MATCH=$(awk '/TARGETWLIP=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  TARGETWLIP="TARGETWLIP=${HOST_IP}:${TARGET_PORT}"
  sudo sed -i "$LINE_MATCH c \\$TARGETWLIP" $CFG_PATH
else
  trap "\"TARGETWLIP=\" string not found in .cfg file." EXIT
fi
## /\Change .cfg file of Middle-Tier Workload
########################################
## \/Change .cfg file of Target Workload
CFG_PATH="/${DESTINATION_FOLDER}/target_workload/.cfg"

LINE_MATCH=$(awk '/ASSERTINGWLIP=/{ print NR;}' $CFG_PATH)
if test $LINE_MATCH -gt 0; then
  ASSERTINGWLIP="ASSERTINGWLIP=${HOST_IP}:${ASSERTING_PORT}"
  sudo sed -i "$LINE_MATCH c \\$ASSERTINGWLIP" $CFG_PATH
else
  trap "\"ASSERTINGWLIP=\" string not found in .cfg file." EXIT
fi
########################################

### Starting to run containers

echo -e "\n###Building Docker images###\n"
sleep 2
sudo bash $BASE_DIR/docker/build_containers.sh

echo -e "\n###Running Docker containers###\n"
sleep 2
sudo bash $BASE_DIR/docker/run_containers.sh