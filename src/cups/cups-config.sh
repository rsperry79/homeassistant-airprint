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
    HOST_ALIAS="*"
    self_sign=false
    setup

    # if [ ! -e "$real_cups_path/$cups_browsed" ]; then
    #     autoconf_browsed
    # else
    #     update_browsed
    # fi

    if [ ! -e "$real_cups_path/$cups_client" ]; then
        autoconf_client
    else
        update_client
    fi

    if [ ! -e "$real_cups_path/$cups_daemon" ]; then
        autoconf_daemon
    else
        update_daemon
    fi

    if [ ! -e "$real_cups_path/$cups_files" ]; then
        autoconf_files
    else
        update_files
    fi

    if [ ! -e "$real_cups_path/$cups_pdf" ]; then
        autoconf_pdf
    else
        update_pdf
    fi

    if [ ! -e "$real_cups_path/$cups_snmp" ]; then
        autoconf_snmp
    else
        update_snmp
    fi

    #add_host_name_to_hosts "$host_name"

}

# Gets current settings from HA
function setup() {
    bashio::log.info "setup cups configs:"
    cups_log_level=$(bashio::config 'cups_logging.cups_log_level')
    cups_access_log_level=$(bashio::config 'cups_logging.cups_access_log_level')
    cups_encryption=$(bashio::config 'cups_ssl.cups_encryption')

    cups_self_sign=no
    if bashio::config.has_value 'cups_ssl.cups_self_sign'; then
        self_sign=$(bashio::config 'cups_ssl.cups_self_sign')
        if [ "$self_sign" == true ]; then
            cups_self_sign=yes
        fi
    fi

    setup_ssl "$cups_encryption" "$self_sign"

    # Used by autoconf
    config=$(jq --arg host_name "$HOSTNAME" --arg cups_ssl_path "$cups_ssl_path" --arg cups_log_level "$cups_log_level" \
        --arg cups_access_log_level "$cups_access_log_level" --arg host_alias "$HOST_ALIAS" --arg self_sign "$cups_self_sign" --arg cups_encryption "$cups_encryption" \
        '{ host_name: $host_name, cups_ssl_path: $cups_ssl_path,  host_alias: $host_alias , cups_log_level: $cups_log_level, cups_access_log_level: $cups_access_log_level, self_sign: $self_sign,  cups_encryption: $cups_encryption }' \
        /data/options.json)

    bashio::log.info "setup autoconf:"
    bashio::log.info "$config"
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
