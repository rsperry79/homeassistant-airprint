#!/command/with-contend bashio

# shellcheck source="./paths.sh"
source "/opt/common/paths.sh"

function run() {
    ensure_package_paths
    install_config_packages
    upgrade
}

# Packages folder
function ensure_package_paths() {
    if ! bashio::fs.directory_exists "${packages_path}"; then
        mkdir -p "${packages_path}" ||
            bashio::exit.nok 'Failed to create a persistent cups config folder'

        chmod 700 "${packages_path}" ||
            bashio::exit.nok \
                'Failed setting permissions on persistent cups config folder'
    fi

    if [ ! -e "$packages_path/$install_script" ]; then
        cp "$src_custom_script_template_path/$install_script" "$packages_path/$install_script"
    fi
}

# Install user configured/requested packages
function install_config_packages() {
    if bashio::config.has_value 'packages'; then
        apt update ||
            bashio::exit.nok 'Failed updating packages repository indexes'

        for package in $(bashio::config 'packages'); do
            apt-get install "$package" -y --no-install-recommends ||
                bashio::exit.nok "Failed installing package ${package}"
        done
    fi
}

function upgrade() {
    # TODO add if autoupdate
    if [ "$(bashio::addon.auto_update)" == "true" ]; then
        bashio::log.info "Running apt upgrade"
        apt update ||
            bashio::exit.nok 'Failed updating packages repository indexes'
        apt upgrade -y --no-install-recommends ||
            bashio::exit.nok "Failed to upgrade apt packages"
    fi
}


run
