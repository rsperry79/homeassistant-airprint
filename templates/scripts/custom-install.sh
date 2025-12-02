#!/command/with-contend bashio
# This script is ran on boot before avahi and cups.
readonly package_dir=/config/packages

function run() {
    bashio::log.info "Running Custom install script"
    # apt update && apt upgrade -y
    install_9970
}

function install_9970() {
    cd "$package_dir" || exit 1
    mkdir -p /var/spool/lpd/
    # check if dl'd to speed up boot
    lpr_pkg="$package_dir"/mfc9970cdwlpr-1.1.1-5.i386.deb
    lpr_url=https://download.brother.com/welcome/dlf006526/mfc9970cdwlpr-1.1.1-5.i386.deb
    if [ ! -e "$lpr_pkg" ]; then
        wget "$lpr_url" -O "$lpr_pkg"
    fi
    # second check to ensure it was dl'd before install to prevent fatal errors
    if [ -e "$lpr_pkg" ]; then
        # force all as brother only supplies a 386 package.
        dpkg -i --force-all "$lpr_pkg" || rm -f "$lpr_pkg"
    fi

    cups_pkg="$package_dir"/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    cups_url=https://download.brother.com/welcome/dlf006528/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    if [ ! -e "$cups_pkg" ]; then
        wget "$cups_url" -O "$cups_pkg"
    fi
    if [ -e "$cups_pkg" ]; then
        dpkg -i --force-all "$cups_pkg" || rm -f e "$cups_pkg"
    else
        bashio::log.notice "Cups wrapper was not present"
    fi
}

function install_cannon() {
    # Add Canon cnijfilter2 driver
    cd "$package_dir" || exit 1
    curl https://gdlp01.c-wss.com/gds/0/0100012300/02/cnijfilter2-6.80-1-deb.tar.gz -o cnijfilter2.tar.gz
    tar -xvf ./cnijfilter2.tar.gz cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_amd64.deb
    mv cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_amd64.deb cnijfilter2_6.80-1.deb
    apt install ./cnijfilter2_6.80-1.deb
}

run
