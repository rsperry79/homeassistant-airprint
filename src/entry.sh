#!/usr/bin/with-contenv bashio

# shellcheck source="./common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck source="./cups/cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

# shellcheck source="./common/network-common.sh"
source "/opt/common/network-common.sh"

# shellcheck source="./common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

# shellcheck source="./common/packages.sh"
source "/opt/common/packages.sh"

# shellcheck source="./cups/cups-ssl-helpers.sh"
source "/opt/cups/cups-ssl-helpers.sh"

# shellcheck source="./cups/cups-config-helpers.sh"
source "/opt/cups/cups-config-helpers.sh"

function run() {
    bashio::log info "Entered Entry.sh"
    #check_install
    self_sign
    update_cups_conf

    install_config_packages

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
        bashio::log.info "Waiting for cups daemon before installing custom script"
        sleep 10s
    done

    bashio "$packages_path/$install_script"
}

function self_sign() {
    if bashio::config.has_value cups_self_sign; then
        self_sign=$(bashio::config 'cups_self_sign')
        bashio::log.debug "Self sign has value: $self_sign"
        if [ "$self_sign" == true ]; then
            cups_self_sign=yes
        else
            cups_self_sign=no
        fi

        update_self_sign "$cups_self_sign"
    fi

}

function check_install() {
    if command -v cupsd &>/dev/null; then
        bashio::log.debug "Cupsd is installed"
    else
        bashio::log.debug "Installing Cups Libs"
        find /build -type f -name "cups-libs-$CUPS_VER-linux-**.deb" -exec bash -c 'for pkg; do dpkg -i --force-confold --force-confdef "$pkg" ; done' _ {} +

        bashio::log.debug "Installing Cups"
        find /build -type f -name "cups-$CUPS_VER-linux-**.deb" -exec bash -c 'for pkg; do dpkg -i --force-confold --force-confdef "$pkg"; done' _ {} +

        bashio::log.debug "Installing lib cups filters"

    fi
}

run               # run entrypoint
tail -f /dev/null # Keep Running
