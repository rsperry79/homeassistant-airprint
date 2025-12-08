#!/command/with-contend bashio

# shellcheck source="./base.sh"
source "/opt/common/paths/base.sh"

# Folder paths
export real_cups_path=$real_config_path/cups
export cups_log_path=$real_cups_path/logs
export cups_ssl_path=$real_cups_path/ssl
export cups_templates_path=$real_cups_path/templates
export src_cups_templates_path=$templates_path/cups

# Template files
export cups_client_cfg=client.conf.tempio
export cups_daemon_cfg=cupsd.conf.tempio
export cups_files_cfg=cups-files.conf.tempio
export cups_browsed_cfg=cups-browsed.conf.tempio
export cups_pdf_cfg=cups-pdf.conf.tempio
export cups_snmp_cfg=snmp.conf.tempio

# Config files
export cups_client=client.conf
export cups_daemon=cupsd.conf
export cups_files=cups-files.conf
export cups_browsed=cups-browsed.conf
export cups_pdf=cups-pdf.conf
export cups_snmp=snmp.conf

#www
export cups_web_root=/usr/share/cups/www/
export cups_html_tempio=index.html.tempio
export cups_html=index.html
