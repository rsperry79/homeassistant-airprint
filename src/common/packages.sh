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
        packages=$(bashio::config 'custom_packages.packages')
        bashio::log.info "packages: $packages"

        # If debug, install one at a time
        if [ "$(bashio::config 'custom_packages.package_debug')" = true ]; then
            bashio::log.info "Installing custom packages one at a time"
            for package in $packages; do
                bashio::log.info "Installing $package"
                if [ -n "$package" ]; then
                    to_inst=("$package")
                    install_package "${to_inst[@]}"
                fi
            done
        # if not debug, install normally
        else
            bashio::log.info "Installing custom packages"
            to_inst=()
            for package in $packages; do
                if [ -n "$package" ]; then
                    bashio::log.info "Adding $package to install array"
                    to_inst+=("$package")
                fi
            done
            install_package "${to_inst[@]}"
        fi
    else
        bashio::log.info "No additional packages are listed for install."
    fi
}

function install_package() {
    local input=("$@")

    bashio::log.info "Installing Package(s): ${input[*]}"

    if [ "$(bashio::config 'custom_packages.install_recommends')" = false ]; then
        apt-get \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-confdef" \
            install "${input[@]}" --no-install-suggests -y ||
            bashio::"exit.nok" "Failed installing packages ${package}"
    else
        apt-get \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-confdef" \
            install "${input[@]}" --no-install-recommends --no-install-suggests -y ||
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
