#!/command/with-contend bashio
# shellcheck disable=SC1091,SC2154
# shellcheck source="../common/paths/avahi-paths.sh"
source "/opt/common/paths/avahi-paths.sh"

# shellcheck source="../common/settings.sh"
source "/opt/common/settings.sh"

# Avahi config folder
if ! bashio::fs.directory_exists "${avahi_config_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${avahi_config_path}" ||
        bashio::exit.nok 'Failed to create a persistent Avahi config folder'
fi

# Avahi services  folder
if ! bashio::fs.directory_exists "${avahi_services_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${avahi_services_path}" ||
        bashio::exit.nok 'Failed to create a persistent Avahi services folder'
fi

ln -sn "$avahi_services_path" /etc/avahi/services

# avahi templates folder
if ! bashio::fs.directory_exists "${avahi_templates_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${avahi_templates_path}" ||
        bashio::exit.nok 'Failed to create a persistent avahi templates folder'
fi

if [ ! -e "$avahi_templates_path/$avahi_daemon_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_avahi_templates_path/$avahi_daemon_cfg" "$avahi_templates_path" ||
        bashio::exit.nok "Failed to create $avahi_daemon_cfg"
fi
