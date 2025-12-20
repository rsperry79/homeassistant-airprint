#!/command/with-contend bashio
# shellcheck disable=SC1091,SC2154

function load_sources() {
    # shellcheck source="../common/paths/avahi-paths.sh"
    source "/opt/common/paths/avahi-paths.sh" || {
        echo "Failed to load avahi-paths.sh" >&2
        exit 1
    }

    # shellcheck source="./helpers/avahi-config-helpers.sh"
    source "/opt/avahi/helpers/avahi-config-helpers.sh" || {
        echo "Failed to load avahi-config-helper.sh" >&2
        exit 1
    }

    # shellcheck source="../common/network-common.sh"
    source "/opt/common/network-common.sh" || {
        echo "Failed to load network-common.sh" >&2
        exit 1
    }
}

function linter() {
    # shellcheck source="../../lint/avahi-settings.lint"
    source "../../lint/avahi-settings.lint"
}

function run() {
    load_sources
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

    setup_reflector
    setup_ipv_reflector
    setup_ipv6
}

# Uses the template to regenerate the configuration file. Ensures a clean file.
function autoconf_config() {
    config=$(jq \
        --arg host_name "$host" \
        --arg AVAHI_USE_IPV6 "$AVAHI_USE_IPV6" \
        --arg AVAHI_REFLECTOR "$AVAHI_REFLECTOR_FLAG" \
        --arg AVAHI_REFLECTOR_IPV "$AVAHI_REFLECTOR_IPV" \
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
