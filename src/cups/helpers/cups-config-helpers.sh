#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../../common/paths/cups-paths.sh"
source "/opt/common/paths/cups-paths.sh"

function disable_ssl_config() {
    bashio::log.debug disable_ssl_config
    if [ -e "$real_cups_path/$cups_files" ]; then
        sed -i "s/^.*ServerKeychain .*/#ServerKeychain /" "$real_cups_path/$cups_files"
    fi
}

function update_self_sign() {
    local self_sign_setting=${1}
    bashio::log.debug update_self_sign
    if [ -e "$real_cups_path/$cups_files" ]; then
        sed -i "s#^.*CreateSelfSignedCerts .*#CreateSelfSignedCerts ${self_sign_setting}#" "$real_cups_path/$cups_files"
    fi
}

function update_access_log_level() {
    local setting=${1}
    bashio::log.debug update_access_log_level
    if [ -e "$real_cups_path/$cups_files" ]; then
        sed -i "s#^.*AccessLogLevel .*#AccessLogLevel ${setting}#" "$real_cups_path/$cups_files"
    fi
}

function update_web_root() {
    local setting=${1}
    bashio::log.debug update_access_log_level
    if [ -e "$real_cups_path/$cups_files" ]; then
        sed -i "s#^.*DocumentRoot .*#DocumentRoot ${setting}/#" "$real_cups_path/$cups_files"
    fi
}

function update_log_level() {
    local setting=${1}
    bashio::log.debug update_log_level
    if [ -e "$real_cups_path/$cups_daemon" ]; then
        sed -i "s/^.*LogLevel .*/LogLevel ${setting}/" "$real_cups_path/$cups_daemon"
    fi
}

function update_access_log_location() {
    local setting=${1}
    bashio::log.debug update_log_level
    if [ -e "$real_cups_path/$cups_files" ]; then
        sed -i "s#^.*AccessLog .*#AccessLog ${setting}#" "$real_cups_path/$cups_files"
    fi
}

function update_log_location() {
    local setting=${1}
    bashio::log.debug update_log_level
    if [ -e "$real_cups_path/$cups_files" ]; then
        sed -i "s#^.*ErrorLog .*#ErrorLog ${setting}#" "$real_cups_path/$cups_files"
    fi
}

function update_server_alias() {
    local setting=${1}
    bashio::log.debug update_server_alias
    if [ -e "$real_cups_path/$cups_daemon" ]; then
        sed -i "s/^.*ServerAlias .*/ServerAlias ${setting}/" "$real_cups_path/$cups_daemon"
    fi
}

function update_server_name() {
    local setting=${1}
    bashio::log.debug update_server_name
    if [ -e "$real_cups_path/$cups_daemon" ]; then
        sed -i "s/^.*ServerName .*/ServerName ${setting}/" "$real_cups_path/$cups_daemon"
    fi
}
