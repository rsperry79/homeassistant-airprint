#!/command/with-contend bashio

# shellcheck source="../../common/settings.sh"
source "/opt/common/settings.sh"

# shellcheck source="../../common/paths/cups-paths.sh"
source "/opt/common/paths/cups-paths.sh"

# shellcheck source="./cups-config-helpers.sh"
source "/opt/cups/helpers/cups-config-helpers.sh"

# shellcheck source="./cups-host-helpers.sh"
source "/opt/cups/helpers/cups-host-helpers.sh"

function setup_ssl() {
    local use_ssl=${1}
    local self_sign=${2}

    if [ "$use_ssl" = "Never" ]; then
        disable_ssl_config
    else
        if [ "$self_sign" == true ]; then
            HOST_ALIAS="$(hostname -f)"
        else
            bashio::log.info "Self sign is off"
            rm -f "$cups_ssl_path/*"
            setup_ssl_public
            setup_ssl_private
        fi
    fi
}

function setup_ssl_private() {

    local _privkey

    if bashio::config.has_value 'cups_ssl.cups_ssl_key'; then
        _privkey=$(bashio::config 'cups_ssl.cups_ssl_key')
    elif [ -e "/ssl/privkey.pem" ]; then
        _privkey="/ssl/privkey.pem"
    else
        _privkey=""
    fi

    if [ ! -e "$_privkey" ]; then
        bashio::log.notice "SSL Private key does not exist at given path"
    else

        convert_private_key "$_privkey" "$CUPS_PRIVATE_KEY"
        # cp "$_privkey" "$CUPS_PRIVATE_KEY"
    fi
}

function setup_ssl_public() {

    local _pubkey

    if bashio::config.has_value 'cups_ssl.cups_ssl_cert'; then
        _pubkey=$(bashio::config 'cups_ssl.cups_ssl_cert')
    elif [ -e "/ssl/fullchain.pem" ]; then
        _pubkey="/ssl/fullchain.pem"
    else
        _pubkey=""
    fi

    HOST_ALIAS=$(get_cn_name "$_pubkey")
    CUPS_PUBLIC_KEY="$cups_ssl_path/$HOST_ALIAS.crt"
    CUPS_PRIVATE_KEY="$cups_ssl_path/$HOST_ALIAS.key"

    if [ ! -e "$_pubkey" ]; then
        bashio::log.notice "SSL Public key does not exist at given path"
    else
        update_hosts "$_pubkey"

        #cp "$_pubkey" "$CUPS_PUBLIC_KEY"
        convert_public_key "$_pubkey" "$CUPS_PUBLIC_KEY"
    fi
}

function convert_private_key() {
    local to_convert=${1}
    local output_file=${2}

    rm -f "$CUPS_PRIVATE_KEY"
    msg=$(openssl rsa -in "$to_convert" -out "$CUPS_PRIVATE_KEY")
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        chown "$svc_acct":"$svc_group" "$CUPS_PRIVATE_KEY"
        chmod "$svc_file_perms" "$CUPS_PRIVATE_KEY"
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
        chown "$svc_acct":"$svc_group" "$output_file"
        chmod "$svc_file_perms" "$output_file"
        bashio::log.debug "SSL Public Key exists. $output_file"
    else
        bashio::log.error "Public key is not valid. $msg"
    fi
}
