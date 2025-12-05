#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

readonly ha_config_file="/homeassistant/configuration.yaml"

# Config Items
export ha_protocol
export ha_port="8123"
export ha_ssl="false"

function get_ssl() {

    bashio::log.debug "Checking Home Assistant port and if SSL is used..."

    if ha_is_secure; then

        if yq . "${ha_config_file}" >/dev/null; then
            # https://www.home-assistant.io/integrations/http/#http-configuration-variables
            ha_port=$(yq ".http.server_port // ${ha_port}" "${ha_config_file}")
            ha_ssl=$(yq '.http | (has("ssl_certificate") and has("ssl_key"))' "${ha_config_file}")
        else
            bashio::log.warning "Unable to parse Home Assistant configuration file at ${ha_config_file}, assuming port ${ha_port} and no SSL"
        fi

        bashio::log.debug "ha_port: ${ha_port}"
        bashio::log.debug "ha_ssl: ${ha_ssl}"
    fi

    if bashio::var.true "${ha_ssl}"; then
        ha_protocol="https"
    else
        ha_protocol="http"
    fi
    bashio::log.info "ha_protocol: ${ha_protocol}"

}

get_ha_certs
