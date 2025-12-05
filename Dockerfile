ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:8.1.4

FROM $BUILD_FROM AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="/lib64:/usr/lib64:${PATH}" \
    CUPS_VER="2.4.14"

# Update package list and upgrade existing packages
# hadolint ignore=DL3008, DL3009
RUN apt-get update \
    && apt-get upgrade --fix-missing -y --no-install-recommends \
    && apt-get install -y  --no-install-recommends \
        openssl \
        cron \
        avahi-daemon \
        avahi-utils \
        libfontconfig1 \
        automake \
        autopoint \
        autoconf \
        clang \
        gettext \
        libtool\
        libasprintf-dev \
        libgettextpo-dev \
        pkg-config \
        gnulib-l10n \
        build-essential \
        epm \
        libavahi-client-dev \
        libkrb5-dev \
        libpam-dev \
        libssl-dev \
        libsystemd-dev \
        libusb-1.0-0-dev \
        pkg-config \
        zlib1g-dev

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
            --with-dnssd=avahi  \
            --with-local-protocols=all \
            --with-tls=openssl \
            --with-logdir=stderr \
            --with-cups-user=lp  \
            --with-cups-group=lp \
            --with-system-groups=lpadmin \
            --enable-webif \
            --with-ipp-port=631 \
        && make clean \
        && make all

FROM $BUILD_FROM AS prod

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="/lib64:/usr/lib64:${PATH}" \
    CUPS_VER="2.4.14"

# Services
COPY services /etc/s6-overlay/s6-rc.d
# Misc Configs
COPY system-files /
# Core runtime scripts
COPY src /opt
# Config Templates
COPY templates /usr/templates

# hadolint ignore=DL3008, DL3009
 RUN apt-get update \
    # Prevent Cups install via apt
    && apt-mark hold \
        cups \
        cups-daemon \
        cups-bsd \
        cups-client \
        cups-daemon \
        cups-common \
        cups-ipp-utils \
        cups-server-common \
    && apt-get full-upgrade --fix-missing -y --no-install-recommends --no-install-suggests  \
    && apt-get install -y  --no-install-recommends --no-install-suggests \
        # system tools
        htop \
        cron \
        dbus \
        sudo \
        locales \
        bash-completion \
        procps \
        lsb-release \
        nano \
        inotify-tools \
        bc \
        udev \
        yq \
        # SSL
        ssl-cert \
        openssl \
        gnupg2 \
        # network
        avahi-daemon \
        avahi-utils \
        iproute2 \
        libnss-mdns \
        net-tools \
        wget \
        curl \
        whois \
        # cups depends
        fontconfig-config \
        libcairo2 \
        libfontconfig1 \
        libgpgmepp6t64 \
        libidn12 \
        liblcms2-2 \
        libnss3 \
        libpoppler-cpp2 \
        libtiff6 \
        libxau6 \
        libxext6 \
        fonts-dejavu-core \
        libgs-common \
        libijs-0.35 \
        liblerc4 \
        libopenjp2-7 \
        libusb-1.0-0 \
        libxcb-render0 \
        libxrender1 \
        x11-common \
        fonts-dejavu-mono  \
        libcurl3t64-gnutls  \
        libfontenc1 \
        libgs10 \
        libjbig0 \
        libngtcp2-16 \
        libpaper2 \
        libqpdf30 \
        libwebp7 \
        libxcb-shm0 \
        libxt6t64 \
        xfonts-encodings \
        fonts-urw-base35 \
        libdeflate0 \
        libfreetype6 \
        libgs10-common \
        libjbig2dec0 \
        libngtcp2-crypto-gnutls8  \
        libpixman-1-0 \
        libsharpyuv0 \
        libx11-6 \
        libxcb1 \
        poppler-data \
        poppler-utils \
        xfonts-utils \
        ghostscript \
        libexif12 \
        libgpgme11t64 \
        libice6 \
        libjpeg62-turbo\
        libnspr4 \
        libpng16-16t64 \
        libsm6 \
        libx11-data \
        libxdmcp6 \
        docx2txt \
        colord \
        fonts-freefont-otf \
        fonts-texgyre \
        liblcms2-utils \
        antiword \
        imagemagick \
        fonts-freefont-ttf  \
        gpg-wks-client \
        fonts-droid-fallback \
        libpaper-utils\
        rasterview \
        libcupsfilters2 \
        # drivers
        foomatic-db \
        foomatic-filters \
        foomatic-filters-beh \
        # build
        build-essential \
        # helpers
        nginx

# RUN rm -f  /etc/nginx/nginx.conf \
#     rm -f  /etc/nginx/sites-available/default

# Copy Cups and install
COPY --from=builder /cups /cups
WORKDIR /cups/cups-${CUPS_VER}
RUN make install

# Remove build tools and clean
RUN apt-get remove -y build-essential \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable scripts to run & Disable sudo password checking add root
RUN chmod +x /opt/*/*.sh /opt/entry.sh /etc/s6-overlay/s6-rc.d/*/run \
    && sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers \
    && useradd  lpadmin \
    && usermod -aG lpadmin root \
    && usermod -aG sudo lpadmin \
    && usermod -aG lp root \
    && useradd  lp_service -g lp \
    && useradd  ColorManager \
    && usermod -aG lpadmin lp_service \
    &&  useradd lpinfo -g lp

LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"
WORKDIR /config
CMD ["/opt/entry.sh"]
#CMD ["tail", "-f", "/dev/null"]
