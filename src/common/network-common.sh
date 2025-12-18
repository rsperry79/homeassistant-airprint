#!/command/with-contend bashio
# shellcheck disable=SC2181

function get_ip_by_iface() {
    local interface=${1}

    ip_addr=$(ip addr show "$interface" | awk '/inet / {print $2}')
    echo "$ip_addr"
}

function get_interfaces() {
    # gets all network interfaces with their broadcast addresses
    local bcast_interfaces=""
    local interfaces=()

    bashio::log.debug "Config has no network interfaces listed.  Auto-finding interfaces"

    # Ensure 'ip' command exists
    if ! command -v ip &>/dev/null; then
        bashio::exit.nok "Error: 'ip' command not found. Please install iproute2."
    fi

    # Get interfaces with broadcast addresses
    while IFS= read -r line; do
        iface=$(awk '{print $2}' <<<"$line" | cut -d':' -f1)
        bcast=$(awk '{for(i=1;i<=NF;i++){if($i=="brd"){print $(i+1)}}}' <<<"$line")
        if [[ -n "$bcast" ]]; then
            interfaces+=("$iface")
        fi
    done < <(ip -o addr show | grep ' brd ')

    for item in "${interfaces[@]}"; do
        bashio::log.debug "Found ${item}"
    done

    for interface in "${interfaces[@]}"; do
        if [ "$interface" != "hassio" ] && [ "$interface" != "docker0" ]; then
            if [ -n "$bcast_interfaces" ]; then
                bcast_interfaces+=",$interface"
                bashio::log.info "Adding interface $interface"

            else
                bcast_interfaces=$interface
            fi
        fi
    done

    echo "$bcast_interfaces"
}
