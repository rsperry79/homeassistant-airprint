#!/usr/bin/with-contenv bashio
# shellcheck source="./common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck source="./cups/cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

# shellcheck source="./common/network-common.sh"
source "/opt/common/network-common.sh"

# shellcheck source="./common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

# shellcheck source="./cups/cups-ssl-helpers.sh"
source "/opt/cups/cups-ssl-helpers.sh"

ulimit -n 1048576

function run() {
    bashio::log info "Entered Entry.sh"

    update_cups_conf
    run_custom_script
}

# The HA API is not available from S6
function update_cups_conf() {
    # Get internal hostname from config
    result=$(bashio::api.supervisor GET /core/api/config true || true)
    internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)

    # update files
    add_host_name_to_hosts "$internal"
    append_existing_host_alias "$internal"
}

function run_custom_script() {

    until [ -e /run/cups/cups.sock ]; do
        bashio::log.info "Waiting for cups daemon before installin custom script"
        sleep 2s
    done

    bashio "$packages_path/$install_script"
}

run               # run entrypoint
tail -f /dev/null # Keep Running
