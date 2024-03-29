#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "$0")" || exit 1; pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.." || exit 1; pwd -P)

NAME="$1"
DEST_DIR="$2"

mkdir -p "${DEST_DIR}"

cp -R "${MODULE_DIR}/chart/${NAME}/"* "${DEST_DIR}"

if [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"
fi
