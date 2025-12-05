#!/command/with-contend bashio
# shellcheck source="../common/settings.sh"
source "/opt/common/settings.sh"

function get_host() {
    # ssl_certificate
    true
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
        add_host_name_to_hosts "$to_check"
    done
}
