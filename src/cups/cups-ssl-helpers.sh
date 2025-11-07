#!/command/with-contend bashio

# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck source="./cups-config-helpers.sh"
source "/opt/cups/cups-config-helpers.sh"

# shellcheck source="./cups-host-helpers.sh"
source "/opt/cups/cups-host-helpers.sh"

function setup_ssl() {
    host_name=${1}
    self_sign=${2}

    CUPS_PRIVATE_KEY="$cups_ssl_path/$host_name.crt"
    CUPS_PUBLIC_KEY="$cups_ssl_path/$host_name.pem"

    if [ "$self_sign" == true ]; then
        bashio::log.info "Self sign is on"
    else
        bashio::log.info "Self sign is off"
        rm -f "$cups_ssl_path/*"

        setup_ssl_private "$CUPS_PRIVATE_KEY"
        setup_ssl_public "$CUPS_PUBLIC_KEY"
    fi

    export cups_public_key
    export cups_private_key
}

function setup_ssl_private() {
    local output_file=${1}
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
        echo
        # convert_private_key "$_privkey" "$output_file"
        #cp "$_privkey" "$CUPS_PRIVATE_KEY"
    fi
}

function setup_ssl_public() {
    local output_file=${1}
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

        #cp "$_pubkey" "$CUPS_PUBLIC_KEY"
        #convert_public_key "$_pubkey" "$output_file"
    fi
}

function convert_private_key() {
    local to_convert=${1}
    local output_file=${2}

    rm -f "$output_file"
    msg=$(openssl rsa -in "$to_convert" -out "$output_file")
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        chown "$svc_acct":"$svc_group" "$output_file"
        chmod "$svc_file_perms" "$output_file"
        bashio::log.debug "SSL Private Key exists. $output_file"
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

# function update_cert_file_names() {
#     local new_name=${1}

#     # new names
#     CUPS_PRIVATE_KEY="$ssl_dir/$new_name.crt"
#     CUPS_PUBLIC_KEY="$ssl_dir/$new_name.pem"

#     # get existing names
#     # TODO READ FROM FILE
#     host_name=$(hostname -f)
#     old_private="$ssl_dir/$host_name.crt"
#     old_public="$ssl_dir/$host_name.pem"

#     # Rename files
#     mv "$old_private" "$CUPS_PRIVATE_KEY"
#     mv "$old_public" "$CUPS_PUBLIC_KEY"

#     # updates the config
#     update_private_key "$CUPS_PRIVATE_KEY"
#     update_public_key "$CUPS_PUBLIC_KEY"
# }
