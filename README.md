# Install Automation for DA-SVID extension in SPIFFE/SPIRE

The scripts here work as a solution for the task of installing automatically both Proof of Concepts for [Docker](https://github.com/marques-ma/DASVID_PoC_V0/tree/docker_vr) and [Kubernetes with minikube](https://github.com/marques-ma/DASVID_PoC_V0/tree/PoC_ZKP). 

## Prerequisites

* curl
* git
* make
* build-essential
* socat (only for minikube K8S)
* OKTA account (Application with client ID, client Secret and authorized callback URI)

All scripts were previously tested on fresh Virtual Machines with:

* Debian GNU/Linux 11 (bullseye).

* Ubuntu 20.04.4 LTS (focal).

## Installation

It is assumed you have access to the [OKTA Developer platform](https://developer.okta.com/) with the Application setup already configured.

After download the repository, it is necessary to change permission on all scripts to run as executables:

```bash
sudo chmod +x -R *.sh && sudo chmod +x lib/*.sh
```

1. Run **requirements.sh** if you do not have all required packages installed.

2. Now, before you run the **installation.sh**, it is necessary to put your data in the **config** file:
    * If you **DO NOT** want to install SPIRE, Kubernetes or Docker (probably because you already have it), change values to TRUE.
    * With the OKTA information and the host IP (probably the machine you will run the proof of concept), change each line accordingly.

3. After the installation, you can run either the environment from Docker or Kubernetes with minikube, using the proper script.

## 📫 Contributions

Undergraduate Henrique Zanela Cochak (UDESC)

Undergraduate Gabriel Dias Tambelli (USP)

## License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)