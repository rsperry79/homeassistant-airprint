#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

# --arg host_name "$HOSTNAME" --arg nginx_log_level "$nginx_log_level" --arg nginx_log_to_file "$nginx_log_to_file"
#  --arg nginx_access_log_to_file "$nginx_access_log_to_file" --arg nginx_ssl_certificate "$nginx_ssl_certificate" --arg nginx_ssl_key "$nginx_ssl_key"

function update_error_log() {
    local location=${1}
    local level=${2}

    bashio::log.debug update_log_level
    if [ -e "$nginx_config_path/$nginx_conf" ]; then
        sed -i "s#^.*error_log .*#error_log ${location} ${level}#" "$nginx_config_path/$nginx_conf"
    fi
}

function update_access_log() {
    local location=${1}
    local level=${2}

    bashio::log.debug update_log_level
    if [ -e "$nginx_config_path/$nginx_conf" ]; then
        sed -i "s#^.*access_log .*#access_log ${location}#" "$nginx_config_path/$nginx_conf"
    fi
}

function update_server_alias() {
    local setting=${1}
    bashio::log.debug update_server_alias
    if [ -e "$real_cups_path/$cups_daemon" ]; then
        sed -i "s/^.*ServerAlias .*/ServerAlias ${setting}/" "$real_cups_path/$cups_daemon"
    fi
}
