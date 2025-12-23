#!/command/with-contend bashio
# shellcheck disable=SC2154
CUPS_PUBLIC_KEY_HA_PATH=""
CUPS_PRIVATE_KEY_HA_PATH=""

function load_sources() {
    # shellcheck disable=SC1091

    # shellcheck source="../../common/settings.sh"
    source "/opt/common/settings.sh"

    # shellcheck source="../../common/ha-helpers.sh"
    source "/opt/common/ha-helpers.sh"

    # shellcheck source="../../common/paths/cups-paths.sh"
    source "/opt/common/paths/cups-paths.sh"

    # shellcheck source="../../common/settings/cups-settings.sh"
    source "/opt/common/settings/cups-settings.sh"

    # shellcheck source="./cups-config-helpers.sh"
    source "/opt/cups/helpers/cups-config-helpers.sh"

    # shellcheck source="./cups-host-helpers.sh"
    source "/opt/cups/helpers/cups-host-helpers.sh"
}

function lint() {
    # shellcheck source="../../../lint/cups-settings.lint"
    source "../../../lint/cups-settings.lint"
}

function setup_ssl() {
    load_sources || {
        bashio::log.error "Failed to load required sources"
        return 1
    }

    CUPS_SERVER_NAME=$(bashio::addon.dns)
    add_host_name_to_hosts_file "$CUPS_SERVER_NAME"
    CUPS_SERVER_ALIAS="$(hostname -f)"

    if [ "$CUPS_ENCRYPTION" = "Never" ]; then
        bashio::log.info "CUPS_ENCRYPTION is set to Never, disabling SSL"
        CUPS_SERVER_ALIAS="$(hostname -f)"
        disable_ssl_config
    else
            if [ "$CUPS_SELF_SIGN" = "true" ]; then
                CUPS_SERVER_NAME=$(bashio::addon.dns)
                add_host_name_to_hosts_file "$CUPS_SERVER_NAME"
                CUPS_SERVER_ALIAS="$(hostname -f)"
            else
                bashio::log.info "Setting up SSL certificates"
                if [ -d "$cups_ssl_path" ]; then
                    rm -rf "${cups_ssl_path:?}"/*
                fi
            fi

            get_keys

            if [ "$CUPS_SELF_SIGN" = "false" ]; then
                bashio::log.info "Using HomeAssistant's certificates"
                setup_ssl_public "$CUPS_PUBLIC_KEY_HA_PATH" "$CUPS_PUBLIC_KEY"
                convert_private_key "$CUPS_PRIVATE_KEY_HA_PATH" "$CUPS_PRIVATE_KEY"
            else
                bashio::log.info "Using self-signed certificate"
            fi

    fi
}

function get_keys () {

    if [ "$CUPS_SELF_SIGN" = "false" ]; then
        get_ha_certs

         if [ -s "$(realpath "$HA_SSL_CERT")" ]; then
            bashio::log.info "SSL Public Key was discovered at $HA_SSL_CERT"
            _pubkey=$HA_SSL_CERT

            # private key
            if [ -s "$(realpath "$HA_SSL_KEY")" ]; then
                bashio::log.info "SSL Private Key was discovered at $HA_SSL_KEY"
                _privkey=$HA_SSL_KEY
                # get the CN name from the public key

                CUPS_SERVER_NAME=$(get_cn_name "$_pubkey")
                CUPS_PUBLIC_KEY_HA_PATH="$_pubkey"
                CUPS_PRIVATE_KEY_HA_PATH="$_privkey"
                CUPS_PUBLIC_KEY="$cups_ssl_path/$CUPS_SERVER_NAME.crt"
                CUPS_PRIVATE_KEY="$cups_ssl_path/$CUPS_SERVER_NAME.key"

                export CUPS_PUBLIC_KEY
                export CUPS_PRIVATE_KEY
                export CUPS_SERVER_NAME
            else
                bashio::log.error "SSL Private Key does not exist at given path: $HA_SSL_KEY"
            fi
        else
            bashio::log.error "SSL Public Key does not exist at discovered path: $HA_SSL_CERT"
            bashio::log.error "/ssl: $(ls -la /ssl)"
            CUPS_SELF_SIGN="true"
        fi
    else
        bashio::log.info "Unable to find SSL Cert, setting Self-Sign on"
        CUPS_SELF_SIGN="true"
        return
    fi
}

function setup_ssl_public() {
    local pubkey=${1}
    local output_file=${2}

    convert_public_key "$pubkey" "$output_file"
    update_hosts "$pubkey"
    export CUPS_SERVER_ALIAS
}

function convert_private_key() {
    local to_convert=${1}
    local output_file=${2}
    bashio::log.info "Converting Private Key: $to_convert to $output_file"
    rm -f "$output_file"
    if openssl rsa -in "$to_convert" -out "$output_file" 2>&1; then
        chown "$SVC_ACCT":"$SVC_GROUP" "$output_file"
        chmod "$SVC_FILE_PERMS" "$output_file"
        bashio::log.debug "SSL Private Key exists. $output_file"
    else
        bashio::log.error "Private key is not valid."
    fi
}

function convert_public_key() {
    local to_convert=${1}
    local output_file=${2}

    bashio::log.info "Converting Public Key: $to_convert to $output_file"
    rm -f "$output_file"
    if openssl x509 -in "$to_convert" -out "$output_file" 2>&1; then
        chown "$SVC_ACCT":"$SVC_GROUP" "$output_file"
        chmod "$SVC_FILE_PERMS" "$output_file"
        bashio::log.debug "SSL Public Key exists. $output_file"
    else
        bashio::log.error "Public key is not valid."
    fi
}
