#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

_helper_log_patch_started

cd "${SCRIPT_DIR}"

rm -rf "${SCRIPT_DIR}"/tmp/
mkdir -p "${SCRIPT_DIR}"/tmp/{input,output}

cp "${VENDIR_SYNC_DIR}"/infrastructure-components.yaml "${SCRIPT_DIR}"/tmp/input/

kustomize build "${SCRIPT_DIR}" -o "${SCRIPT_DIR}"/tmp/output/

# process deployment file to remove bash variable substitutions
DEPLOYMENT_FILE=$(find "${SCRIPT_DIR}"/tmp/output/ -iname \*deployment\*)

if [ -z "${DEPLOYMENT_FILE}" ]; then
    echo "Could not find deployment file in the kustomize output."
    exit 1
fi

sed -i -E 's/\$\{[^:]+:=([^}]+)\}/\1/g' "${DEPLOYMENT_FILE}"
# finished processing deployment file

# process CiliumNetworkPolicy to wrap it in a conditional check
CNP_FILE=$(find "${SCRIPT_DIR}"/tmp/output/ -iname \*ciliumnetworkpolicy\*)
sed -i '1 i\{{- if .Values.ciliumNetworkPolicy.enabled }}' "${CNP_FILE}"
sed -i '$ a {{- end }}' "${CNP_FILE}"

# move CRD files to the crds/manifests directory for processing separately
set -x
mkdir -p "${SCRIPT_DIR}"/../crds/output || true
find "${SCRIPT_DIR}"/tmp/output/ -iname \*apiextensions\* -exec mv {} "${SCRIPT_DIR}"/../crds/output/ \;

cp "${SCRIPT_DIR}"/tmp/output/*.yaml "${CHART_DIR}"/templates/

rm -rf "${SCRIPT_DIR}"/tmp/
{ set +x; } 2>/dev/null

_helper_log_patch_finished
