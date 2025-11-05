#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="./cups-common.sh"
source "/opt/helpers/cups-common.sh"

function update_hosts() {
    local pubkey="${1}"

    cn=$(openssl x509 -noout -subject -in "$pubkey" -nameopt multiline | awk -F' = ' '/commonName/ {print $2}')
    bashio::log.debug "CN $cn"

    trimmed_cn="${cn#"${cn%%[![:space:]]*}"}"
    add_host_name_to_hosts "$trimmed_cn"
    HOST_ALIAS="$trimmed_cn"
    add_sans "$pubkey"
}

function add_host_name_to_hosts() {
    local to_check=${1}

    if ! grep -q "$to_check" /etc/hosts; then
        bashio::log.debug "Adding host: $to_check to /etc/hosts"
        echo "127.0.0.1 $to_check" >>/etc/hosts
    else
        bashio::log.debug "Not Adding host: $to_check to /etc/hosts"
    fi
}

function add_sans() {
    local cert=${1}

    sans=$(openssl x509 -noout -text -in "$cert" | grep DNS: | tail -n1 | sed 's/DNS://g; s/, / /g')
    trimmed="${sans#"${sans%%[![:space:]]*}"}"

    set -f
    IFS=' ' read -r -a names <<<"$trimmed"
    set +f

    for index in "${!names[@]}"; do
        to_check="${names[index]}"
        bashio::log.debug "add_sans checking: $to_check"
        add_host_name_to_hosts "$to_check"
        append_host_alias "$to_check"
    done
}

function append_host_alias() {
    local to_check=${1}

    if ! echo "$HOST_ALIAS" | grep "$to_check"; then
        HOST_ALIAS+=" $to_check"
    fi
}

function append_host_existing_alias() {
    to_add=${1}

    current=$(grep "ServerAlias" /config/cups/cupsd.conf)
    to_save="$current $to_add"
    bashio::log.red "append_host_existing_alias $to_save"
    sed -i "s/^.*ServerAlias .*/ServerAlias ${HOST_ALIAS}/" "$real_cups_path/$cups_daemon_cfg"

    current=$(grep "ServerAlias" /config/cups/cupsd.conf)

    bashio::log.red "append_host_existing_alias $current"
}
