#!/bin/bash

cd /
git clone https://github.com/spiffe/spire.git
cd /spire
make build
sed -i 's/secure_path=\"/secure_path=\"\/spire\/bin:/' /etc/sudoers
source ~/.bashrc
