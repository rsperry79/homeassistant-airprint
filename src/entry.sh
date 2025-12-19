#!/usr/bin/with-contenv bashio

function load_sources() {
    # shellcheck source="./common/paths/common-paths.sh"
    source "/opt/common/paths/common-paths.sh"

    # shellcheck source="./cups/helpers/cups-host-helpers.sh"
    source "/opt/cups/helpers/cups-host-helpers.sh"

    # shellcheck source="./common/network-common.sh"
    source "/opt/common/network-common.sh"

    # shellcheck source="./common/ha-helpers.sh"
    source "/opt/common/ha-helpers.sh"

    # shellcheck source="./cups/helpers/cups-ssl-helpers.sh"
    source "/opt/cups/helpers/cups-ssl-helpers.sh"

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
    add_host_name_to_hosts "$internal"
    append_existing_host_alias "$internal"
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
