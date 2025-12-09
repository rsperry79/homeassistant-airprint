#!/command/with-contend bashio
# shellcheck disable=SC2181
# shellcheck source="../common/paths/cups-paths.sh"
source "/opt/common/paths/cups-paths.sh"

# shellcheck source="./helpers/cups-host-helpers.sh"
source "/opt/cups/helpers/cups-host-helpers.sh"

# shellcheck source="./helpers/cups-ssl-helpers.sh"
source "/opt/cups/helpers/cups-ssl-helpers.sh"

# shellcheck source="./helpers/cups-config-helpers.sh"
source "/opt/cups/helpers/cups-config-helpers.sh"

function run() {

    cups_log_level="error"
    cups_encryption="IfRequested"
    cups_access_log_level="config"
    HOST_ALIAS="localhost"
    self_sign=false
    setup

    cups_encryption=$(bashio::config 'cups_ssl.cups_encryption')
    if [ ! -e "$real_cups_path/$cups_client" ] && [ "$cups_encryption" != "Never" ]; then
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

    if [ ! -e "$real_cups_path/$cups_html" ]; then
        autoconf_index
    else
        update_index
    fi

    setup_ssl "$cups_encryption" "$self_sign"
    #add_host_name_to_hosts "$host_name"
}

# Gets current settings from HA
function setup() {
    cups_log_to_file=$(bashio::config 'cups_logging.cups_log_to_file')
    if [ "$cups_log_to_file" = "false" ]; then
        cups_log_to_file=stderr
    else

        cups_log_to_file=$cups_log_path/cups.log
    fi

    cups_log_level=$(bashio::config 'cups_logging.cups_log_level')

    cups_access_log_to_file=$(bashio::config 'cups_logging.cups_access_log_to_file')
    if [ "$cups_access_log_to_file" = "false" ]; then
        cups_access_log_to_file=stderr
    else
        cups_access_log_to_file=$cups_log_path/access.log
    fi

    cups_fatal_errors=$(bashio::config 'cups_logging.cups_fatal_errors')
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
        jq --arg host_name "$HOSTNAME" --arg host_alias "$HOST_ALIAS" --arg cups_fatal_errors "$cups_fatal_errors" --arg cups_www_root "$cups_web_root" \
            --arg cups_ssl_path "$cups_ssl_path" --arg self_sign "$cups_self_sign" --arg cups_encryption "$cups_encryption" \
            --arg cups_log_level "$cups_log_level" --arg cups_access_log_level "$cups_access_log_level" --arg cups_log_to_file "$cups_log_to_file" --arg cups_access_log_to_file "$cups_access_log_to_file" \
            '{ host_name: $host_name, cups_fatal_errors: $cups_fatal_errors, cups_www_root: $cups_www_root, cups_ssl_path: $cups_ssl_path,  host_alias: $host_alias , cups_log_level: $cups_log_level, cups_access_log_level: $cups_access_log_level, self_sign: $self_sign,  cups_encryption: $cups_encryption, cups_log_to_file: $cups_log_to_file, cups_access_log_to_file: $cups_access_log_to_file  }' \
            /data/options.json
    )
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
    update_access_log_location "$cups_access_log_to_file"
    update_log_location "$cups_log_to_file"
    update_self_sign "$self_sign"
    update_web_root "$cups_web_root"
}

function autoconf_index() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_html_tempio" \
        -out "$real_cups_path/$cups_html"
    chown "$svc_acct":"$svc_group" "$real_cups_path/$cups_html"
}

function update_index() {
    true
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
