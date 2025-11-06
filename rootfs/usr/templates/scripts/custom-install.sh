#!/command/with-contend bashio
# This script is ran on boot before avahi and cups.
readonly package_dir=/config/packages

function run() {
    bashio::log.info "Running Custom install script"
    # apt update && apt upgrade -y
    install
}

function install() {
    cd "$package_dir" || exit 1
    mkdir -p /var/spool/lpd/
    # check if dl'd to speed up boot
    if [ ! -e mfc9970cdwlpr-1.1.1-5.i386.deb ]; then
        wget https://download.brother.com/welcome/dlf006526/mfc9970cdwlpr-1.1.1-5.i386.deb -O "$package_dir"/mfc9970cdwlpr-1.1.1-5.i386.deb
    fi
    # second check to ensure it was dl'd before install to prevent fatal errors
    if [ -e "$package_dir"/mfc9970cdwlpr-1.1.1-5.i386.deb ]; then
        # force all as brother only supplies a 386 package.
        dpkg -i --force-all "$package_dir"/mfc9970cdwlpr-1.1.1-5.i386.deb
    fi

    if [ ! -e mfc9970cdwcupswrapper-1.1.1-5.i386.deb ]; then
        wget https://download.brother.com/welcome/dlf006528/mfc9970cdwcupswrapper-1.1.1-5.i386.deb -O "$package_dir"/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    fi
    if [ -e "$package_dir"/mfc9970cdwcupswrapper-1.1.1-5.i386.deb ]; then
        dpkg -i --force-all /config/packages/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    else
        bashio::log.notice "Cups wrapper was not present"
    fi

}

install
