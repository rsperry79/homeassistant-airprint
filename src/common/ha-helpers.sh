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

        if yq . "${ha_config_file}" >/dev/null; then
            # https://www.home-assistant.io/integrations/http/#http-configuration-variables

            # ha_ssl_key=$(yq ".http.ssl_key // ${ha_ssl_key}" "${ha_config_file}")
            # ha_ssl_certificate=$(yq ".http.ssl_certificate // ${ha_ssl_certificate}" "${ha_config_file}")

            # bashio::log.info "ha_ssl_key: ${ha_ssl_key}"
            # bashio::log.info "ha_ssl_certificate: ${ha_ssl_certificate}"

            # export ha_ssl_key
            # export ha_ssl_certificate
            true

        else
            bashio::log.warning "Unable to parse Home Assistant configuration file at ${ha_config_file}, assuming port ${ha_port} and no SSL"
        fi
    fi

}

# returns a bool
function ha_is_secure() {
    if yq . "${ha_config_file}" >/dev/null; then
        # https://www.home-assistant.io/integrations/http/#http-configuration-variables
        ha_ssl=$(yq '.http | (has("ssl_certificate") and has("ssl_key"))' "${ha_config_file}")
    else
        bashio::log.warning "Unable to parse Home Assistant configuration file at ${ha_config_file}, assuming port ${ha_port} and no SSL"
    fi

    if bashio::var.true "${ha_ssl}"; then
        echo true
    else
        echo false
    fi
}
