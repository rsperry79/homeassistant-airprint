#!/command/with-contend bashio
# shellcheck disable=SC2181

function update_interfaces() {
    bcast_interfaces=$(get_interfaces)
    bashio::addon.option 'interfaces' "$bcast_interfaces"
}
