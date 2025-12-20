#!/command/with-contend bashio

# shellcheck disable=SC1091,SC2154
# shellcheck source="./paths/common-paths.sh"
source "/opt/common/paths/common-paths.sh"

# shellcheck disable=SC1091
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

    if [ ! -e "$packages_path/$example_subscript" ]; then
        cp "$src_custom_script_template_path/$example_subscript" "$packages_path/$example_subscript"
    fi

    if [ ! -e "$packages_path/$script_helpers" ]; then
        cp "$src_custom_script_template_path/$script_helpers" "$packages_path/$script_helpers"
    fi
}

# Install user configured/requested packages
function install_config_packages() {
    if bashio::config.has_value 'CUSTOM_PACKAGES.PACKAGES'; then

        export DEBIAN_FRONTEND=noninteractive
        apt-get update ||
            bashio::exit.nok 'Failed updating packages repository indexes'
        packages=$(bashio::config 'CUSTOM_PACKAGES.PACKAGES')
        bashio::log.info "packages: $packages"

        # If debug, install one at a time
        if [ "$(bashio::config 'CUSTOM_PACKAGES.PACKAGE_DEBUG')" = true ]; then
            bashio::log.info "Installing custom packages one at a time"
            for package in $packages; do
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

    if [ "$(bashio::config 'CUSTOM_PACKAGES.INSTALL_RECOMMENDS')" = false ]; then
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
        apt-get update ||
            bashio::exit.nok 'Failed updating packages repository indexes'
        apt-get upgrade -y ||
            bashio::exit.nok "Failed to upgrade apt packages"
    fi
}

run
