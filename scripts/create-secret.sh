#!/usr/bin/env bash

SECRET_NAME="$1"
NAMESPACE="$2"
USERNAME="$3"
DEST_DIR="$4"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${PASSWORD}" ]]; then
  echo "The PASSWORD must be provided in an environment variable" >&2
  exit 1
fi

mkdir -p "${DEST_DIR}"

echo "Writing yaml for secret ${SECRET_NAME} in namespace ${NAMESPACE} to secret-${SECRET_NAME}.yaml"
kubectl create secret generic "${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --from-literal="username=${USERNAME}" \
  --from-literal="password=${PASSWORD}" \
  --dry-run=client \
  --output yaml > "${DEST_DIR}/secret-${SECRET_NAME}.yaml"
