#!/command/with-contend bashio

function load_sources () {
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

function lint () {
    # shellcheck source="../../../lint/cups-settings.lint"
    source "../../../lint/cups-settings.lint"
}


function setup_ssl() {
    load_sources || {
        bashio::log.error "Failed to load required sources"
        return 1
    }

    if [ "$CUPS_ENCRYPTION" = "Never" ]; then
        bashio::log.info "CUPS_ENCRYPTION is set to Never, disabling SSL"
        disable_ssl_config
    else
        if [ "$CUPS_SELF_SIGN" == "false" ]; then
            bashio::log.info "CUPS_SELF_SIGN is set to false, using provided SSL certificates"
            if [ -d "$cups_ssl_path" ]; then
                rm -f "$cups_ssl_path/*"
            fi

            setup_ssl_public
            setup_ssl_private
        fi
        if [ "$CUPS_SELF_SIGN" == "true" ]; then
            bashio::log.info "Using self-signed certificate"
            CUPS_HOST_ALIAS="$(hostname -f)"
        fi
    fi
}

function setup_ssl_private() {

    local _privkey

    if [ "$CUPS_SELF_SIGN" = false ]; then
         bashio::log.info "Using $HA_SSL_KEY for SSL Private Key"
        _privkey=$HA_SSL_KEY
    elif [ -e "/ssl/privkey.pem" ]; then
        _privkey="/ssl/privkey.pem"
    else
        bashio::log.info "Unable to find SSL key, setting Self-Sign on"
        CUPS_SELF_SIGN="true"
        return
    fi

    if [ ! -e "$_privkey" ]; then
        bashio::log.notice "SSL Private key does not exist at given path"
    else
        convert_private_key "$_privkey" "$CUPS_PRIVATE_KEY"
    fi
}

function setup_ssl_public() {

    local _pubkey

   if [ "$CUPS_SELF_SIGN" = "false" ]; then
        get_ha_certs
        bashio::log.info "Using $HA_SSL_CERT for SSL Public Key"

        _pubkey=$HA_SSL_CERT
    elif [ -e "/ssl/fullchain.pem" ]; then
        _pubkey="/ssl/fullchain.pem"
    else
        bashio::log.info "Unable to find SSL Cert, setting Self-Sign on"
        CUPS_SELF_SIGN="true"
        return
    fi
    CUPS_PUBLIC_KEY="$cups_ssl_path/$CUPS_HOST_ALIAS.crt"
    CUPS_PRIVATE_KEY="$cups_ssl_path/$CUPS_HOST_ALIAS.key"

    CUPS_HOST_ALIAS=$(get_cn_name "$CUPS_PUBLIC_KEY")
    # TODO HIDE?


    if [ ! -e "$CUPS_PUBLIC_KEY" ]; then
        bashio::log.notice "SSL Public key does not exist at given path"
    else
        update_hosts "$CUPS_PUBLIC_KEY"

        #cp "$_pubkey" "$CUPS_PUBLIC_KEY"
        convert_public_key "$CUPS_PUBLIC_KEY" "$CUPS_PUBLIC_KEY"
    fi

}

function convert_private_key() {
    local to_convert=${1}
    local output_file=${2}

    rm -f "$CUPS_PRIVATE_KEY"
    msg=$(openssl rsa -in "$to_convert" -out "$CUPS_PRIVATE_KEY")
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        chown "$SVC_ACCT":"$SVC_GROUP" "$CUPS_PRIVATE_KEY"
        chmod "$SVC_FILE_PERMS" "$CUPS_PRIVATE_KEY"
        bashio::log.debug "SSL Private Key exists. $CUPS_PRIVATE_KEY"
    else
        bashio::log.error "Private key is not valid. $msg"
    fi
}

function convert_public_key() {
    local to_convert=${1}
    local output_file=${2}

    rm -f "$output_file"
    msg=$(openssl x509 -in "$to_convert" -out "$output_file")
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        chown "$SVC_ACCT":"$SVC_GROUP" "$output_file"
        chmod "$SVC_FILE_PERMS" "$output_file"
        bashio::log.debug "SSL Public Key exists. $output_file"
    else
        bashio::log.error "Public key is not valid. $msg"
    fi
}
