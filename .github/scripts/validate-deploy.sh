#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

source "${SCRIPT_DIR}/validation-functions.sh"

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  exit 1
fi

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

if ! command -v ibmcloud 1> /dev/null 2> /dev/null; then
  echo "ibmcloud cli not found" >&2
  exit 1
fi

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(jq -r '.namespace // "default"' gitops-output.json)
MAS_INSTANCE_ID=$(jq -r '.mas_instance_id // "inst1"' gitops-output.json)
CORE_NAMESPACE=$(jq --arg INST_ID "${MAS_INSTANCE_ID}" -r '.core_namespace // "mas-${INST_ID}-core"' gitops-output.json)
COMPONENT_NAME=$(jq -r '.name // "my-module"' gitops-output.json)
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)

mkdir -p .testrepo

echo "*** Cloning git repo ${GIT_REPO}"
git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

set -e

validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "operators" "masauto-operator" "Chart.yaml"
validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "operators" "masauto-operator" "values.yaml"

validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "Chart.yaml"
validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "values.yaml"
validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "templates/secret-ibm-entitlement-key.yaml"

check_k8s_namespace "${NAMESPACE}"

check_k8s_resource "${NAMESPACE}" subscription masauto-operator || exit 1
check_k8s_resource "${NAMESPACE}" deployment masauto-operator-controller-manager || exit 1

check_k8s_resource "${NAMESPACE}" secret ibm-entitlement-key || exit 1

check_k8s_resource ibm-common-services deployment cert-manager-controller || exit 1

check_k8s_resource ibm-sls deployment sls-api-licensing || exit 1

check_k8s_resource ibm-common-services deployment user-data-services-operator || exit 1
check_k8s_resource ibm-common-services analyticsproxy analyticsproxy || exit 1

check_k8s_resource ibm-common-services deployment kafka-entity-operator || exit 1

check_k8s_resource ibm-common-services deployments event-api-deployment || exit 1

check_k8s_resource "${NAMESPACE}" secret sls-bootstrap || exit 1
check_k8s_resource "${NAMESPACE}" job license-job || exit 1

check_k8s_namespace "${CORE_NAMESPACE}" || exit 1
check_k8s_resource "${CORE_NAMESPACE}" suite "${MAS_INSTANCE_ID}" || exit 1

count=0
while [[ count -lt 40 ]]; do
  RESULT=$(kubectl get -n "${CORE_NAMESPACE}" suite "${MAS_INSTANCE_ID}" -o json)

  CONDITION=$(echo "${RESULT}" | jq -c '.status.conditions[] | select(.type == "SLSIntegrationReady")')

  SLS_INTEGRATION_REASON=$(echo "${CONDITION}" | jq -r '.reason')
  echo "SLS Integration reason: ${SLS_INTEGRATION_REASON}"
  if [[ "${SLS_INTEGRATION_REASON}" == "MissingLicenseFile" ]]; then
    echo "Waiting for license to be applied"
  elif [[ "${SLS_INTEGRATION_REASON}" == "Ready" ]]; then
    echo "MAS Core instance is ready"
    break
  fi

  echo "**** Suite result ****"
  echo "${RESULT}"

  count=$((count + 1))
  sleep 90
done

cd ..
rm -rf .testrepo
