ARG BUILD_FROM=ghcr.io/hassio-addons/ubuntu-base:10.0.10
#ARG CUPS_VER="2.4.14"
#FROM $BUILD_FROM AS builder

# # Update package list and upgrade existing packages
# RUN apt update -y && apt upgrade --fix-missing -y

# # Install required dependencies for CUPS
# RUN apt install -y autoconf build-essential \
#     avahi-daemon libavahi-client-dev \
#     libkrb5-dev libnss-mdns libpam-dev libssl-dev \
#     libsystemd-dev libusb-1.0-0-dev zlib1g-dev \
#     openssl sudo tar curl

# # Build latest cups as debian is out of date
# WORKDIR /build
# WORKDIR /config/cups
# WORKDIR /root/cups

# ARG cups_url="https://github.com/OpenPrinting/cups/releases/download/v2.4.14/cups-2.4.14-source.tar.gz"
# RUN curl -fsSL "${cups_url}" | tar xzf - || { echo "Download or extraction failed"; exit 1; } \
#     && cd "cups-2.4.14" \
#     && ./configure --prefix=/build/usr --sysconfdir=/config/cups --localstatedir=/var  --enable-libpaper=yes --with-components=all --with-tls=openssl  --enable-static=yes \
#     --enable-libpaper=yes --enable-tcp-wrappers=yes --enable-webif=yes --with-dnssd=yes  --with-local-protocols=all --with-rcdir=/build/rc  --with-systemd=/build/systemd \
#     && make clean && make && make install

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
        libavahi-client-dev \
        libkrb5-dev \
        libpam-dev \
        libusb-1.0-0-dev \
        zlib1g-dev \
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
        libssl-dev \
        openssl \
        # Avahi
        avahi-daemon \
        avahi-utils \
        # CUPS printing packages
        cups \
        cups-backend-bjnp \
        bluez-cups \
        cups-browsed \
        cups-filters \
        cups-ipp-utils \
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
        # systemd-resolved \

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
# COPY --from=builder /build /build
# COPY --from=builder /config/cups /build/config

# COPY --from=builder /build/usr/include /usr/include
# COPY --from=builder /build/usr/share /usr/share

# COPY --from=builder /build/usr/bin /bin
# COPY --from=builder /build/usr/sbin /sbin

# COPY --from=builder /build/usr/lib /lib
# COPY --from=builder /build/usr/lib64 /lib64

COPY services /etc/s6-overlay/s6-rc.d
COPY src /opt
COPY templates /usr/templates
RUN chmod +x /opt/*/*.sh /opt/entry.sh /etc/s6-overlay/s6-rc.d/*/run

# Set MDNS
#RUN sed -i "s/^.*MulticastDNS .*/MulticastDNS=yes/" /etc/systemd/resolved.conf

# Disable sudo password checking
RUN sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers
  #  && usermod -a -G lp root \
 #   && groupadd lpadmin


 # TODO add lpadmin user.

CMD ["/opt/entry.sh"]
