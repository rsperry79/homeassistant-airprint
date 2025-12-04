#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck source="./cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

# shellcheck source="./cups-ssl-helpers.sh"
source "/opt/cups/cups-ssl-helpers.sh"

# shellcheck source="./cups-config-helpers.sh"
source "/opt/cups/cups-config-helpers.sh"

function run() {

    cups_log_level="error"
    cups_encryption="IfRequested"
    cups_access_log_level="config"
    HOST_ALIAS="localhost"
    self_sign=false
    setup

    # if [ ! -e "$real_cups_path/$cups_browsed" ]; then
    #     autoconf_browsed
    # else
    #     update_browsed
    # fi

    cups_encryption=$(bashio::config 'cups_ssl.cups_encryption')
    if [ ! -e "$real_cups_path/$cups_client" ] && [ "$cups_encryption" != "Never" ]; then
        autoconf_client
    else
        update_client
    fi

    bashio::log.info "exit cups config client"

    if [ ! -e "$real_cups_path/$cups_daemon" ]; then
        autoconf_daemon
    else
        update_daemon
    fi
    bashio::log.info "exit cups config daemon"

    if [ ! -e "$real_cups_path/$cups_files" ]; then
        autoconf_files
    else
        update_files
    fi
    bashio::log.info "exit cups config FILES"

    if [ ! -e "$real_cups_path/$cups_pdf" ]; then
        autoconf_pdf
    else
        update_pdf
    fi
    bashio::log.info "exit cups config pdf"

    if [ ! -e "$real_cups_path/$cups_snmp" ]; then
        autoconf_snmp
    else
        update_snmp
    fi
    bashio::log.info "exit cups config snmp"

    setup_ssl "$cups_encryption" "$self_sign"
    bashio::log.info "exit cups config ssl"
    #add_host_name_to_hosts "$host_name"

}

# Gets current settings from HA
function setup() {
    bashio::log.info "setup cups configs:"

    cups_log_location=$(bashio::config 'cups_logging.cups_log_location')
    if [ "$cups_log_location" = "log_tab" ]; then
        cups_log_location=stderr
    fi

    cups_log_level=$(bashio::config 'cups_logging.cups_log_level')
    cups_access_log_location=$(bashio::config 'cups_logging.cups_access_log_location')
    if [ "$cups_access_log_location" = "log_tab" ]; then
        cups_access_log_location=stderr
    else
        cups_access_log_location=$cups_log_path/cups.log
    fi

    cups_access_log_level=$(bashio::config 'cups_logging.cups_access_log_level')
    cups_encryption=$(bashio::config 'cups_ssl.cups_encryption')
    cups_access_log_level=$(bashio::config 'cups_logging.cups_access_log_level')
    cups_self_sign=No
    if [ "$cups_encryption" != "Never" ]; then
        if bashio::config.has_value 'cups_ssl.cups_self_sign'; then
            self_sign=$(bashio::config 'cups_ssl.cups_self_sign')
            if [ "$self_sign" == true ]; then
                cups_self_sign=Yes
            fi
        fi
    fi

    # Used by autoconf
    config=$(
        jq --arg host_name "$HOSTNAME" --arg host_alias "$HOST_ALIAS" \
            --arg cups_ssl_path "$cups_ssl_path" --arg self_sign "$cups_self_sign" --arg cups_encryption "$cups_encryption" \
            --arg cups_log_level "$cups_log_level" --arg cups_access_log_level "$cups_access_log_level" --arg cups_log_location "$cups_log_location" --arg cups_access_log_location "$cups_access_log_location" \
            '{ host_name: $host_name, cups_ssl_path: $cups_ssl_path,  host_alias: $host_alias , cups_log_level: $cups_log_level, cups_access_log_level: $cups_access_log_level, self_sign: $self_sign,  cups_encryption: $cups_encryption, cups_log_location: $cups_log_location, cups_access_log_location: $cups_access_log_location  }' \
            /data/options.json
    )

    bashio::log.info "exit cups config setup"
}

function autoconf_client() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_client_cfg" \
        -out "$real_cups_path/$cups_client"

}

function update_client() {
    true
    # local h_name=${1}
    # update_server_name "$h_name"
}

function autoconf_daemon() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_daemon_cfg" \
        -out "$real_cups_path/$cups_daemon"
}

function autoconf_browsed() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_browsed_cfg" \
        -out "$real_cups_path/$cups_browsed"
}

function update_browsed() {
    true
}

function update_daemon() {
    update_log_level "$cups_log_level"
    update_server_alias "$HOST_ALIAS"
    update_server_name "$HOSTNAME"
}

function autoconf_files() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_files_cfg" \
        -out "$real_cups_path/$cups_files"
}

function update_files() {
    update_access_log_level "$cups_access_log_level"
    bashio::log.info "exit cups update_files access level"
    update_access_log_location "$cups_access_log_location"
    bashio::log.info "exit cups update_files access location"
    update_log_location "$cups_log_location"
    bashio::log.info "exit cups update_files error location"
    update_self_sign "$self_sign"
}

function autoconf_pdf() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_pdf_cfg" \
        -out "$real_cups_path/$cups_pdf"

}

function update_pdf() {
    true
}

function autoconf_snmp() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_snmp_cfg" \
        -out "$real_cups_path/$cups_snmp"

}

function update_snmp() {
    true
}

run
