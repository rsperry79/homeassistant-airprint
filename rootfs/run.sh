#!/usr/bin/with-contenv bashio
# shellcheck source="./opt/common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck source="./opt/cups/cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

# shellcheck source="./opt/common/network-common.sh"
source "/opt/common/network-common.sh"

# shellcheck source="./opt/common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

# shellcheck source="./opt/cups/cups-ssl-helpers.sh"
source "/opt/cups/cups-ssl-helpers.sh"

ulimit -n 1048576

function run() {
    bashio::log info "Entered Run.sh"

    until [ -e /var/run/avahi-daemon/socket ]; do
        sleep 1s
    done

    update_cups_conf
    update_ha_config

    bashio::log.info "Starting CUPS from run.sh"
    start_cups
}

# The HA API is not available from S6
function update_cups_conf() {
    # Get internal hostname from config
    result=$(bashio::api.supervisor GET /core/api/config true || true)
    internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)

    # update files
    add_host_name_to_hosts "$internal"
    append_existing_host_alias "$internal"
    # update_cert_file_names "$internal"
}

function update_ha_config() {
    update_interfaces
}

# not a service as HA health check should restart on failure
function start_cups() {

    bashio::log.info "Testing CUPS server config"
    cupsd -t -c "$real_cups_path"/"$cups_daemon" f -s "$real_cups_path"/"$cups_files"

    bashio::log.info "Starting CUPS server from S6"
    cupsd -f -c "$real_cups_path"/"$cups_daemon" f -s "$real_cups_path"/"$cups_files"
}

run               # run entrypoint
tail -f /dev/null # Keep Running
