#!/command/with-contenv bashio
export package_dir=/config/packages

function run() {
    install_9970
}

# Install Brother MFC-9970 printer drivers
function install_9970() {
    cups_url=https://download.brother.com/welcome/dlf006528/mfc9970cdwcupswrapper-1.1.1-5.i386.deb
    lpr_url=https://download.brother.com/welcome/dlf006526/mfc9970cdwlpr-1.1.1-5.i386.deb

    mkdir -p /var/spool/lpd/
    # See ${package_dir}/install.sh for wget_install function
    wget_install "mfc9970cdwlpr.i386.deb" "$lpr_url" true
    wget_install "mfc9970cdwcupswrapper.i386.deb" "$cups_url" true
}

run
