#!/command/with-contend bashio
# shellcheck disable=SC1091,SC2154

# shellcheck source="../common/paths/cups-paths.sh"
source "/opt/common/paths/cups-paths.sh"

# shellcheck source="../common/settings.sh"
source "/opt/common/settings.sh"

# Cups config folder
if ! bashio::fs.directory_exists "${real_cups_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${real_cups_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups config folder'

    if [ -d /etc/cups ] && [ ! -h /etc/cups ]; then
        rm -rf /etc/cups
    fi
fi

ln -sn "$real_cups_path" /etc/cups

#Cups log folder
if ! bashio::fs.directory_exists "${cups_log_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${cups_log_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups logging folder'
fi

# cups templates folder
if ! bashio::fs.directory_exists "${cups_templates_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${cups_templates_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups templates folder'
fi

# cups ssl folder
if ! bashio::fs.directory_exists "${cups_ssl_path}"; then
    install -d -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "${cups_ssl_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups templates folder'
fi

# cups www folder
if ! bashio::fs.directory_exists "${cups_web_root}"; then
    install -d -m "$WWW_SVC_PERMS" -g "$SVC_GROUP" "${cups_web_root}" ||
        bashio::exit.nok 'Failed to create a persistent cups www folder'
    cp -ra "$cups_real_web_root/." "$cups_web_root"
    rm -f "$cups_web_root/$cups_html"
    chown root:root -R "$cups_web_root"
    chmod "$WWW_SVC_PERMS" -R "$cups_web_root"
fi

# client.conf
if [ ! -e "$cups_templates_path/$cups_client_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_cups_templates_path/$cups_client_cfg" "$cups_templates_path" ||
        bashio::exit.nok "Failed to create $cups_client_cfg"
fi

# cupsd.conf
if [ ! -e "$cups_templates_path/$cups_daemon_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_cups_templates_path/$cups_daemon_cfg" "$cups_templates_path" ||
        bashio::exit.nok "Failed to create $cups_daemon_cfg"

fi

# cups-files.conf
if [ ! -e "$cups_templates_path/$cups_files_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_cups_templates_path/$cups_files_cfg" "$cups_templates_path" ||
        bashio::exit.nok "Failed to create $cups_files_cfg"
fi

# cups-pdf.conf
if [ ! -e "$cups_templates_path/$cups_pdf_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_cups_templates_path/$cups_pdf_cfg" "$cups_templates_path" ||
        bashio::exit.nok "Failed to create $cups_pdf_cfg"
fi

# snmp.conf
if [ ! -e "$cups_templates_path/$cups_snmp_cfg" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_cups_templates_path/$cups_snmp_cfg" "$cups_templates_path" ||
        bashio::exit.nok "Failed to create $cups_snmp_cfg"
fi

# index.html
if [ ! -e "$cups_templates_path/$cups_html" ]; then
    install -m "$SVC_FILE_PERMS" -g "$SVC_GROUP" "$src_cups_templates_path/$cups_html_tempio" "$cups_templates_path" ||
        bashio::exit.nok "Failed to create $cups_html"
fi
