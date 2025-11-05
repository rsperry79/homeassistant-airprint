#!/command/with-contend bashio

# shellcheck source="./cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

# shellcheck source="./cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

# shellcheck source="./cups-common.sh"
source "/opt/cups/cups-common.sh"

function setup_ssl() {
    host_name=${1}
    self_sign=${2}

    privkey="$ssl_dir/$host_name.crt"
    pubkey="$ssl_dir/$host_name.pem"

    if [ "$self_sign" == true ]; then
        bashio::log.info "Self sign is on"
    else
        bashio::log.info "Self sign is off"
        rm -f "$ssl_dir/*"
        setup_ssl_public
        setup_ssl_private
    fi
}

function setup_ssl_private() {
    local _privkey
    if bashio::config.has_value 'cups_ssl_key'; then
        _privkey=$(bashio::config 'cups_ssl_key')
    elif [ -e "/ssl/privkey.pem" ]; then
        _privkey="/ssl/privkey.pem"
    else
        _privkey=""
    fi

    if [ ! -e "$_privkey" ]; then
        bashio::log.notice "SSL Private key does not exist at given path"
    else
        convert_private_key "$_privkey"
    fi
}

function setup_ssl_public() {
    local _pubkey
    if bashio::config.has_value 'cups_ssl_cert'; then
        _pubkey=$(bashio::config 'cups_ssl_cert')
    elif [ -e "/ssl/fullchain.pem" ]; then
        _pubkey="/ssl/fullchain.pem"
    else
        _pubkey=""
    fi

    if [ ! -e "$_pubkey" ]; then
        bashio::log.notice "SSL Public key does not exist at given path"
    else
        update_hosts "$_pubkey"
        convert_public_key "$_pubkey"
    fi
}

function convert_private_key() {
    local _privkey=${1}

    rm -f "$ssl_dir/$host_name.key"
    msg=$(openssl rsa -in "$_privkey" -out "$ssl_dir/$host_name.key")
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        privkey="$ssl_dir/$host_name.key"
        chown "$ssl_owner":"$ssl_group" "$privkey"
        chmod "$ssl_perms" "$privkey"
        bashio::log.debug "SSL Private Key exists. $privkey"
    else
        bashio::log.error "Private key is not valid. $msg"
    fi
}

function convert_public_key() {
    local _pubkey=${1}

    rm -f "$ssl_dir/$host_name.crt"
    msg=$(openssl x509 -in "$_pubkey" -out "$ssl_dir/$host_name.crt")
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        chown "$ssl_owner":"$ssl_group" "$pubkey"
        chmod "$ssl_perms" "$pubkey"
        bashio::log.debug "SSL Public Key exists. $pubkey"
    else
        bashio::log.error "Public key is not valid. $msg"
    fi
}
