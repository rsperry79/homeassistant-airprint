#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

function update_private_key() {
    local private_key=${1}
    sed -i "s#^.*ServerKey .*#ServerKey ${private_key}#" "$real_cups_path/$cups_files"

}

function update_public_key() {
    local public_key=${1}
    sed -i "s#^.*ServerCertificate .*#ServerCertificate ${public_key}#" "$real_cups_path/$cups_files"
}

function update_self_sign() {
    local self_sign_setting=${1}
    sed -i "s#^.*CreateSelfSignedCerts .*#CreateSelfSignedCerts ${self_sign_setting}#" "$real_cups_path/$cups_files"
}

function update_access_log_level() {
    local setting=${1}
    sed -i "s#^.*AccessLogLevel .*#AccessLogLevel ${setting}#" "$real_cups_path/$cups_files"
}

function update_log_level() {
    local setting=${1}
    sed -i "s/^.*LogLevel .*/LogLevel ${setting}/" "$real_cups_path/$cups_daemon"

}

function update_server_alias() {
    local setting=${1}
    sed -i "s/^.*ServerAlias .*/ServerAlias ${setting}/" "$real_cups_path/$cups_daemon"
}

function update_server_name() {
    local setting=${1}
    sed -i "s/^.*ServerName .*/ServerName ${setting}/" "$real_cups_path/$cups_daemon"
    sed -i "s/^.*ServerName .*/ServerName ${setting}:631/" "$real_cups_path/$cups_client"
}
