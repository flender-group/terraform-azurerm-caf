#!/bin/bash
set -euo pipefail

# Script to manage Azure Advisor Recommendation Digest configuration
# Usage: advisor_config.sh <create|update|delete> <api_url> [payload_json]

ACTION="${1:-}"
API_URL="${2:-}"
PAYLOAD="${3:-}"
MAX_RETRIES=3
RETRY_DELAY=5

if [ -z "$ACTION" ] || [ -z "$API_URL" ]; then
  echo "Usage: $0 <create|update|delete> <api_url> [payload_json]"
  exit 1
fi

case "$ACTION" in
  create|update)
    if [ -z "$PAYLOAD" ]; then
      echo "ERROR: Payload JSON required for create/update"
      exit 1
    fi
    
    echo "Creating/Updating Advisor Recommendation Digest configuration..."
    
    # PUT request to create/update configuration using az rest with retry logic
    for attempt in $(seq 1 $MAX_RETRIES); do
      echo "Attempt $attempt of $MAX_RETRIES..."
      
      RESPONSE=$(az rest --method PUT \
        --url "$API_URL" \
        --headers "Content-Type=application/json" \
        --body "$PAYLOAD" \
        --output json 2>&1) && {
        echo "Advisor configuration successfully ${ACTION}d"
        echo "Response:"
        echo "$RESPONSE" | jq -C . 2>/dev/null || echo "$RESPONSE"
        exit 0
      } || EXIT_CODE=$?
      
      echo "Attempt $attempt failed"
      echo "Response: $RESPONSE"
      
      if [ $attempt -lt $MAX_RETRIES ]; then
        echo "⏳ Waiting ${RETRY_DELAY}s before retry..."
        sleep $RETRY_DELAY
      fi
    done
    
    echo "Failed to ${ACTION} Advisor configuration after $MAX_RETRIES attempts"
    exit 1
    ;;
    
  delete)
    echo "Deleting Advisor Recommendation Digest configuration..."
    
    # Modify the payload to set state='Disabled' (API only supports PUT)
    DISABLED_PAYLOAD=$(echo "$PAYLOAD" | jq '.properties.digests[].state = "Disabled"')
    
    # PUT request to disable configuration (API doesn't support DELETE) with retry logic
    for attempt in $(seq 1 $MAX_RETRIES); do
      echo "Attempt $attempt of $MAX_RETRIES..."
      
      RESPONSE=$(az rest --method PUT \
        --url "$API_URL" \
        --headers "Content-Type=application/json" \
        --body "$DISABLED_PAYLOAD" \
        --output json 2>&1) && {
        echo "Advisor configuration successfully deleted (set to Disabled)"
        if [ -n "$RESPONSE" ] && [ "$RESPONSE" != "null" ]; then
          echo "Response:"
          echo "$RESPONSE" | jq -C . 2>/dev/null || echo "$RESPONSE"
        fi
        exit 0
      } || EXIT_CODE=$?
      
      # Check if 404 (resource doesn't exist)
      if echo "$RESPONSE" | grep -q "404\|NotFound\|ResourceNotFound"; then
        echo "Advisor configuration already deleted or does not exist"
        exit 0
      fi
      
      echo "Attempt $attempt failed"
      echo "Response: $RESPONSE"
      
      if [ $attempt -lt $MAX_RETRIES ]; then
        echo "Waiting ${RETRY_DELAY}s before retry..."
        sleep $RETRY_DELAY
      fi
    done
    
    echo "Failed to delete Advisor configuration after $MAX_RETRIES attempts (continuing anyway)"
    # Don't fail on destroy to allow Terraform to continue
    exit 0
    ;;
    
  *)
    echo "ERROR: Invalid action '$ACTION'. Must be create, update, or delete"
    exit 1
    ;;
esac