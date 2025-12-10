#!/command/with-contend bashio

# shellcheck source="./paths/common-paths.sh"
source "/opt/common/paths/common-paths.sh"

# shellcheck source="./settings.sh"
source "/opt/common/settings.sh"

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
    if bashio::config.has_value 'custom_packages.packages'; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update ||
            bashio::exit.nok 'Failed updating packages repository indexes'

        # If debug, install one at a time
        if [ "$(bashio::config 'custom_packages.package_debug')" = true ]; then
            for package in $(bashio::config 'custom_packages.packages'); do
                install_package "$package"
            done
        # if not debug, install normally
        else
            bashio::log.info "Installing additional packages"
            packages="$(bashio::config 'custom_packages.packages')"
            to_inst=()
            for package in $(bashio::config 'custom_packages.packages'); do
                to_inst+=("$package")
            done

            if [ "$(bashio::config 'custom_packages.install_recommends')" = false ]; then
                apt-get \
                    -o Dpkg::Options::="--force-confold" \
                    -o Dpkg::Options::="--force-confdef" \
                    install "${to_inst[@]}" --no-install-suggests -y ||
                    bashio::"exit.nok" "Failed installing packages ${package}"
            else
                apt-get \
                    -o Dpkg::Options::="--force-confold" \
                    -o Dpkg::Options::="--force-confdef"
                install "${to_inst[@]}" --no-install-recommends --no-install-suggests -y ||
                    bashio::"exit.nok" "Failed installing packages ${package}"
            fi
        fi
    else
        bashio::log.info "No additional packages are listed for install."
    fi
}

function install_package() {
    local package=${1}

    if [ "$(bashio::config 'custom_packages.install_recommends')" = false ]; then
        apt-get \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-confdef" \
            install "$package" --no-install-suggests -y ||
            bashio::"exit.nok" "Failed installing packages ${package}"
    else
        apt-get \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-confdef"
        install "$package" --no-install-recommends --no-install-suggests -y ||
            bashio::"exit.nok" "Failed installing packages ${package}"
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
