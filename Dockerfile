ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:8.1.4
FROM $BUILD_FROM AS builder

# Update package list and upgrade existing packages
RUN apt update -y && apt upgrade --fix-missing -y

# Install required dependencies for CUPS
RUN apt install -y autoconf build-essential \
    avahi-daemon  git  libavahi-client-dev \
    libssl-dev libkrb5-dev libnss-mdns libpam-dev \
    libsystemd-dev libusb-1.0-0-dev zlib1g-dev \
    openssl  systemd-resolved sudo

# Build latest cups as debian is out of date
WORKDIR /root/cups
RUN git clone https://github.com/OpenPrinting/cups.git /root/cups

RUN ./configure --prefix=/root/usr --sysconfdir=/root/etc --localstatedir=/var  --enable-static=yes --enable-libpaper=yes \
 --enable-libpaper=yes --enable-tcp-wrappers=yes --enable-webif=yes --with-dnssd=yes  --with-local-protocols=all \
 && make clean && make && make install

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

# Install packages
RUN apt update \
    && apt upgrade -y --no-install-recommends \
    && apt install -y --no-install-recommends \
        # dev
        htop \
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
        # Avahi
        avahi-daemon \
        avahi-utils \
        # CUPS printing packages
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

        # Printer Drivers
        foomatic-db-compressed-ppds \
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

# Copy files, set perms
COPY --from=builder /root/etc /etc
COPY --from=builder /root/usr /usr
COPY services /etc/s6-overlay/s6-rc.d
COPY src /opt
COPY templates /usr/templates
RUN chmod +x /opt/*/*.sh /opt/entry.sh /etc/s6-overlay/s6-rc.d/*/run

# Set MDNS
RUN sed -i "s/^.*MulticastDNS .*/MulticastDNS=yes/" /etc/systemd/resolved.conf

# Disable sudo password checking
RUN sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers
  #  && usermod -a -G lp root \
 #   && groupadd lpadmin

CMD ["/opt/entry.sh"]
