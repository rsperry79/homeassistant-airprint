#!/usr/bin/with-contenv bashio
# shellcheck disable=SC2154

function load_sources() {
    # shellcheck disable=SC1091
    # shellcheck source="./common/paths/common-paths.sh"
    source "/opt/common/paths/common-paths.sh"

    # shellcheck disable=SC1091
    # shellcheck source="./cups/helpers/cups-host-helpers.sh"
    source "/opt/cups/helpers/cups-host-helpers.sh"

    # shellcheck disable=SC1091
    # shellcheck source="./common/network-common.sh"
    source "/opt/common/network-common.sh"

    # shellcheck disable=SC1091
    # shellcheck source="./common/ha-helpers.sh"
    source "/opt/common/ha-helpers.sh"

    # shellcheck disable=SC1091
    # shellcheck source="./cups/helpers/cups-ssl-helpers.sh"
    source "/opt/cups/helpers/cups-ssl-helpers.sh"

    # shellcheck disable=SC1091
    # shellcheck source="./cups/helpers/cups-config-helpers.sh"
    source "/opt/cups/helpers/cups-config-helpers.sh"
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
    add_host_name_to_hosts_file "$internal"
    update_server_name "$internal"
}

function run_custom_script() {
    if bashio::config.has_value 'CUSTOM_PACKAGES.RUN_CUSTOM_INST_SCRIPT'; then
        if [ "$(bashio::config 'CUSTOM_PACKAGES.RUN_CUSTOM_INST_SCRIPT')" = true ]; then
            until [ -e /run/cups/cups.sock ]; do
                bashio::log.info "Waiting for cups daemon before installing custom script"
                sleep 10s
            done

            bashio "$packages_path/$install_script"
        fi
    fi
}

load_sources      # loads needed scripts
run               # run entrypoint
tail -f /dev/null # Keep Running
