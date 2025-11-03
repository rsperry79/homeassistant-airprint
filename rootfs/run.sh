#!/usr/bin/with-contenv bashio

ulimit -n 1048576
readonly real_cups_path=/config/cups
readonly cups_daemon_cfg=cupsd.conf

function run() {
    bashio::log info "Entered Run.sh"
    update_cups
}

# The HA API is not available from S6
function update_cups() {
    # Get all possible host-names from configuration
    result=$(bashio::api.supervisor GET /core/api/config true || true)
    internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)

    if grep "$internal" "$real_cups_path/$cups_daemon_cfg"; then
        sed -i "s/^.*ServerAlias\a\  ${internal}" "$real_cups_path/$cups_daemon_cfg" # update config
        s6-svc -r /etc/s6-overlay/s6-rc.d/cups-server                                # restart the service
    fi
}

run
# Keep Running
tail -f /dev/null
