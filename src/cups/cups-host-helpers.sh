#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck source="./cups-config-helpers.sh"
source "/opt/cups/cups-config-helpers.sh"

function update_hosts() {
    local pubkey="${1}"
    HOST_ALIAS=$(get_cn_name "$pubkey")
    add_sans "$pubkey"
}

function get_cn_name() {
    local pubkey="${1}"
    cn=$(openssl x509 -noout -subject -in "$pubkey" -nameopt multiline | awk -F' = ' '/commonName/ {print $2}')
    bashio::log.info "CN $cn"

    trimmed_cn="${cn#"${cn%%[![:space:]]*}"}"
    add_host_name_to_hosts "$trimmed_cn"
    echo "$trimmed_cn"
}

function add_host_name_to_hosts() {
    local to_check=${1}

    if ! grep -q "$to_check 127.0.0.1" /etc/hosts; then
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
        bashio::log.info "add_sans checking: $to_check"

        append_host_alias "$to_check"
        add_host_name_to_hosts "$to_check"
    done
}

function append_host_alias() {
    local to_check=${1}

    if ! echo "$HOST_ALIAS" | grep -q "$to_check"; then
        HOST_ALIAS+=" $to_check"
    fi
}

function append_existing_host_alias() {
    local to_add=${1}
    bashio::log.info "append_existing_host_alias $to_add"

    current=$(grep "ServerAlias" "$real_cups_path/$cups_daemon")
    bashio::log.info "append_existing_host_alias current: $current"
    if ! echo "$current" | grep "$to_add"; then
        bashio::log.info append_existing_host_alias
        sed -i "s/^.*ServerAlias .*/$current $to_add/" "$real_cups_path/$cups_daemon"
    fi
}
