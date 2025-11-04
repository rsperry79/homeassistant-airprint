#!/command/with-contend bashio
# shellcheck disable=SC2181
readonly ssl_dir="/config/cups/ssl"

readonly ssl_owner="root"
readonly ssl_group="root"
readonly ssl_perms="770"

function update_hosts() {
    pubkey=${1}
    cn=$(openssl x509 -noout -subject -in "$pubkey" -nameopt multiline | awk -F' = ' '/commonName/ {print $2}')
    bashio::log.debug "CN $cn"

    host_alias="${cn#"${cn%%[![:space:]]*}"}"

    add_host_name_to_hosts "$host_alias"

    add_sans "$pubkey"
}

function add_host_name_to_hosts() {
    host_alias=${1}
    if ! grep -q "$host_alias" /etc/hosts; then
        bashio::log.info "Adding host: $host_alias to /etc/hosts"
        echo "127.0.0.1 $host_alias" >>/etc/hosts
    else
        bashio::log.info "Not Adding host: $host_alias to /etc/hosts"
    fi
}

function add_sans() {
    cert=${1}
    sans=$(openssl x509 -noout -text -in "$cert" | grep DNS: | tail -n1 | sed 's/DNS://g; s/, / /g')
    trimmed="${sans#"${sans%%[![:space:]]*}"}"

    set -f
    IFS=' ' read -r -a names <<<"$trimmed"
    set +f

    for index in "${!names[@]}"; do
        to_check="${names[index]}"
        bashio::log.blue "add_sans checking: $to_check"
        add_host_name_to_hosts "$to_check"
        append_host_alias "$to_check"
    done

    bashio::log.info "helpers host_alias: $host_alias"
}

function append_host_alias() {
    bashio::log.info "checking  $to_check for host aliases :: $host_alias"
    if [ "$(! echo "$host_alias" | grep "$to_check")" ]; then
        host_alias+=" $to_check"
        bashio::log.yellow "added $to_check to host aliases"
        bashio::log.red "helpers append_host_alias host_alias: $host_alias"
    fi
}

function append_host_existing_alias() {
    to_add=${1}

    temp=$(grep "ServerAlias" /config/cups/cupsd.conf)
    bashio::log.info "append_host_existing_alias\r\n $temp\r\n$to_add"

}

function setup_ssl() {
    host_name=${1}
    self_sign=${2}
    # TODO MOVE

    if [ "$self_sign" == true ]; then
        bashio::log.info "Self sign is on"

        privkey="$ssl_dir/$host_name.crt"
        pubkey="$ssl_dir/$host_name.pem"
    else
        bashio::log.info "Self sign is off"

        rm -f "$ssl_dir/*"
        setup_ssl_public
        setup_ssl_private
    fi

}

function setup_ssl_private() {
    privkey="/ssl/privkey.pem"
    if bashio::config.has_value 'cups_ssl_key'; then
        privkey=$(bashio::config 'cups_ssl_key')
    elif [ -e "/ssl/privkey.pem" ]; then
        privkey="/ssl/privkey.pem"
    else
        privkey=""
    fi

    if [ ! -e "$privkey" ]; then
        bashio::log.notice "SSL Private key does not exist at given path"
    else
        convert_private_key
    fi
}

function setup_ssl_public() {
    if bashio::config.has_value 'cups_ssl_cert'; then
        pubkey=$(bashio::config 'cups_ssl_cert')
    elif [ -e "/ssl/fullchain.pem" ]; then
        pubkey="/ssl/fullchain.pem"
    else
        pubkey=""
    fi

    if [ ! -e "$pubkey" ]; then
        bashio::log.notice "SSL Public key does not exist at given path"
    else
        update_hosts "$pubkey"
        convert_public_key
    fi
}

function convert_private_key() {
    rm -f "$ssl_dir/$host_name.key"
    msg=$(openssl rsa -in "$privkey" -out "$ssl_dir/$host_name.key")
    if [ $? -eq 0 ]; then
        chown "$ssl_owner":"$ssl_group" "$ssl_dir/$host_name.key"
        chmod "$ssl_perms" "$ssl_dir/$host_name.key"
        privkey="$ssl_dir/$host_name.key"
        bashio::log.debug "SSL Private Key exists. $privkey"
    else
        bashio::log.error "Private key is not valid. $msg"
    fi
}

function convert_public_key() {
    rm -f "$ssl_dir/$host_name.crt"
    msg=$(openssl x509 -in "$pubkey" -out "$ssl_dir/$host_name.crt")
    if [ $? -eq 0 ]; then
        chown "$ssl_owner":"$ssl_group" "$ssl_dir/$host_name.crt"
        chmod "$ssl_perms" "$ssl_dir/$host_name.crt"
        pubkey="$ssl_dir/$host_name.crt"
        bashio::log.debug "SSL Public Key exists. $pubkey"
    else
        bashio::log.error "Public key is not valid. $msg"
    fi
}
