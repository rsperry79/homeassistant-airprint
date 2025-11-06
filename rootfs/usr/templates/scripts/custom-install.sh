#!/command/with-contend bashio
# This script is ran on boot before avahi and cups.

function run() {
    bashio::log.info "Running Custom install script"
    # apt update && apt upgrade -y
    install
}

function install() {
    cd /config/packages || exit 1
    mkdir -p /var/spool/lpd/
    # check if dl'd to speed up boot
    if [ ! -e mfc9970cdwlpr-1.1.1-5.i386.deb ]; then
        wget https://download.brother.com/welcome/dlf006526/mfc9970cdwlpr-1.1.1-5.i386.deb -O /config/packages/mfc9970cdwlpr-1.1.1-5.i386.deb
    fi
    # second check to ensure it was dl'd before install to prevent fatal errors
    if [ -e /config/packages/mfc9970cdwlpr-1.1.1-5.i386.deb ]; then
        dpkg -i --force-all /config/packages/mfc9970cdwlpr-1.1.1-5.i386.deb # force all as brother only supplies a 386 package.
    fi

    if [ ! -e mfc9970cdwcupswrapper-1.1.1-5.i386.deb ]; then
        wget https://download.brother.com/welcome/dlf006528/mfc9970cdwcupswrapper-1.1.1-5.i386.deb -O /config/packages/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    fi
    if [ -e /config/packages/mfc9970cdwcupswrapper-1.1.1-5.i386.deb ]; then
        dpkg -i --force-all /config/packages/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    else
        bashio::log.notice "Cups wrapper was not present"
    fi

}

install
