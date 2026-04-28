#!/usr/bin/env bash

set -euo pipefail

action="${1:-}"

case "$action" in
  upload)
    tmp_file=$(mktemp)
    trap 'rm -f "$tmp_file"' EXIT

    printf '%s' "$BLOB_CONTENT" > "$tmp_file"

    az storage blob upload \
      --only-show-errors \
      --overwrite true \
      --auth-mode login \
      --account-name "$STORAGE_ACCOUNT_NAME" \
      --container-name "$STORAGE_CONTAINER_NAME" \
      --name "$BLOB_NAME" \
      --content-type "application/json" \
      --type block \
      --file "$tmp_file" \
      --metadata "producer=$PRODUCER_NAME" \
      --subscription "$SUBSCRIPTION_ID"
    ;;
  delete)
    blob_exists=$(az storage blob exists \
      --auth-mode login \
      --account-name "$STORAGE_ACCOUNT_NAME" \
      --container-name "$STORAGE_CONTAINER_NAME" \
      --name "$BLOB_NAME" \
      --query exists \
      --subscription "$SUBSCRIPTION_ID" \
      -o tsv)

    if [ "$blob_exists" = "true" ]; then
      az storage blob delete \
        --only-show-errors \
        --auth-mode login \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --container-name "$STORAGE_CONTAINER_NAME" \
        --subscription "$SUBSCRIPTION_ID" \
        --name "$BLOB_NAME"
    fi
    ;;
  *)
    echo "Usage: $0 <upload|delete>" >&2
    exit 1
    ;;
esac