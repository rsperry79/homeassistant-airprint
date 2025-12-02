#!/command/with-contend bashio
# This script is ran on boot before avahi and cups.
readonly package_dir=/config/packages

function run() {
    bashio::log.info "Running Custom install script"
    # apt update && apt upgrade -y
    install_9970
}

function install_9970() {
    cups_url=https://download.brother.com/welcome/dlf006528/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    lpr_url=https://download.brother.com/welcome/dlf006526/mfc9970cdwlpr-1.1.1-5.i386.deb

    mkdir -p /var/spool/lpd/
    get_install "mfc9970cdwlpr.i386.deb" "$lpr_url" true
    get_install "mfc9970cdwcupswrapper.i386.deb" "$cups_url" true
}

function install_cannon() {
    # Add Canon cnijfilter2 driver
    cd "$package_dir" || exit 1
    curl https://gdlp01.c-wss.com/gds/0/0100012300/02/cnijfilter2-6.80-1-deb.tar.gz -o cnijfilter2.tar.gz
    tar -xvf ./cnijfilter2.tar.gz cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_amd64.deb
    mv cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_amd64.deb cnijfilter2_6.80-1.deb
    apt install ./cnijfilter2_6.80-1.deb
}

function get_install() {
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

run
