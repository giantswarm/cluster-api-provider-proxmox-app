#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

_helper_log_patch_started

cd "${REPO_DIR}"

set -x
cp "${SCRIPT_DIR_REL}"/manifests/* "${CHART_DIR}/templates/"
{ set +x; } 2>/dev/null

_helper_log_patch_finished
