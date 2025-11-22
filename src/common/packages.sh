#!/command/with-contend bashio

# shellcheck source="./paths.sh"
source "/opt/common/paths.sh"

function run() {
    ensure_package_paths
    upgrade
    install_config_packages
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
    if bashio::config.has_value 'system_settings.packages'; then
        export DEBIAN_FRONTEND=noninteractive
        apt update ||
            bashio::exit.nok 'Failed updating packages repository indexes'

        opts=""
        if [ "$(bashio::config 'system_settings.install_recommends')" = false ]; then
            opts="--no-install-recommends"
        fi

        # If debug, install one at a time
        if [ "$(bashio::config 'system_settings.package_debug')" = true ]; then
            for package in $(bashio::config 'system_settings.packages'); do
                apt-get -o Dpkg::Options::="--force-confold" \
                    -o Dpkg::Options::="--force-confdef" \
                    install "$package" -y "$opts" || bashio::exit.nok "Failed installing packages ${package}"
            done
        # if not debug, install normally
        else
            to_inst=""
            for package in $(bashio::config 'system_settings.packages'); do
                if [ -z "$to_inst" ]; then
                    to_inst+="$package"
                else
                    to_inst+=" $package"
                fi
            done

            bashio::log.info "Installing additional packages: $to_inst"

            apt-get -o Dpkg::Options::="--force-confold" \
                -o Dpkg::Options::="--force-confdef" \
                install "$to_inst" -y "$opts" ||
                bashio::"exit.nok" "Failed installing packages ${package}"
        fi
    else
        bashio::log.info "No additional packages are listed for install."
    fi
}

function upgrade() {
    if [ "$(bashio::addon.auto_update)" == "true" ]; then
        bashio::log.info "Running apt upgrade"
        apt update ||
            bashio::exit.nok 'Failed updating packages repository indexes'
        apt upgrade -y ||
            bashio::exit.nok "Failed to upgrade apt packages"
    fi
}

run
