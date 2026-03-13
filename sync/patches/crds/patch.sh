#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly SCRIPT_DIR
source "${SCRIPT_DIR}"/../../_helpers.sh

_helper_log_patch_started

cd "${SCRIPT_DIR}"

set -x
mkdir "${CRD_CHART_DIR}"/templates -p || true
cp -r "${SCRIPT_DIR}"/manifests/* "${CRD_CHART_DIR}"
mv "${SCRIPT_DIR}"/output/* "${CRD_CHART_DIR}"/templates/
{ set +x; } 2>/dev/null

# update the crd Chart.yaml if the CRDs have changed
CRDS_CHANGED=0

# add annotation to ensure helm doesn't delete CRDs
for crd in "${CRD_CHART_DIR}"/templates/*; do
    # this command ensures that the annotations field exists and then adds the helm annotation. it does not remove any existing annotations.
    yq eval '.metadata.annotations = (.metadata.annotations // {} ) | .metadata.annotations += {"helm.sh/resource-policy": "keep"}' -i "${crd}"
done

# check for updated CRDs
if ! git diff --quiet HEAD -- "${CRD_CHART_DIR}"/templates/; then
    CRDS_CHANGED=1
fi

# check for new CRDs
if git ls-files --others --exclude-standard -- "${CRD_CHART_DIR}"/templates/ | grep -q .; then
    CRDS_CHANGED=1
fi

if [[ $CRDS_CHANGED -eq 1 ]]; then
    echo -e "\nCRDs have changed, updating CRD chart version\n"
    # CRDs have changed in this release, set the CRD chart version to match the upstream version we're syncing against
    # get the upstream sync version from vendir.yml
    UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].githubRelease.tag ${REPO_DIR}/vendir.yml)
    # strip leading 'v' if present
    CRD_CHART_VERSION="${UPSTREAM_SYNC_VERSION#v}"
else
    # no change to CRDs, ensure the CRD chart version is not bumped by setting it to the current published version
    CRD_CHART_VERSION=$(curl --silent https://raw.githubusercontent.com/giantswarm/cluster-api-provider-proxmox-app/refs/heads/main/helm/cluster-api-provider-proxmox/charts/cluster-api-provider-proxmox-crds/Chart.yaml | yq .version -r)
fi

set -x
# update the crd chart version
sed -i -E "s/^(version: ).*/version: ${CRD_CHART_VERSION}/" "${CRD_CHART_DIR}/Chart.yaml"

# replace the placeholder in the main chart's dependencies
sed -i -E "s/CRD_VERSION_PLACEHOLDER/${CRD_CHART_VERSION}/" "${CHART_DIR}/Chart.yaml"
{ set +x; } 2>/dev/null

_helper_log_patch_finished
