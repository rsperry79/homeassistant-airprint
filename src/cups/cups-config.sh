#!/command/with-contend bashio
# shellcheck disable=SC1091,SC2154
# shellcheck disable=SC2181

function linter() {
    # shellcheck source="../../lint/cups-settings.lint"
    source "../../lint/cups-settings.lint"
}

function load_sources() {
    # shellcheck source="../common/paths/cups-paths.sh"
    source "/opt/common/paths/cups-paths.sh"

    # shellcheck source="./helpers/cups-host-helpers.sh"
    source "/opt/cups/helpers/cups-host-helpers.sh"

    # shellcheck source="./helpers/cups-host-helpers.sh"
    source "/opt/cups/helpers/cups-host-helpers.sh"

    # shellcheck source="../common/ha-helpers.sh"
    source "/opt/common/ha-helpers.sh"

    # shellcheck source="./helpers/cups-ssl-helpers.sh"
    source "/opt/cups/helpers/cups-ssl-helpers.sh"

    # shellcheck source="./helpers/cups-config-helpers.sh"
    source "/opt/cups/helpers/cups-config-helpers.sh"

    # shellcheck source="./helpers/cups-logging-helpers.sh"
    source "/opt/cups/helpers/cups-logging-helpers.sh"
}

function run() {
    load_sources
    get_settings

    setup_cups_logging
    setup_ssl
    autoconf_setup

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

    if [ ! -e "$real_cups_path/$cups_client" ] && [ "$CUPS_ENCRYPTION" != "Never" ]; then
        autoconf_client
    else
        update_client
    fi
}

function get_settings() {
    CUPS_SERVER_NAME="$(hostname -f)"
    if bashio::config.has_value 'CUPS_SSL.CUPS_ENCRYPTION'; then
        CUPS_ENCRYPTION=$(bashio::config 'CUPS_SSL.CUPS_ENCRYPTION')
    else
        CUPS_ENCRYPTION=$CUPS_DEFAULT_ENCRYPTION
    fi

    CUPS_SELF_SIGN=false
    if [ "$(ha_is_secure)" == false ]; then
        CUPS_SELF_SIGN=true
    fi

    export CUPS_SERVER_ALIAS
    export CUPS_ENCRYPTION
    export CUPS_SELF_SIGN
}

# Gets current settings from HA
function autoconf_setup() {
    # Used by autoconf
    config=$(
        jq \
            --arg CUPS_SERVER_NAME "$CUPS_SERVER_NAME" \
            --arg CUPS_SERVER_ALIAS "$CUPS_SERVER_ALIAS" \
            --arg CUPS_SELF_SIGN "$CUPS_SELF_SIGN" \
            --arg CUPS_ENCRYPTION "$CUPS_ENCRYPTION" \
            --arg cups_ssl_path "$cups_ssl_path" \
            --arg cups_www_root "$cups_web_root" \
            --arg CUPS_LOG_LEVEL "$CUPS_LOG_LEVEL" \
            --arg CUPS_FATAL_ERROR_LEVEL "$CUPS_FATAL_ERROR_LEVEL" \
            --arg CUPS_ACCESS_LOG_LEVEL "$CUPS_ACCESS_LOG_LEVEL" \
            --arg CUPS_LOG_TO_FILE "$CUPS_LOG_TO_FILE" \
            --arg CUPS_ACCESS_LOG_TO_FILE "$CUPS_ACCESS_LOG_TO_FILE" \
            '{
                CUPS_SERVER_NAME: $CUPS_SERVER_NAME,
                CUPS_SERVER_ALIAS: $CUPS_SERVER_ALIAS,
                CUPS_SELF_SIGN: $CUPS_SELF_SIGN,
                CUPS_ENCRYPTION: $CUPS_ENCRYPTION,
                cups_ssl_path: $cups_ssl_path,
                cups_www_root: $cups_www_root,
                CUPS_LOG_LEVEL: $CUPS_LOG_LEVEL,
                CUPS_FATAL_ERROR_LEVEL: $CUPS_FATAL_ERROR_LEVEL,
                CUPS_ACCESS_LOG_LEVEL: $CUPS_ACCESS_LOG_LEVEL,
                CUPS_LOG_TO_FILE: $CUPS_LOG_TO_FILE,
                CUPS_ACCESS_LOG_TO_FILE: $CUPS_ACCESS_LOG_TO_FILE
            }' /data/options.json
    )
}

function autoconf_client() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_client_cfg" \
        -out "$real_cups_path/$cups_client"
}

function update_client() {
    true
    # TODO
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

function update_daemon() {
    update_log_level "$CUPS_LOG_LEVEL"
    update_server_alias "$CUPS_SERVER_ALIAS"
    # update_server_name "$(hostname -f)"
}

function autoconf_files() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_files_cfg" \
        -out "$real_cups_path/$cups_files"
}

function update_files() {
    update_access_log_level "$CUPS_ACCESS_LOG_LEVEL"
    update_access_log_location "$CUPS_ACCESS_LOG_TO_FILE"
    update_log_location "$CUPS_LOG_TO_FILE"
    update_self_sign "$CUPS_SELF_SIGN"
    update_web_root "$cups_web_root"
}

function autoconf_index() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_html_tempio" \
        -out "$cups_web_root/$cups_html"
    chown "$SVC_ACCT":"$SVC_GROUP" "$cups_web_root/$cups_html"
}

function update_index() {
    true
    # TODO
}

function autoconf_pdf() {
    echo "$config" | tempio \
        -template "$cups_templates_path/$cups_pdf_cfg" \
        -out "$real_cups_path/$cups_pdf"
}

function update_pdf() {
    true
    # TODO
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
