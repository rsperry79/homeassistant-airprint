ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:9.0.0

FROM $BUILD_FROM AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="/lib64:/usr/lib64:${PATH}" \
    CUPS_VER="2.4.10"

# Update package list and upgrade existing packages

RUN apt-get update \
    && apt-get upgrade --fix-missing -y --no-install-recommends \
    && apt-get install -y  --no-install-recommends \
        openssl=3.0* \
        cron=3.0* \
        avahi-daemon=0.8* \
        avahi-utils=0.8* \
        libfontconfig1=2.14* \
        automake=1:1.16* \
        autopoint=0.21* \
        autoconf=2.71* \
        clang=1:16* \
        gettext=0.21* \
        libtool=2.4* \
        libasprintf-dev=0.21* \
        libgettextpo-dev=0.21* \
        pkg-config=1.8* \
        gnulib-l10n=20220703* \
        build-essential=12.9* \
        epm=4.8* \
        libavahi-client-dev=0.8* \
        libkrb5-dev=1.20* \
        libpam-dev=1.5* \
        libssl-dev=3.0* \
        libsystemd-dev=252* \
        libusb-1.0-0-dev=2:1.0* \
        zlib1g-dev=1:1.2* \
        # drivers
        printer-driver-all=1.0* \
        foomatic-db=20231030* \
        foomatic-filters=4.0* \
        foomatic-filters-beh=4.0*

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
    CUPS_VER="2.4.10"

# Services
COPY services /etc/s6-overlay/s6-rc.d
# Misc Configs
COPY system-files /
# Core runtime scripts
COPY src /opt
# Config Templates
COPY templates /usr/templates

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
        htop=3.2* \
        cron=3.0* \
        dbus=1.14* \
        sudo=1.9* \
        locales=2.37* \
        bash-completion=1:2.11* \
        procps=2:4.0* \
        lsb-release=12.0* \
        nano=8.0* \
        inotify-tools=3.22* \
        bc=1.07* \
        udev=3.2* \
        yq=4.34* \
        # SSL
        ssl-cert=1.1* \
        openssl=3.0* \
        gnupg2=2.2* \
        # network
        avahi-daemon=0.8* \
        avahi-utils=0.8* \
        iproute2=6.1* \
        libnss-mdns=0.14* \
        net-tools=1.10* \
        wget=1.21* \
        curl=7.88* \
        whois=5.5* \
        # cups depends
        fontconfig-config=2.14* \
        libcairo2=1.16* \
        libfontconfig1=2.14* \
        libgpgmepp6t64=1.18* \
        libidn12=1.41* \
        liblcms2-2=2.14* \
        libnss3=2:3.89* \
        libpoppler-cpp2=22.12* \
        libtiff6=4.5* \
        libxau6=1:1.0* \
        libxext6=2:1.3* \
        fonts-dejavu-core=2.37* \
        libgs-common=10.0* \
        libijs-0.35=0.35* \
        liblerc4=4.0* \
        libopenjp2-7=2.5* \
        libusb-1.0-0=2:1.0* \
        libxcb-render0=1.15* \
        libxrender1=1:0.9* \
        x11-common=1:7.7* \
        fonts-dejavu-mono=2.37* \
        libcurl3t64-gnutls=7.88* \
        libfontenc1=1:1.1* \
        libgs10=10.0* \
        libjbig0=2.1* \
        libngtcp2-16=0.16* \
        libpaper2=1.1* \
        libqpdf30=11.3* \
        libwebp7=1.2* \
        libxcb-shm0=1.15* \
        libxt6t64=1:1.2* \
        xfonts-encodings=1:1.0* \
        fonts-urw-base35=20200219* \
        libdeflate0=1.18* \
        libfreetype6=2.12* \
        libgs10-common=10.0* \
        libjbig2dec0=0.19* \
        libngtcp2-crypto-gnutls8=0.16* \
        libpixman-1-0=0.42* \
        libsharpyuv0=1.2* \
        libx11-6=2:1.8* \
        libxcb1=1.15* \
        poppler-data=0.4* \
        poppler-utils=22.12* \
        xfonts-utils=7.7* \
        ghostscript=10.0* \
        libexif12=0.6* \
        libgpgme11t64=1.18* \
        libice6=2:1.0* \
        libjpeg62-turbo=1:2.1* \
        libnspr4=2:4.35* \
        libpng16-16t64=1.6* \
        libsm6=2:1.2* \
        libx11-data=2:1.8* \
        libxdmcp6=1:1.1* \
        docx2txt=0.0* \
        colord=1.4* \
        fonts-freefont-otf=20120503* \
        fonts-texgyre=20160102* \
        liblcms2-utils=2.14* \
        antiword=0.37* \
        imagemagick=8:6.9* \
        fonts-freefont-ttf=20120503* \
        gpg-wks-client=2.2* \
        fonts-droid-fallback=1:6.0* \
        libpaper-utils=1.1* \
        rasterview=1.0* \
        libcupsfilters2=1.28* \
        # build
        build-essential=12.9* \
        # helpers
        nginx=1.24* \
    && rm -rf /var/lib/apt/lists/*

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
    && useradd lpinfo -g lp \
    && usermod -aG root _apt

LABEL io.hass.version="1.0" io.hass.type="addon" io.hass.arch="aarch64|amd64"
WORKDIR /config
CMD ["/opt/entry.sh"]
#CMD ["tail", "-f", "/dev/null"]
