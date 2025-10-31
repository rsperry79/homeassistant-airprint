#!/command/with-contend bashio
# This script is ran on boot before avahi and cups.

function run() {
    bashio::log.info "Running Custom install script"
    apt update && apt upgrade -y
    install
}

function install() {
    cd /config/packages || exit 1
    mkdir -p /var/spool/lpd/

    # if [ ! -e mfc9970cdwlpr-1.1.1-5.i386.deb ]; then
    #     wget https://download.brother.com/welcome/dlf006526/mfc9970cdwlpr-1.1.1-5.i386.deb
    # fi
    # dpkg -i --force-all mfc9970cdwcupswrapper-1.1.1-5.i386.deb

    if [ ! -e mfc9970cdwlpr-1.1.1-5.i386.deb ]; then
        wget https://download.brother.com/welcome/dlf006528/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    fi
    dpkg -i --force-all mfc9970cdwcupswrapper-1.1.1-5.i386.deb
}

install
