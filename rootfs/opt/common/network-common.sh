#!/command/with-contend bashio
# shellcheck disable=SC2181

function get_interfaces() {
    # gets all network interfaces with their broadcast addresses
    local bcast_interfaces=""
    local interfaces=()
    if ! bashio::config.has_value 'interfaces'; then

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
            if [ -n "$bcast_interfaces" ]; then
                bcast_interfaces+=",$interface"
                resolvectl mdns "$interface" >yes # enable resolved
            else
                bcast_interfaces=$interface
            fi
        done
    else
        # shellcheck disable=SC2178
        bcast_interfaces=$(bashio::config 'interfaces')
    fi

    echo "$bcast_interfaces"
}

function enable_resolved() {
    local interfaces_arr[]=${1}
    IFS=',' read -ra interfaces <<<"${interfaces_arr[@]}"
    for interface in "${interfaces[@]}"; do
        resolvectl mdns "$interface" yes
    done
}
