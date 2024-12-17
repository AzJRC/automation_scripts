#!/bin/bash


# Source the .env file
if [ -f "$(dirname "$0")/.env" ]; then
	set -o allexport
	source "$(dirname "$0")/.env"
	set +o allexport
fi

# Hardcoded variables
CURR_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

# Get DigitalOcean record
RECORD=$(curl -s -X GET \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $API_TOKEN" \
	"https://api.digitalocean.com/v2/domains/$DOMAIN/records/$RECORD_ID")

# Get DNS the record's IP field with DigitalOcean API
DO_IP=$(echo "$RECORD" | jq -r .[].data) 
if [[ -z "$RECORD" || -z "$DO_IP" ]]; then
	echo "$CURR_TIME - Failed to retrieve DO IP address in DNS record." >> "$LOG_FILE"
	exit 1
fi

# Get current public IP using Ipify
CURRENT_IP=$(curl -s https://api.ipify.org)
if [[ -z "$CURRENT_IP" ]]; then
	echo "$CURR_TIME - Failed to retrieve public IP address." >> "$LOG_FILE" 
	exit 1
fi

# Compare DigitalOcean's DNS record IP field with the current public IP
if [[ "$CURRENT_IP" == "$DO_IP" ]]; then
	echo "$CURR_TIME - IP addresses match. No update needed." >> "$LOG_FILE"
	exit 0
fi

# Update DigitalOcean's DNS record IP field with current public IP
UPDATE_RESPONSE=$(curl -s -X PUT \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $API_TOKEN" \
	-d "{\"data\":\"$CURRENT_IP\"}" \
	"https://api.digitalocean.com/v2/domains/$DOMAIN/records/$RECORD_ID")

if echo "$UPDATE_RESPONSE" | jq -e '.domain_record.id' > /dev/null; then
	echo "$CURR_TIME - DNS record updated successfully to $CURRENT_IP." >> "$LOG_FILE"
    else
	echo "$CURR_TIME - Failed to update DNS record. Response: $UPDATE_RESPONSE" >> "$LOG_FILE"
	exit 1
fi
