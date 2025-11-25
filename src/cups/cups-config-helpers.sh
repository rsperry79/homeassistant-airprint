#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

function disable_ssl_config() {
    sed -i "s/^.*ServerKeychain .*/#ServerKeychain /" "$real_cups_path/$cups_files"
}

function update_self_sign() {
    local self_sign_setting=${1}
    bashio::log.debug update_self_sign
    sed -i "s#^.*CreateSelfSignedCerts .*#CreateSelfSignedCerts ${self_sign_setting}#" "$real_cups_path/$cups_files"
}

function update_access_log_level() {
    local setting=${1}
    bashio::log.debug update_access_log_level
    sed -i "s#^.*AccessLogLevel .*#AccessLogLevel ${setting}#" "$real_cups_path/$cups_files"
}

function update_log_level() {
    local setting=${1}
    bashio::log.debug update_log_level
    sed -i "s/^.*LogLevel .*/LogLevel ${setting}/" "$real_cups_path/$cups_daemon"

}

function update_server_alias() {
    local setting=${1}
    bashio::log.debug update_server_alias
    sed -i "s/^.*ServerAlias .*/ServerAlias ${setting}/" "$real_cups_path/$cups_daemon"
}

function update_server_name() {
    local setting=${1}
    bashio::log.debug update_server_name
    sed -i "s/^.*ServerName .*/ServerName ${setting}/" "$real_cups_path/$cups_daemon"
}
