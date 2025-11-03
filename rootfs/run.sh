#!/usr/bin/with-contenv bashio

ulimit -n 1048576
readonly real_cups_path=/config/cups
readonly cups_daemon_cfg=cupsd.conf

function run() {
    update_cups
}

# The HA API is not available from S6
function update_cups() {
    # Get all possible host-names from configuration
    result=$(bashio::api.supervisor GET /core/api/config true || true)
    internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)
    external=$(bashio::jq "$result" '.external_url' | cut -d'/' -f3 | cut -d':' -f1)

    sed -i "s/^.*ServerAlias .*/ServerAlias ${internal}/" "$real_cups_path/$cups_daemon_cfg"
    sed -i "s/^.*ServerName .*/ServerName ${external}/" "$real_cups_path/$cups_daemon_cfg"
}

run
