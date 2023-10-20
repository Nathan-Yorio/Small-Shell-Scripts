#!/bin/bash

########################################################
# Functions, init
########################################################

# Set your Cloudflare API credential
EMAIL=$CLOUDFLARE_EMAIL
TOKEN=$CLOUDFLARE_API_TOKEN

if [ $# -lt 1 ]; then
    echo "Usage: $0 <number_of_pages_of_results_to_retrieve>"
    exit 1
fi

# Initialize variables for pagination and status
page=1
zones_data=""
total_pages=$1

# Function to print a simple status bar
print_status_bar() {
  percent=$((page * 50 / total_pages))
  echo -ne "\033[33mProgress: [" 
  for ((i = 0; i < percent; i++)); do
    echo -n "#"
  done
  for ((i = percent; i < 50; i++)); do
    echo -n "-"
  done
  echo -ne "] $page/$total_pages Pages ($percent%)\033[0m\r"  # \r Reset to beginning for clean bar
}

# Function to retrieve regular site and zone settings for a specific zone
get_zone_settings() {
  local zone_id="$1"
  local settings


  settings=$(curl -s --request GET "https://api.cloudflare.com/client/v4/zones/$zone_id/settings" \
    --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    --header "Content-Type: application/json")

  echo "$settings"
}

# Function to retrieve WAF rules for a specific zone
get_waf_rules() {
  local zone_id="$1"
  local waf_rules

  waf_rules=$(curl -s --request GET "https://api.cloudflare.com/client/v4/zones/$zone_id/firewall/waf/packages" \
    --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    --header "Content-Type: application/json")

  echo "$waf_rules"
}

# Gets the actual rules out of the rulesets, by ID
get_zone_entrypoint_rules() {
  local zone_id="$1"
  local ruleset_phase="$2"
  local rulesets

  rulesets=$(curl -s --request GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets/phases/$ruleset_phase/entrypoint" \
    --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    --header "Content-Type: application/json")

  echo "$rulesets"
}

# Make API requests to get all pages of zones
while ((page <= total_pages)); do
  response=$(curl -s --request GET "https://api.cloudflare.com/client/v4/zones?page=$page" \
    --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    --header "Content-Type: application/json")

  # Append the current page's data to the zones_data variable
  zones_data="${zones_data}$(jq -r '.result[] | "\(.id)\t\(.name)"' <<< "$response")"$'\n'

  print_status_bar
  ((page++))
done

########################################################
# Data Dump to Txt
########################################################

# Clear the status bar line
echo -e "\n"

# Print the zone IDs and site names in a table
echo -e "Zone ID\tSite Name" >> zones_data.txt
echo -e "$zones_data" >> zones_data.txt

echo "Site Settings For each zone" >> site_settings.txt
while read -r line; do
  zone_id=$(cut -f 1 <<< "$line")
  zone_name=$(cut -f 2 <<< "$line")

  echo "Settings for: $zone_name ($zone_id)" >> site_settings.txt
  zone_settings_data=$(get_zone_settings "$zone_id")
  echo "$zone_settings_data" | jq . >> site_settings.txt
  echo "" >> site_settings.txt
done <<< "$zones_data"

echo "WAF Rules For each zone" >> waf_rules.txt
while read -r line; do
  zone_id=$(cut -f 1 <<< "$line")
  zone_name=$(cut -f 2 <<< "$line")

  echo -e "WAF Rules for: $zone_name \($zone_id\)" >> waf_rules.txt
  waf_rules_data=$(get_waf_rules "$zone_id")
  echo "$waf_rules_data" | jq . >> waf_rules.txt
  echo "" >> waf_rules.txt
done <<< "$zones_data"


echo "WAF Rulesets for each WAF Rule" >> waf_rulesets.txt
echo "jq is going to print an error for empty rulesets, null iterate, no worries"
while read -r line; do
  zone_id=$(cut -f 1 <<< "$line")
  zone_name=$(cut -f 2 <<< "$line")

  waf_rules_data=$(get_waf_rules "$zone_id")
  waf_rules_names=$(echo "$waf_rules_data" | jq -r '.result[].name')
  waf_rules_ids=$(echo "$waf_rules_data" | jq -r '.result[].id')

  # Only echo this ruleset information if it is nonempty to avoid trashing up the output
  if [ -n "$waf_rules_names" ] || [ -n "$waf_rules_ids" ]; then
    echo "WAF Rulesets for: " >> waf_rulesets.txt
    echo "Zone_ID: $zone_id:" >> waf_rulesets.txt
    echo "Zone_Name: $zone_name:" >> waf_rulesets.txt
    if [ -n "$waf_rules_names" ]; then
      echo "Names: " >> waf_rulesets.txt
      echo "$waf_rules_names" >> waf_rulesets.txt
    fi
    if [ -n "$waf_rules_ids" ]; then
      echo "Ids: " >> waf_rulesets.txt
      echo "$waf_rules_ids" >> waf_rulesets.txt
    fi
  fi

  # Print the Actual Rules in the Ruleset for each Rule_ID
  for rule_id in $waf_rules_ids; do
    echo "Rulesets for WAF Rule ($rule_id):" >> waf_rulesets.txt
    rulesets_data=$(get_zone_entrypoint_rules "$zone_id" "http_request_firewall_custom" )
    echo "$rulesets_data" | jq . >> waf_rulesets.txt
    echo "" >> waf_rulesets.txt
  done
done <<< "$zones_data"
