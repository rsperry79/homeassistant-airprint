#!/command/with-contend bashio
# shellcheck disable=SC2181
# shellcheck source="../../common/paths/nginx-paths.sh"
source "/opt/common/paths/nginx-paths.sh"

# shellcheck source="../../common/settings/nginx-settings.sh"
source "/opt/common/settings/nginx-settings.sh"


function update_error_log() {
    local location=${1}
    local level=${2}

    bashio::log.debug update_log_level
    if [ -e "$nginx_config_path/$nginx_conf" ]; then
        sed -i "s#^.*error_log .*#error_log ${location} ${level};#" "$nginx_config_path/$nginx_conf"
    fi
}

function update_access_log() {
    local location=${1}

    bashio::log.debug update_log_level
    if [ -e "$nginx_config_path/$nginx_conf" ]; then
        sed -i "s#^.*access_log .*#access_log ${location};#" "$nginx_config_path/$nginx_conf"
    fi
}

function setup_error_logging () {
    if bashio::config.has_value 'NGINX_LOGGING.NGINX_ERROR_LOG_TO_FILE'; then
        log_to_file_flag=$(bashio::config 'NGINX_LOGGING.NGINX_ERROR_LOG_TO_FILE')
    else
        log_to_file_flag=$NGINX_DEFAULT_ERROR_LOG_TO_FILE
    fi

    NGINX_ERROR_LOG_LOCATION=stderr
    if [ "$log_to_file_flag" = "true" ]; then
        NGINX_ERROR_LOG_LOCATION=$nginx_log_path/nginx.log
    fi

    export NGINX_ERROR_LOG_LOCATION
}


function setup_access_logging () {
    local log_to_file_flag
    if bashio::config.has_value 'NGINX_LOGGING.NGINX_ACCESS_LOG_TO_FILE'; then
        log_to_file_flag=$(bashio::config 'NGINX_LOGGING.NGINX_ACCESS_LOG_TO_FILE')
    else
        log_to_file_flag=$NGINX_DEFAULT_ACCESS_LOG_TO_FILE
    fi

    NGINX_ACCESS_LOG_LOCATION=stderr
    if [ "$log_to_file_flag" = "true" ]; then
        NGINX_ACCESS_LOG_LOCATION=$nginx_log_path/nginx.log
    fi

    export NGINX_ACCESS_LOG_LOCATION
}



function setup_error_log_level () {
    if bashio::config.has_value 'NGINX_LOGGING.nginx_log_level'; then
        NGINX_LOG_LEVEL_SETTING=$(bashio::config 'NGINX_LOGGING.nginx_log_level')
    else
        NGINX_LOG_LEVEL_SETTING=$NGINX_DEFAULT_LOG_LEVEL
    fi

    export NGINX_LOG_LEVEL_SETTING
}



