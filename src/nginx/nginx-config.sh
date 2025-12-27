#!/command/with-contend bashio
# shellcheck disable=SC1091,SC2154

function load_sources() {
    # shellcheck source="../common/paths/nginx-paths.sh"
    source "/opt/common/paths/nginx-paths.sh"

    # shellcheck source="../common/settings/nginx-settings.sh"
    source "/opt/common/settings/nginx-settings.sh"

    # shellcheck source="./helpers/nginx-config-helpers.sh"
    source "/opt/nginx/helpers/nginx-config-helpers.sh"

    # shellcheck source="./helpers/nginx-ssl-helpers.sh"
    source "/opt/nginx/helpers/nginx-ssl-helpers.sh"

    # shellcheck source="../common/network-common.sh"
    source "/opt/common/network-common.sh"
}

function linter() {
    # shellcheck source="../../lint/nginx-settings.lint"
    source "../../lint/nginx-settings.lint"
}

function run() {
    load_sources
    setup
    setup_autoconf

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
    ingress_entry=$(bashio::addon.ingress_entry)
    hassio_ip=$(bashio::addon.ip_address)
    ingress_port=$(bashio::addon.ingress_port)

    setup_nginx_logging
}

function setup_autoconf() {
    config=$(
        jq \
            --arg host_name "$HOSTNAME" \
            --arg ingress_entry "$ingress_entry" \
            --arg hassio_ip "$hassio_ip" \
            --arg ingress_port "$ingress_port" \
            --arg nginx_log_location "$NGINX_ERROR_LOG_LOCATION" \
            --arg nginx_log_level "$NGINX_LOG_LEVEL_SETTING" \
            --arg nginx_access_log_location "$NGINX_ACCESS_LOG_LOCATION" \
            '{
                host_name: $host_name,
                ingress_entry: $ingress_entry,
                hassio_ip: $hassio_ip,
                ingress_port: $ingress_port,
                nginx_log_location: $nginx_log_location,
                nginx_log_level: $nginx_log_level,
                nginx_access_log_location: $nginx_access_log_location
            }' /data/options.json
    )
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
    # TODO
    true
}

function update_nginx_cfg() {
    update_error_log "$NGINX_ERROR_LOG_LOCATION" "$NGINX_LOG_LEVEL_SETTING"
    update_access_log "$NGINX_ACCESS_LOG_LOCATION"
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
