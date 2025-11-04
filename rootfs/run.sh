#!/usr/bin/with-contenv bashio

ulimit -n 1048576
readonly real_cups_path=/config/cups
readonly cups_daemon_cfg=cupsd.conf

function run() {
    bashio::log info "Entered Run.sh"
    update_cups_conf
}

# The HA API is not available from S6
function update_cups_conf() {
    # Get all possible host-names from configuration
    result=$(bashio::api.supervisor GET /core/api/config true || true)
    internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)
    bashio::log.info "HA Int: $internal"

    if ! grep -q "$internal" "$real_cups_path/$cups_daemon_cfg"; then
        sed -i "/^.*ServerAlias/s/$/  ${internal}/" "$real_cups_path/$cups_daemon_cfg" # update config
        bashio::log.info "Restarting CUPS after adding HA Internal domain"
        s6-svc -r /etc/s6-overlay/s6-rc.d/cups-server # restart the service
    fi
}

run               # run entrypoint
tail -f /dev/null # Keep Running
