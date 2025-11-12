ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:8.1.4
# hadolint ignore=DL3006

FROM $BUILD_FROM AS builder

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# #ARG CUPS_VER="2.4.14"

WORKDIR /build

# Optimize APT for faster, smaller builds
RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99no-recomberends \
    && echo 'APT::Get::Clean "always";' >> /etc/apt/apt.conf.d/99auto-clean \
    && echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' >> /etc/apt/apt.conf.d/99auto-clean

# Update package list and upgrade existing packages
RUN apt update -y && apt upgrade --fix-missing -y

RUN apt update \
    && apt upgrade -y --no-install-recommends \
    && apt install -y --no-install-recommends \
        # dev
        autoconf \
        build-essential \
        libnss-mdns \
        libavahi-client-dev \
        libkrb5-dev \
        libpam-dev \
        libssl-dev \
        libusb-1.0-0-dev \
        zlib1g-dev

ARG cups_url="https://github.com/OpenPrinting/cups/releases/download/v2.4.14/cups-2.4.14-source.tar.gz"

RUN curl -fsSL "${cups_url}" | tar xzf - || { echo "Download or extraction failed"; exit 1; } \
    && cd "cups-2.4.14"

COPY /src/dev.sh dev.sh
RUN chmod +x /dev.sh

#\
#     && make distclean \
#     && ./configure --sysconfdir=/config/cups \
#     --localstatedir=/run \
#     --with-components=all \
#     --enable-libpaper=yes \
#     --enable-debug-printfs=yes \
#     --enable-libpaper=yes \
#     --enable-tcp-wrappers=yes \
#     --enable-webif=yes \
#     --with-dnssd=avahi  \
#     --with-local-protocols=all
#     --with-tls=openssl \
#     --with-log-level=debug \
#     --with-access-log-level=all  \
#     --with-cups-user=lp  \
#     --with-cups-group=lp \
#     --with-system-groups=lpadmin \
#    && make all \
#    && make deb

# FROM $BUILD_FROM AS prod

# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99no-recommends \
#     && echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99no-recomberends \
#     && echo 'APT::Get::Clean "always";' >> /etc/apt/apt.conf.d/99auto-clean \
#     && echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' >> /etc/apt/apt.conf.d/99auto-clean

# # Update package list and upgrade existing packages
# RUN apt update -y && apt upgrade --fix-missing -y

# ENV \
#     DEBIAN_FRONTEND="noninteractive" \
#     PATH="/lib64:${PATH}" \
#     CUPS_DEBUG_LOG=- \
#     CUPS_DEBUG_LEVEL=0

# # Install packages
# RUN apt update \
#     && apt upgrade -y --no-install-recommends \
#     && apt install -y --no-install-recommends \
#         # debug
#         htop \
#         # System packages
#         sudo \
#         locales \
#         whois \
#         bash-completion \
#         procps \
#         lsb-release \
#         nano \
#         gnupg2 \
#         inotify-tools \
#         libssl-dev \
#         openssl \
#         # Avahi
#         avahi-daemon \
#         avahi-utils \
#         # CUPS printing packages
#         cups-backend-bjnp \
#         bluez-cups \
#         cups-browsed \
#         cups-filters \
#         \
#         ipp-usb \
#         cups-pk-helper\
#         # cups-pdf \
#         colord \
#         python3-cups \
#         pyppd \
#         rasterview \
#         # Network
#         dbus \
#         iproute2 \
#         libnss-mdns \
#         net-tools \
#         samba \
#         samba-client \
#         wget \
#         curl \
#         # systemd-resolved \

#         # Printer Drivers
#         foomatic-db-compressed-ppds \
#         hp-ppd  \
#         openprinting-ppds \
#         printer-driver-hpcups \
#         printer-driver-all \
#         printer-driver-brlaser \
#         printer-driver-escpr \
#         printer-driver-foo2zjs \
#         printer-driver-gutenprint \
#         printer-driver-splix \
#     && apt clean -y \
#     && rm -rf /var/lib/apt/lists/*


# COPY services /etc/s6-overlay/s6-rc.d
# COPY src /opt
# COPY templates /usr/templates


# RUN chmod +x /opt/*/*.sh /opt/entry.sh /etc/s6-overlay/s6-rc.d/*/run
# # Disable sudo password checking add root

#  RUN sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers \
#     && usermod -a -G lp root \
#     && usermod -a -G lpadmin root \
#     && useradd -g lpadmin lpadmin

LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"


# CMD ["/opt/entry.sh"]
CMD ["/dev.sh"]
