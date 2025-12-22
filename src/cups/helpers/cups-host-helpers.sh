#!/command/with-contend bashio
# shellcheck disable=SC1091,SC2154
# shellcheck disable=SC2181

# shellcheck source="../../common/paths/cups-paths.sh"
source "/opt/common/paths/cups-paths.sh"

# shellcheck source="./cups-config-helpers.sh"
source "/opt/cups/helpers/cups-config-helpers.sh"

function update_hosts() {
    local pubkey="${1}"
    CUPS_SERVER_ALIAS=$(get_cn_name "$pubkey")
    add_sans "$pubkey"
}

function get_cn_name() {
    local pubkey="${1}"
    cn=$(openssl x509 -noout -subject -in "$pubkey" -nameopt multiline | awk -F' = ' '/commonName/ {print $2}')

    trimmed_cn="${cn#"${cn%%[![:space:]]*}"}"
    add_host_name_to_hosts_file "$trimmed_cn"
    echo "$trimmed_cn"
}

function add_host_name_to_hosts_file() {
    local to_check=${1}

    if ! grep -q "127.0.0.1 $to_check" /etc/hosts; then
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
        append_host_alias "$to_check"
        add_host_name_to_hosts_file "$to_check"
    done
}

function append_host_alias() {
    local to_check=${1}

    if ! echo "$CUPS_SERVER_ALIAS" | grep -q "$to_check"; then
        CUPS_SERVER_ALIAS+=" $to_check"
    fi
}

function append_existing_host_alias() {
    local to_add=${1}

    current=$(grep "ServerAlias" "$real_cups_path/$cups_daemon")
    if ! echo "$current" | grep "$to_add"; then
        sed -i "s/^.*ServerAlias .*/$current $to_add/" "$real_cups_path/$cups_daemon"
    fi
}



function update_server_name() {
    local setting=${1}
    bashio::log.debug update_server_name
    if [ -e "$real_cups_path/$cups_daemon" ]; then
        sed -i "s/^.*ServerName .*/ServerName ${setting}/" "$real_cups_path/$cups_daemon"
    fi
}
