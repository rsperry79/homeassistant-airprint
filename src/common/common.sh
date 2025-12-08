#!/command/with-contend bashio

# shellcheck source="./paths/base.sh"
source "/opt/common/paths/base.sh"

# shellcheck source="./settings.sh"
source "/opt/common/settings.sh"

apt_config_file
dbus_dir=/var/run/dbus
apt_cache_dir=/config/apt-cache/archives
apt_config_dir=/etc/apt/apt.conf.d
apt_config_file="99custom-cache-dir"

function run_setup() {
    # D-BUS dir
    if ! bashio::fs.directory_exists "$dbus_dir"; then
        install -d -m "root" -g "root" "${dbus_dir}" ||
            bashio::exit.nok 'Failed to create the dbus folder'
    fi

    # Apt-Cache dir
    if ! bashio::fs.directory_exists "$apt_cache_dir"; then
        install -d -m "root" -g "root" "${apt_cache_dir}" ||
            bashio::exit.nok 'Failed to create the apt-cache folder'
    fi

    # Apt config dir
    if ! bashio::fs.directory_exists "$apt_config_dir"; then
        install -d -m "root" -g "root" "${apt_config_dir}" ||
            bashio::exit.nok 'Failed to create the apt-config folder'
    fi

    # Apt config file
    if [ ! -e "$apt_config_dir/$apt_config_file" ]; then
        install -m "$svc_file_perms" -g "$svc_group" "$system_templates_path/$apt_config_file" "$apt_config_dir" ||
            bashio::exit.nok "Failed to create $apt_config_file"
    fi

    # Config folder
    if ! bashio::fs.directory_exists "${real_config_path}"; then
        install -d -m "$svc_file_perms" -g "$svc_group" "${real_config_path}" ||
            bashio::exit.nok 'Failed to create a persistent config folder'
    fi

}

run_setup
