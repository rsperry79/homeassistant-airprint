#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../../common/paths/avahi-paths.sh"
source "/opt/common/paths/avahi-paths.sh"

function update_interfaces() {
    local bcast_interfaces=${1}
    sed -i "s/^.*allow-interfaces=.*/allow-interfaces=${bcast_interfaces}/" "$avahi_config_path/$avahi_daemon"
}

function update_reflectors() {
    local AVAHI_REFLECTOR=${1}
    local AVAHI_REFLECTOR_IPV=${2}

    sed -i "s/^.*enable\-reflector=.*/enable\-reflector\=${AVAHI_REFLECTOR}/" "$avahi_config_path/$avahi_daemon"
    sed -i "s/^.*reflect\-ipv=.*/reflect\-ipv\=${AVAHI_REFLECTOR_IPV}/" "$avahi_config_path/$avahi_daemon"
}
