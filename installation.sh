#!/bin/bash

slp=2

function DA-SVID_inst(){
skip_SPIRE=''
skip_DOCKER=''
skip_K8S=''

### Reading config file and picking options to SKIP
echo -e "\n###Reading config file to pick what to install###\n"
sleep $slp
while IFS= read -r LINE
do
  LINE=$(echo $LINE | tr '[:lower:]' '[:upper:]')
  if grep -q "SPIRE" <<< "$LINE"; then
    TMP=${LINE#*=}
    if [ $TMP == 'TRUE' ] || [ $TMP == 'FALSE' ]; then
      skip_SPIRE=$TMP
    else
      trap "Error reading config file. Must be string TRUE or FALSE." EXIT
    fi
  elif grep -q "DOCKER" <<< "$LINE"; then
    TMP=${LINE#*=}
    if [ $TMP == 'TRUE' ] || [ $TMP == 'FALSE' ]; then
      skip_DOCKER=$TMP
    else
      trap "Error reading config file. Must be string TRUE or FALSE." EXIT
    fi
  elif grep -q "K8S" <<< "$LINE"; then
    TMP=${LINE#*=}
    if [ $TMP == 'TRUE' ] || [ $TMP == 'FALSE' ]; then
      skip_K8S=$TMP
    else
      trap "Error reading config file. Must be string TRUE or FALSE." EXIT
    fi
  else
    continue
  fi
done < "config"
echo -e "\n###DONE###\n"

### Installation section 
LIB_PATH=$(pwd)"/lib"

if [ $skip_SPIRE == 'FALSE' ]; then
  echo -e "\n###Begin SPIRE installation###\n"
  sleep $slp
  sudo bash $LIB_PATH/install_spire.sh
  echo -e "\n###SPIRE installed###\n"
  sleep $slp
fi
if [ $skip_DOCKER == 'FALSE' ]; then
  echo -e "\n###Begin DOCKER installation###\n"
  sleep $slp
  sudo bash $LIB_PATH/install_docker.sh
  echo -e "\n###DOCKER installed###\n"
  sleep $slp
fi
if [ $skip_K8S == 'FALSE' ]; then
  echo -e "\n###Begin Minikube installation###\n"
  sleep $slp
  sudo bash $LIB_PATH/install_k8s_spire.sh
  echo -e "\n###Minikube installed###\n"
  sleep $slp
fi
}

DA-SVID_inst

if [ -d "/var/lib/docker" ]; then
  :
else
  trap "/var/lib/docker directory not found. Is Docker installed? Closing application..." EXIT
fi
if [ -d "/spire" ]; then
  :
else
  trap "/spire directory not found. Is SPIRE installed? Closing application..." EXIT
fi

echo -e "\n###Add ${USER} to docker group with root privileges###\n"
sleep $slp
sudo usermod -aG docker $USER
su - $USER
echo -e "\n###${USER} added successfully###\n"
sleep $slp