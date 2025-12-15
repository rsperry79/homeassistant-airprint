#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/settings.sh"
source "/opt/common/settings.sh"

function update_interfaces() {
    bcast_interfaces=$(get_interfaces)
    bashio::addon.option 'interfaces' "$bcast_interfaces"
}

function get_ha_certs() {

    if ha_is_secure; then

        if yq . "${HA_CONFIG_PATH}" >/dev/null; then
            # https://www.home-assistant.io/integrations/http/#http-configuration-variables
            ha_ssl_key=""
            ha_ssl_key=$(yq ".http.ssl_key // ${ha_ssl_key}" "${HA_CONFIG_PATH}")
            ha_ssl_certificate=""
            ha_ssl_certificate=$(yq ".http.ssl_certificate // ${ha_ssl_certificate}" "${HA_CONFIG_PATH}")

            bashio::log.info "ha_ssl_key: ${ha_ssl_key}"
            bashio::log.info "ha_ssl_certificate: ${ha_ssl_certificate}"

            export ha_ssl_key
            export ha_ssl_certificate

        else
            bashio::log.warning "Unable to parse Home Assistant configuration file at ${HA_CONFIG_PATH}"
        fi
    fi

}

# returns a bool
function ha_is_secure() {
    if yq . "${HA_CONFIG_PATH}" >/dev/null; then
        # https://www.home-assistant.io/integrations/http/#http-configuration-variables
        ha_ssl=$(yq '.http | (has("ssl_certificate") and has("ssl_key"))' "${HA_CONFIG_PATH}")
    else
        bashio::log.warning "Unable to parse Home Assistant configuration file at ${HA_CONFIG_PATH} and no SSL"
    fi

    if bashio::var.true "${ha_ssl}"; then
        echo true
    else
        echo false
    fi
}
