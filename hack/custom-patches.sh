#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

YQ="./bin/yq"

f="config/kustomize/tmp/apps_v1_deployment_capmox-controller-manager.yaml"

${YQ} e '.spec.template.spec.securityContext={} | .spec.template.spec.containers[].securityContext={}' ${f} > ${f}.tmp
mv ${f}.tmp ${f}

${YQ} e '.spec.template.spec.securityContext.remove-this-key="'"
{{- with .Values.podSecurityContext }}
  {{- . | toYaml | nindent 8 }}
{{- end }}
"'" | .spec.template.spec.containers[].securityContext.remove-this-key="'"
{{- with .Values.containerSecurityContext }}
	{{- . | toYaml | nindent 12 }}
{{- end }}
"'"' ${f} > ${f}.tmp
cat ${f}.tmp | grep -v 'remove-this-key' > ${f}
rm -rf ${f}.tmp
