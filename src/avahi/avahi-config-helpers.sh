#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

function update_interfaces() {
    local bcast_interfaces=${1}
    sed -i "s/^.*allow-interfaces=.*/allow-interfaces=${bcast_interfaces}/" "$avahi_config_path/$avahi_daemon"
}

function update_reflectors() {
    local avahi_reflector=${1}
    local avahi_reflect_ipv=${2}

    sed -i "s/^.*enable\-reflector=.*/enable\-reflector\=${avahi_reflector}/" "$avahi_config_path/$avahi_daemon"
    sed -i "s/^.*reflect\-ipv=.*/reflect\-ipv\=${avahi_reflect_ipv}/" "$avahi_config_path/$avahi_daemon"
}
