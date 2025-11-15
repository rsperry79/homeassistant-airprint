ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:8.1.4

#######################
##      BUILD       ###
#######################

FROM $BUILD_FROM AS builder
# hadolint ignore=DL3006

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV \
    DEBIAN_FRONTEND="noninteractive" \
    PATH="/lib64:${PATH}" \
    CUPS_DEBUG_LOG=- \
    CUPS_DEBUG_LEVEL=0 \
    CUPS_VER="2.4.14"

# Optimize APT for faster, smaller builds
RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Get::Clean "always";' >> /etc/apt/apt.conf.d/99auto-clean \
    && echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' >> /etc/apt/apt.conf.d/99auto-clean

# hadolint ignore=DL3008
RUN apt-get update \
    &&  apt-get  upgrade --fix-missing -y --no-install-recommends \
    && apt-get install -y  --no-install-recommends \
        autoconf \
        avahi-daemon \
        build-essential \
        epm \
        libnss-mdns \
        libavahi-client-dev \
        libkrb5-dev \
        libpam-dev \
        libssl-dev \
        libsystemd-dev \
        libusb-1.0-0-dev \
        pkg-config \
        zlib1g-dev

# files to copy in prod
WORKDIR /build/all
# the build src folder
WORKDIR /cups

# Get latest stable Cups
ARG cups_url="https://github.com/OpenPrinting/cups/releases/download/v${CUPS_VER}/cups-${CUPS_VER}-source.tar.gz"
RUN curl -fsSL "${cups_url}" | tar xzf - || { echo "Download or extraction failed"; exit 1; }
WORKDIR /cups/cups-${CUPS_VER}
RUN ./configure \
            --sysconfdir=/config \
            --runstatedir=/run \
            --with-components=all \
            --enable-debug \
            --enable-debug-printfs \
            --enable-libpaper \
            --with-dbusdir=/etc/dbus-1/system.d \
            --with-dnssd=avahi  \
            --with-local-protocols=all \
            --with-tls=openssl \
            --with-logdir=stderr \
            --with-cups-user=lp  \
            --with-cups-group=lp \
            --with-system-groups=lpadmin \
        && make clean \
        && make all \
        && make deb \
        &&  tar --skip-old-files -xzf ./dist/*.tgz  --directory /build/all \
        && cp /build/all/cups-${CUPS_VER}* /build


          # --with-ondemand=systemd \
#######################
##      PROD        ###
#######################
FROM $BUILD_FROM AS prod
# hadolint ignore=DL3006

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV \
    DEBIAN_FRONTEND="noninteractive" \
    PATH="/lib64:${PATH}" \
    CUPS_DEBUG_LOG=- \
    CUPS_DEBUG_LEVEL=0 \
    CUPS_VER="2.4.14"

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Get::Clean "always";' >> /etc/apt/apt.conf.d/99auto-clean \
    && echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' >> /etc/apt/apt.conf.d/99auto-clean

# Update package list and upgrade existing packages
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get upgrade --fix-missing -y --no-install-recommends \
    && apt-get install -y  --no-install-recommends \
        # debug
        htop \
        # System packages
        sudo \
        locales \
        bash-completion \
        procps \
        lsb-release \
        nano \
        gnupg2 \
        inotify-tools \
        openssl \
        cron \
        # Avahi
        avahi-daemon \
        avahi-utils \
        # CUPS printing packages
        cups-backend-bjnp \
        bluez-cups \
        cups-browsed \
        cups-filters \
        ipp-usb \
        colord \
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
        whois \
        # Printer Drivers
        foomatic-db-compressed-ppds \
        hp-ppd  \
        openprinting-ppds \
        printer-driver-hpcups \
        printer-driver-all \
        printer-driver-brlaser \
        printer-driver-escpr \
        printer-driver-foo2zjs \
        printer-driver-gutenprint \
        printer-driver-splix \
    && rm -rf /var/lib/apt/lists/*

# Copy and install build files
# workdir name is to distinguish from the packages folder used to install user-runtime packages/configs
WORKDIR /installers
COPY --from=builder /build /installers
RUN find /installers -type f -name "*.deb" -not -path /installer/all -exec bash -c 'for pkg; do dpkg -i "${pkg}"; done' _ {} +

# Copy services code
COPY services /etc/s6-overlay/s6-rc.d
# Misc configs
COPY system-files /
# the core scripts to run the server
COPY src /opt
# The config templates
COPY templates /usr/templates
# Enable scripts to run
RUN chmod +x /opt/*/*.sh /opt/entry.sh /etc/s6-overlay/s6-rc.d/*/run

# Disable sudo password checking add root
RUN sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers \
    && usermod -a -G lp root \
    && usermod -a -G lpadmin root \
    && useradd -g lpadmin lpadmin

LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"

CMD ["/opt/entry.sh"]
#CMD ["tail", "-f", "/dev/null"]

