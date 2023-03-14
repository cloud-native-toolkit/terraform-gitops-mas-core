#!/usr/bin/env bash

SECRET_NAME="$1"
NAMESPACE="$2"
HOST_ID="$3"
DEST_DIR="$4"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${LICENSE_KEY}" ]]; then
  echo "The LICENSE_KEY must be provided in an environment variable" >&2
  exit 1
fi

mkdir -p "${DEST_DIR}"

echo "Writing yaml for secret ${SECRET_NAME} in namespace ${NAMESPACE} to secret-${SECRET_NAME}.yaml"
kubectl create secret generic "${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --from-literal="licensingId=${HOST_ID}" \
  --from-literal="licensingKey=${LICENSE_KEY}" \
  --dry-run=client \
  --output yaml > "${DEST_DIR}/secret-${SECRET_NAME}.yaml"
