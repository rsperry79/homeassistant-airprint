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

        if [ "$(bashio::config 'system_settings.package_debug')" = true ]; then
            for package in $(bashio::config 'system_settings.packages'); do
                if [ "$(bashio::config 'system_settings.install_recommends')" = true ]; then

                    apt-get -o Dpkg::Options::="--force-confold" \
                        -o Dpkg::Options::="--force-confdef" \
                        install "$package" -y ||
                        bashio::exit.nok "Failed installing packages ${package}"
                else
                    apt-get -o Dpkg::Options::="--force-confold" \
                        -o Dpkg::Options::="--force-confdef" \
                        install "$package" -y --no-install-recommends ||
                        bashio::exit.nok "Failed installing packages ${package}"
                fi
            done

        else

            for package in $(bashio::config 'system_settings.packages'); do
                to_inst+=" $package"
            done
            bashio::log.info "Installing additional packages: $to_inst"

            if [ "$(bashio::config 'system_settings.install_recommends')" = true ]; then
                apt-get -o Dpkg::Options::="--force-confold" \
                    -o Dpkg::Options::="--force-confdef" \
                    install "$to_inst" -y ||
                    bashio::exit.nok "Failed installing packages ${package}"
            else
                apt-get -o Dpkg::Options::="--force-confold" \
                    -o Dpkg::Options::="--force-confdef" \
                    install "$to_inst" -y --no-install-recommends ||
                    bashio::exit.nok "Failed installing packages ${package}"
            fi
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
