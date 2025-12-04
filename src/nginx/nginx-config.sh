#!/command/with-contend bashio
# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

function run() {
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

    nginx_log_location=$(bashio::config 'nginx.nginx_log_location')
    if [ "$nginx_log_location" = "log_tab" ]; then
        nginx_log_location=stderr
    else
        nginx_log_location=$nginx_log_path/nginx.log
    fi

    nginx_access_log_location=$(bashio::config 'nginx.nginx_access_log_location')
    if [ "$nginx_access_log_location" = "log_tab" ]; then
        nginx_access_log_location=stderr
    else
        nginx_access_log_location=$nginx_log_path/access.log
    fi
    nginx_log_level=$(bashio::config 'nginx.nginx_log_level')

    nginx_ssl_certificate="" #"ssl_certificate {{.nginx_ssl_cert}};"
    nginx_ssl_key=""         #"ssl_certificate_key {{.nginx_ssl_key}};"

    config=$(jq --arg host_name "$HOSTNAME" --arg nginx_log_level "$nginx_log_level" --arg nginx_log_location "$nginx_log_location" --arg nginx_access_log_location "$nginx_access_log_location" --arg nginx_ssl_certificate "$nginx_ssl_certificate" --arg nginx_ssl_key "$nginx_ssl_key" \
        '{host_name: $host_name, nginx_log_level: $nginx_log_level, nginx_log_location: $nginx_log_location, nginx_access_log_location: $nginx_access_log_location, nginx_ssl_certificate: $nginx_ssl_certificate, nginx_ssl_key: $nginx_ssl_key}' \
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
    true
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
