#!/command/with-contend bashio
# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck source="./avahi-config-helpers.sh"
source "/opt/avahi/avahi-config-helpers.sh"

# shellcheck source="../common/network-common.sh"
source "/opt/common/network-common.sh"

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

function setup() {
    host_name=$(bashio::info.hostname)
    host="${host_name%%.*}"

    use_ipv6="no"
    if bashio::config.has_value 'use_ipv6'; then
        ipv6_flag=$(bashio::config 'use_ipv6')
        if [ "$ipv6_flag" == true ]; then
            use_ipv6="yes"
        fi
    fi

    avahi_reflector="no"
    if bashio::config.has_value 'avahi_reflector'; then
        avahi_reflector_flag=$(bashio::config 'avahi_reflector')
        if [ "$avahi_reflector_flag" == true ]; then
            avahi_reflector="yes"
        fi
    fi

    avahi_reflect_ipv="no"
    if bashio::config.has_value 'avahi_reflector'; then
        avahi_reflector_flag=$(bashio::config 'avahi_reflector')
        if [ "$avahi_reflector_flag" == true ]; then
            avahi_reflect_ipv="yes"
        fi
    fi
}

# Uses the template to regenerate the configuration file. Ensures a clean file.
function autoconf_config() {
    # Fill config file templates with runtime data

    config=$(jq --arg host_name "$host" --arg use_ipv6 "$use_ipv6" --arg avahi_reflector "$avahi_reflector" --arg avahi_reflect_ipv "$avahi_reflect_ipv" --arg bcast_interfaces "$bcast_interfaces" \
        '{host_name: $host_name, use_ipv6: $use_ipv6, avahi_reflector: $avahi_reflector, avahi_reflect_ipv: $avahi_reflect_ipv,  bcast_interfaces: $bcast_interfaces}' \
        /data/options.json)
    #if [ ! -e "$real_cups_path/$cups_daemon_cfg" ]; then

    echo "$config" | tempio \
        -template "$avahi_templates_path/$avahi_daemon_cfg" \
        -out "$avahi_config_path/$avahi_daemon"
}

function update_avahi_config() {
    #sed -i "s/^.*host-name=.*/host-name=${host}/" "$avahi_config_path/$avahi_daemon"
    sed -i "s/^.*use-ipv6=.*/use-ipv6=${use_ipv6}/" "$avahi_config_path/$avahi_daemon"
    sed -i "s/^.*publish-aaaa-on-ipv4=.*/publish-aaaa-on-ipv4=${use_ipv6}/" "$avahi_config_path/$avahi_daemon"

    update_reflectors "$avahi_reflector" "$avahi_reflect_ipv"
    update_interfaces "$bcast_interfaces"
}

run
