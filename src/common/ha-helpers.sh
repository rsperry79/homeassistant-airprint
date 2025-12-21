#!/command/with-contend bashio
# shellcheck disable=SC1091
# shellcheck disable=SC2181

# shellcheck source="../common/settings.sh"
source "/opt/common/settings.sh"

function update_interfaces() {
    bcast_interfaces=$(get_interfaces)
    bashio::addon.option 'interfaces' "$bcast_interfaces"
}

function get_ha_certs() {
    if [ "$(ha_is_secure)" == true ]; then

        # shellcheck disable=SC2154
        if yq . "${HA_CONFIG_PATH}" >/dev/null; then
            # https://www.home-assistant.io/integrations/http/#http-configuration-variables
            HA_SSL_KEY=$(yq ".http.ssl_key" "${HA_CONFIG_PATH}")
            HA_SSL_KEY=${HA_SSL_KEY//\"/} # remove double quotes
            HA_SSL_KEY=${HA_SSL_KEY//\'/} # remove single quotes

            HA_SSL_CERT=$(yq ".http.ssl_certificate" "${HA_CONFIG_PATH}")
            HA_SSL_CERT=${HA_SSL_CERT//\"/} # remove double quotes
            HA_SSL_CERT=${HA_SSL_CERT//\'/} # remove single quotes

            bashio::log.debug "HA_SSL_KEY: ${HA_SSL_KEY}"
            bashio::log.debug "HA_SSL_CERT: ${HA_SSL_CERT}"

            export HA_SSL_KEY
            export HA_SSL_CERT
        else
            bashio::log.warning "Unable to parse Home Assistant configuration file at ${HA_CONFIG_PATH}"
        fi
    fi
}

# returns a bool
function ha_is_secure() {
    ha_ssl="false"
    # shellcheck disable=SC2154
    if yq . "${HA_CONFIG_PATH}" >/dev/null; then
        # https://www.home-assistant.io/integrations/http/#http-configuration-variables
        ha_ssl=$(yq '.http | (has("ssl_certificate") and has("ssl_key"))' "${HA_CONFIG_PATH}")
    else
        bashio::log.warning "Unable to parse Home Assistant configuration file at ${HA_CONFIG_PATH} and no SSL"
    fi

    if bashio::var.true "${ha_ssl}"; then
        bashio::log.info "HA is in secure mode"
        echo true
    else
        bashio::log.info "HA is not in secure mode"
        echo false
    fi
}
