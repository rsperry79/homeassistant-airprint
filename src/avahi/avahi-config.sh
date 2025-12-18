#!/command/with-contend bashio

# shellcheck source="../common/paths/avahi-paths.sh"
source "/opt/common/paths/avahi-paths.sh"

# shellcheck source="../common/settings/avahi-settings.sh"
source "/opt/common/settings/avahi-settings.sh"

# shellcheck source="./helpers/avahi-config-helpers.sh"
source "/opt/avahi/helpers/avahi-config-helpers.sh"

# shellcheck source="../common/network-common.sh"
source "/opt/common/network-common.sh"


function linter () {
    # shellcheck source="../../lint/avahi-settings.lint"
    source "../../lint/avahi-settings.lint"
}

function run() {
    setup
    bcast_interfaces=$(get_interfaces)
    #enable_resolved "$bcast_interfaces"

    if [ ! -e "$avahi_config_path/$avahi_daemon" ]; then
        autoconf_config
    else
        update_avahi_config
    fi
}

function setup_reflector () {
    if bashio::config.has_value 'AVAHI_SETTINGS.AVAHI_REFLECTOR'; then
        AVAHI_REFLECTOR=$(bashio::config 'AVAHI_SETTINGS.AVAHI_REFLECTOR')

    else
        AVAHI_REFLECTOR=$AVAHI_DEFAULT_REFLECTOR
    fi

    if [ "$AVAHI_REFLECTOR" == true ]; then
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

function setup() {
    host_name=$(bashio::info.hostname)
    host="${host_name%%.*}"

    setup_reflector
    setup_ipv_reflector
    setup_ipv6
}

# Uses the template to regenerate the configuration file. Ensures a clean file.
function autoconf_config() {
    # Fill config file templates with runtime data

    config=$(jq \
        --arg host_name "$host" \
        --arg AVAHI_USE_IPV6 "$AVAHI_USE_IPV6" \
        --arg AVAHI_REFLECTOR "$AVAHI_REFLECTOR_FLAG" \
        --arg AVAHI_REFLECTOR_IPV "$AVAHI_REFLECTOR_IPV_FLAG" \
        --arg bcast_interfaces "$bcast_interfaces" \
        '{
            host_name: $host_name,
            AVAHI_USE_IPV6: $AVAHI_USE_IPV6,
            AVAHI_REFLECTOR: $AVAHI_REFLECTOR,
            AVAHI_REFLECTOR_IPV: $AVAHI_REFLECTOR_IPV,
            bcast_interfaces: $bcast_interfaces
        }' /data/options.json)

    echo "$config" | tempio \
        -template "$avahi_templates_path/$avahi_daemon_cfg" \
        -out "$avahi_config_path/$avahi_daemon"
}

function update_avahi_config() {
    #sed -i "s/^.*host-name=.*/host-name=${host}/" "$avahi_config_path/$avahi_daemon"
    sed -i "s/^.*use-ipv6=.*/use-ipv6=${AVAHI_USE_IPV6}/" "$avahi_config_path/$avahi_daemon"
    sed -i "s/^.*publish-aaaa-on-ipv4=.*/publish-aaaa-on-ipv4=${AVAHI_USE_IPV6}/" "$avahi_config_path/$avahi_daemon"

    update_reflectors "$AVAHI_REFLECTOR" "$AVAHI_REFLECTOR_IPV"
    update_interfaces "$bcast_interfaces"
}

run
