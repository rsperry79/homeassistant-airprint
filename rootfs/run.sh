#!/usr/bin/with-contenv bashio

# shellcheck source="./opt/cups/cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

# shellcheck source="./opt/common/network-common.sh"
source "/opt/common/network-common.sh"

# shellcheck source="./opt/common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

ulimit -n 1048576

function run() {
    bashio::log info "Entered Run.sh"
    update_cups_conf
    update_ha_config
}

# The HA API is not available from S6
function update_cups_conf() {
    # Get all possible host-names from configuration
    result=$(bashio::api.supervisor GET /core/api/config true || true)
    internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)
    append_existing_hostname "$internal"
    add_host_name_to_hosts "$internal"

    # bashio::log.info "Restarting CUPS after adding HA Internal domain"
    #s6-svc -r /var/run/s6/services/cups-server # restart the service
}

function update_ha_config() {
    update_interfaces
}

run               # run entrypoint
tail -f /dev/null # Keep Running
