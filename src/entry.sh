#!/usr/bin/with-contenv bashio

function load_sources() {
    # shellcheck source="./common/settings.sh"
    source "/opt/common/settings.sh"

    # shellcheck source="./cups/cups-host-helpers.sh"
    source "/opt/cups/cups-host-helpers.sh"

    # shellcheck source="./common/network-common.sh"
    source "/opt/common/network-common.sh"

    # shellcheck source="./common/ha-helpers.sh"
    source "/opt/common/ha-helpers.sh"

    # shellcheck source="./cups/cups-ssl-helpers.sh"
    source "/opt/cups/cups-ssl-helpers.sh"

    # shellcheck source="./cups/cups-config-helpers.sh"
    source "/opt/cups/cups-config-helpers.sh"
}

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
    if [ "$(bashio::config 'custom_packages.run_script')" = true ]; then
        until [ -e /run/cups/cups.sock ]; do
            bashio::log.info "Waiting for cups daemon before installing custom script"
            sleep 10s
        done

        bashio "$packages_path/$install_script"
    fi
}

load_sources      # loads needed scripts
run               # run entrypoint
tail -f /dev/null # Keep Running
