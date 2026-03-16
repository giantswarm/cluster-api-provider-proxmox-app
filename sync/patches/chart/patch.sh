#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

_helper_log_patch_started

cd "${SCRIPT_DIR}"

# we need to get the current version of the chart in order to
# reset it after copying Chart.yaml over.
CHART_VERSION=$(yq -r '.version' "${CHART_DIR}/Chart.yaml") ; readonly CHART_VERSION

# we need to set the appVersion field in Chart.yaml to match the
# version being synced from upstream.

# get the upstream sync version from vendir.yml
UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].githubRelease.tag ${REPO_DIR}/vendir.yml)
# strip leading 'v' if present
UPSTREAM_SYNC_VERSION_STRIPPED="${UPSTREAM_SYNC_VERSION#v}"

set -x
cp manifests/Chart.yaml "${CHART_DIR}"/Chart.yaml

# set the app version in Chart.yaml
sed -i -E "s/APP_VERSION_PLACEHOLDER/${UPSTREAM_SYNC_VERSION_STRIPPED}/" "${CHART_DIR}/Chart.yaml"

# reset the version in Chart.yaml
sed -i -E "s/CHART_VERSION_PLACEHOLDER/${CHART_VERSION}/" "${CHART_DIR}/Chart.yaml"
{ set +x; } 2>/dev/null

_helper_log_patch_finished
