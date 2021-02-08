#!/usr/bin/env bash

set -e

## debug if desired
if [[ -n "${DEBUG}" ]]; then
    set -x
fi

## make this script a bit more re-usable
GIT_REPOSITORY="github.com/mittwald/pypiserver-helm.git"
CHART_YAML="./pypiserver/Chart.yaml"

## avoid noisy shellcheck warnings
TAG="${GITHUB_REF:10}"
[[ -n "${TAG}" ]] || TAG="0.0.0"
GITHUB_TOKEN="${GITHUB_TOKEN:-dummy}"

## temp working vars
TIMESTAMP="$(date +%s )"
TMP_DIR="/tmp/${TIMESTAMP}"

## set up Git-User
git config --global user.name "Mittwald Machine"
git config --global user.email "opensource@mittwald.de"

## temporary clone git repository
git clone "https://${GIT_REPOSITORY}" "${TMP_DIR}"
cd "${TMP_DIR}"

## replace chart version with current tag without 'v'-prefix
sed -i "s#version:.*#version: ${TAG}#g" "${CHART_YAML}"

## useful for debugging purposes
git status

## Add new remote with credentials baked in url
git remote add publisher "https://mittwald-machine:${GITHUB_TOKEN}@${GIT_REPOSITORY}"

## add and commit changed file
git add -A

## useful for debugging purposes
git status

## stage changes
git commit -m "Bump chartVersion to '${TAG}'"

## rebase
git pull --rebase publisher main

if [[ "${1}" == "publish" ]]; then

    ## publish changes
    git push publisher main

    ## trigger helm-charts reload
    curl -X POST 'https://api.github.com/repos/mittwald/helm-charts/dispatches' -u "mittwald-machine:${GITHUB_TOKEN}" -d '{"event_type": "updateCharts"}'

fi


exit 0