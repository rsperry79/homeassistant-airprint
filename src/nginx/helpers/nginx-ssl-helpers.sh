#!/command/with-contenv bashio
# shellcheck disable=SC1091,SC2154

# shellcheck source="../../common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

function setup_nginx_ssl() {
    # if [ "$(ha_is_secure)" == true ]; then
    #     NGINX_PROTO="SSL"
    #     get_ha_certs
    #     nginx_ssl_cert="ssl_certificate $HA_SSL_CERT;"
    #     nginx_ssl_key="ssl_certificate_key $HA_SSL_KEY;"
    # else
    NGINX_PROTO=""
    nginx_ssl_cert=""
    nginx_ssl_key=""
    # fi

    export NGINX_PROTO
    export nginx_ssl_cert
    export nginx_ssl_key
}
