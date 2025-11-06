ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:8.1.4
FROM $BUILD_FROM

LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND="noninteractive"

# Optimize APT for faster, smaller builds
RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Get::Clean "always";' >> /etc/apt/apt.conf.d/99auto-clean \
    && echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' >> /etc/apt/apt.conf.d/99auto-clean

RUN apt update \
    && apt upgrade -y --no-install-recommends \
    && apt install -y --no-install-recommends \
        # System packages
        sudo \
        locales \
        whois \
        bash-completion \
        procps \
        lsb-release \
        nano \
        gnupg2 \
        inotify-tools \
        # airprint generate requirements
        python3 \
        python3-pip \
        python3-venv \
        python3-libxml2 \
        libcups2-dev \
        # CUPS printing packages
        cups \
        cups-backend-bjnp \
        bluez-cups \
        cups-bsd \
        cups-browsed \
        cups-filters \
        cups-pk-helper\
        cups-pdf \
        colord \
        python3-cups \
        pyppd \
        rasterview \
        # Network
        dbus \
        iproute2 \
        libnss-mdns \
        net-tools \
        samba \
        samba-client \
        wget \
        curl \
        systemd-resolved \
        # Avahi
        avahi-daemon \
        avahi-utils \
        # Printer Drivers
        foomatic-db-compressed-ppds \
        hpijs-ppds \
        hp-ppd  \
        openprinting-ppds \
        printer-driver-hpcups \
        printer-driver-all \
        printer-driver-all-enforce \
        printer-driver-brlaser \
        printer-driver-escpr \
        printer-driver-foo2zjs \
        printer-driver-gutenprint \
        printer-driver-splix \
        # Sane
        sane \
        sane-airscan \
        sane-utils \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*


COPY rootfs /
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run  /run.sh #/opt/airprint/airprint-generate.py

RUN sed -i "s/^.*MulticastDNS .*/MulticastDNS=yes/" /etc/systemd/resolved.conf \
 && sed -i "s/^.*LLMNR .*/LLMNR=yes ${setting}/" /etc/systemd/resolved.conf


# disable sudo password checking
RUN sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

CMD ["/run.sh"]

