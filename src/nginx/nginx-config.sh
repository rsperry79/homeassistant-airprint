#!/command/with-contend bashio

# shellcheck source="../common/paths/nginx-paths.sh"
source "/opt/common/paths/nginx-paths.sh"

# shellcheck source="./helpers/nginx-config-helpers.sh"
source "/opt/nginx/helpers/nginx-config-helpers.sh"

# shellcheck source="./helpers/nginx-ssl-helpers.sh"
source "/opt/nginx/helpers/nginx-ssl-helpers.sh"

# shellcheck source="../common/network-common.sh"
source "/opt/common/network-common.sh"

function run() {

    ingress=$(bashio::addon.ingress)
    bashio::log.info "ingress $ingress"

    ingress_entry=$(bashio::addon.ingress_entry)
    bashio::log.info "ingress_entry $ingress_entry"

    ingress_url=$(bashio::addon.ingress_url)
    bashio::log.info "ingress_url $ingress_url"

    ingress_port=$(bashio::addon.ingress_port)
    bashio::log.info "ingress_port $ingress_port"

    addon_name=$(bashio::addon.name)
    bashio::log.info "addon_name $addon_name"

    addon_url=$(bashio::addon.url)
    bashio::log.info "addon_url $addon_url"

    addon_hostname=$(bashio::addon.hostname)
    bashio::log.info "addon_hostname $addon_hostname"

    addon_dns=$(bashio::addon.dns)
    bashio::log.info "addon_dns $addon_dns"

    addon_repository=$(bashio::addon.repository)
    bashio::log.info "addon_repository $addon_repository"

    addon_ip_address=$(bashio::addon.ip_address)
    bashio::log.info "addon_ip_address $addon_ip_address"

    setup

    if [ ! -e "$nginx_config_path/$nginx_conf" ]; then
        autoconf_nginx_config
    else
        update_nginx_cfg
    fi

    if [ ! -e "$nginx_config_path/$nginx_default" ]; then
        autoconf_default_config
    else
        update_nginx_default
    fi

    replace_configs
}

function setup() {
    ingress_url=$(bashio::addon.ingress_url)

    nginx_log_to_file=$(bashio::config 'nginx.nginx_log_to_file')
    nginx_log_location=stderr
    if [ "$nginx_log_to_file" = "true" ]; then
        nginx_log_location=$nginx_log_path/nginx.log
    fi

    nginx_access_log_to_file=$(bashio::config 'nginx.nginx_access_log_to_file')
    nginx_access_log_location=stderr
    if [ "$nginx_access_log_to_file" = "true" ]; then
        nginx_access_log_location=$nginx_log_path/access.log
    fi

    nginx_log_level=$(bashio::config 'nginx.nginx_log_level')

    nginx_ssl_certificate="" #"ssl_certificate {{.nginx_ssl_cert}};"
    nginx_ssl_key=""         #"ssl_certificate_key {{.nginx_ssl_key}};"

    config=$(jq \
        --arg host_name "$HOSTNAME" \
        --arg ingress_url "$ingress_url" \
        --arg nginx_log_location "$nginx_log_location" \
        --arg nginx_log_level "$nginx_log_level" \
        --arg nginx_access_log_location "$nginx_access_log_location" \
        --arg nginx_ssl_certificate "$nginx_ssl_certificate" \
        --arg nginx_ssl_key "$nginx_ssl_key" \
        '{
            host_name: $host_name,
            ingress_url: $ingress_url,
            nginx_log_location: $nginx_log_location,
            nginx_log_level: $nginx_log_level,
            nginx_access_log_location: $nginx_access_log_location,
            nginx_ssl_certificate: $nginx_ssl_certificate,
            nginx_ssl_key: $nginx_ssl_key
        }' \
        /data/options.json)
}

# Uses the template to regenerate the configuration file. Ensures a clean file.
function autoconf_nginx_config() {
    # nginx.conf
    echo "$config" | tempio \
        -template "$nginx_templates_path/$nginx_conf_cfg" \
        -out "$nginx_config_path/$nginx_conf"
}

function autoconf_default_config() {
    # default.conf
    echo "$config" | tempio \
        -template "$nginx_templates_path/$nginx_default_cfg" \
        -out "$nginx_config_path/$nginx_default"
}

function update_nginx_default() {

    true
}

function update_nginx_cfg() {
    update_error_log "$nginx_log_location" "$nginx_log_level"
    update_access_log "$nginx_access_log_location"
}

function replace_configs() {
    if [ -e "$nginx_etc/$nginx_conf" ]; then
        if [ ! -L "$nginx_etc/$nginx_conf" ]; then
            rm -f "$nginx_etc/$nginx_conf"
            ln -s "$nginx_config_path/$nginx_conf" "$nginx_etc/$nginx_conf"
        fi
    else
        ln -s "$nginx_config_path/$nginx_conf" "$nginx_etc/$nginx_conf"
    fi

    if [ -e "$nginx_etc_sites/$nginx_default" ]; then
        if [ ! -L "$nginx_etc_sites/$nginx_default" ]; then
            rm -f "$nginx_etc_sites/$nginx_default"
            ln -s "$nginx_config_path/$nginx_default" "$nginx_etc_sites/$nginx_default"
        fi
    else
        ln -s "$nginx_config_path/$nginx_default" "$nginx_etc_sites/$nginx_default"
    fi

    if [ -e "$nginx_etc_enabled/$nginx_default" ]; then
        if [ ! -L "$nginx_etc_enabled/$nginx_default" ]; then
            rm -f "$nginx_etc_enabled/$nginx_default"
            ln -s "$nginx_etc_sites/$nginx_default" "$nginx_etc_enabled"
        fi
    else
        ln -s "$nginx_etc_sites/$nginx_default" "$nginx_etc_enabled"
    fi
}

run
