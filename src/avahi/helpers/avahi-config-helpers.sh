#!/command/with-contend bashio
# shellcheck disable=SC2181
# shellcheck source="../../common/settings/avahi-settings.sh"
source "/opt/common/settings/avahi-settings.sh"

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

function setup_reflector () {
    if bashio::config.has_value 'AVAHI_SETTINGS.AVAHI_REFLECTOR'; then
        AVAHI_REFLECTOR_FLAG=$(bashio::config 'AVAHI_SETTINGS.AVAHI_REFLECTOR')

    else
        AVAHI_REFLECTOR_FLAG=$AVAHI_DEFAULT_REFLECTOR
    fi

    if [ "$AVAHI_REFLECTOR_FLAG" == true ]; then
        AVAHI_REFLECTOR="yes"
    else
        AVAHI_REFLECTOR="no"
    fi

    export AVAHI_REFLECTOR
}

function setup_ipv_reflector () {
    if bashio::config.has_value 'AVAHI_SETTINGS.AVAHI_REFLECTOR_IPV'; then
        AVAHI_REFLECTOR_FLAG=$(bashio::config 'AVAHI_SETTINGS.AVAHI_REFLECTOR_IPV')
    else
        AVAHI_REFLECTOR_FLAG=$AVAHI_DEFAULT_REFLECT_IPV
    fi

    if [ "$AVAHI_REFLECTOR_FLAG" == true ]; then
        AVAHI_REFLECTOR_IPV="yes"
    else
        AVAHI_REFLECTOR_IPV="no"
    fi

    export AVAHI_REFLECTOR_IPV
}

function setup_ipv6 () {
    if bashio::config.has_value 'AVAHI_SETTINGS.AVAHI_USE_IPV6'; then
        ipv6_flag=$(bashio::config 'AVAHI_SETTINGS.AVAHI_USE_IPV6')
    else
        ipv6_flag=$AVAHI_DEFAULT_USE_IPV6
    fi

    if [ "$ipv6_flag" == true ]; then
        AVAHI_USE_IPV6="yes"
    else
        AVAHI_USE_IPV6="no"
    fi

    export AVAHI_USE_IPV6
}
