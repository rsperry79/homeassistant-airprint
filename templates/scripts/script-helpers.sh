#!/command/with-contend bashio
readonly package_dir=/config/packages

function wget_install() {
    local name=${1}
    local url=${2}
    local force=${3:-false}

    cd "$package_dir" || exit 1

    file="$package_dir"/"$name"
    # check if dl'd to speed up boot
    if [ ! -e "$file" ]; then
        wget "$url" -O "$file"
    fi
    if [ -e "$file" ]; then
        if [ "$force" = true ]; then
            dpkg -i --force-all "$file" || rm -f "$file"
        else
            dpkg -i "$file" || rm -f "$file"
        fi
    else
        bashio::log.notice "Failed to install $file"
    fi
}

function setup_custom_install () {
    cd "$package_dir" || bashio::"exit.nok" "Failed to set working directory to $package_dir"
    # more custom setup could be added here ie;
    # apt_setup
}

function apt_setup () {
    bashio::log.debug "Setting up apt"
    apt-get update
}

