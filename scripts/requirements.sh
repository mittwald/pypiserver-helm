#!/usr/bin/env bash

set -e

GENERIC_BIN_DIR="/usr/local/bin"

## Generic stuff
apt-get -qq update
apt-get -qq install curl

## Install Helm
if [[ ! -x "$(command -v helm)" ]]; then
    export HELM_INSTALL_DIR="${GENERIC_BIN_DIR}"
    HELM_BIN="${GENERIC_BIN_DIR}/helm"

    curl -sS -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    chmod +x ${HELM_BIN}
fi