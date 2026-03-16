#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

_helper_log_patch_started

cd "${REPO_DIR}"

# get the upstream sync version from vendir.yml
UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].githubRelease.tag ${REPO_DIR}/vendir.yml)

set -x
cp "${SCRIPT_DIR_REL}"/manifests/* "${CHART_DIR}"

sed -i -E "s/IMAGE_TAG/${UPSTREAM_SYNC_VERSION}/g" "${CHART_DIR}/values.yaml"
{ set +x; } 2>/dev/null

_helper_log_patch_finished
