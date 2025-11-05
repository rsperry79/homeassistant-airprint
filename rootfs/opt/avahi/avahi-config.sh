#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="./avahi-common.sh"
source "/opt/avahi/avahi-common.sh"

function update_interfaces() {
    local bcast_interfaces=${1}
    sed -i "s/^.*allow-interfaces=.*/allow-interfaces=${bcast_interfaces}/" "$real_avahi_path/$avahi_daemon_cfg"
}

function update_reflectors() {
    local avahi_reflector=${1}
    local avahi_reflect_ipv=${2}

    sed -i "s/^.*enable\-reflector=.*/enable\-reflector\=${avahi_reflector}/" "$real_avahi_path/$avahi_daemon_cfg"
    sed -i "s/^.*reflect\-ipv=.*/reflect\-ipv\=${avahi_reflect_ipv}/" "$real_avahi_path/$avahi_daemon_cfg"
}
