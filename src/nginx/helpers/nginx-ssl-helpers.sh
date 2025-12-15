#!/command/with-contend bashio


# shellcheck source="../../common/ha-helpers.sh"
source "/opt/common/ha-helpers.sh"

function setup_nginx_ssl () {

    if ha_is_secure; then

        nginx_proto="SSL"

        if [ -n "$CUPS_PUBLIC_KEY" ]; then
            nginx_ssl_cert="ssl_certificate $CUPS_PUBLIC_KEY;"
            nginx_ssl_key="ssl_certificate_key $CUPS_PRIVATE_KEY;"
        else
            # NGINX SHOULD be dependant on cups starting so this block should not be used,
            # this is simply a fallback
            get_ha_certs
            nginx_ssl_cert="ssl_certificate $ha_ssl_certificate;"
            nginx_ssl_key="ssl_certificate_key $ha_ssl_key;"
        fi
    else
        nginx_proto=""
        nginx_ssl_cert=""
        nginx_ssl_key=""
    fi

    export nginx_proto
    export nginx_ssl_cert
    export nginx_ssl_key
}
