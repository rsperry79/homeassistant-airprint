#!/command/with-contend bashio
# shellcheck source="../common/settings.sh"
source "/opt/common/settings.sh"

# shellcheck source="../common/paths/nginx-paths.sh"
source "/opt/common/paths/nginx-paths.sh"

# NGINX config folder
if ! bashio::fs.directory_exists "${nginx_config_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${nginx_config_path}" ||
        bashio::exit.nok 'Failed to create a persistent NGINX config folder'
fi

# NGINX templates folder
if ! bashio::fs.directory_exists "${nginx_templates_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${nginx_templates_path}" ||
        bashio::exit.nok 'Failed to create a persistent nginx templates folder'
fi

# NGINX log folder
if ! bashio::fs.directory_exists "${nginx_log_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${nginx_log_path}" ||
        bashio::exit.nok 'Failed to create a persistent nginx log folder'
fi

# nginx.conf
if [ ! -e "$nginx_templates_path/$nginx_conf_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_nginx_templates_path/$nginx_conf_cfg" "$nginx_templates_path" ||
        bashio::exit.nok "Failed to create $nginx_conf"
fi

# default.conf
if [ ! -e "$nginx_templates_path/$nginx_default_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_nginx_templates_path/$nginx_default_cfg" "$nginx_templates_path" ||
        bashio::exit.nok "Failed to create $nginx_default_cfg"
fi

