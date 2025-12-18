#!/command/with-contend bashio

# shellcheck source="../../common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

function setup_nginx_ssl () {

    if ha_is_secure; then
        nginx_proto="SSL"
        get_ha_certs
        nginx_ssl_cert="ssl_certificate $HA_SSL_CERT;"
        nginx_ssl_key="ssl_certificate_key $HA_SSL_KEY;"

    else
        nginx_proto=""
        nginx_ssl_cert=""
        nginx_ssl_key=""
    fi

    export nginx_proto
    export nginx_ssl_cert
    export nginx_ssl_key
}
