#!/command/with-contend bashio
# shellcheck disable=SC2181
export file_owner="root"
export file_group="root"
export file_perms="770"

export real_config_path=/config
export folder_group="root"

# CUPS paths
export real_cups_path=/config/cups
export cups_config_path=/config/cups
export src_cups_templates_path=/usr/templates/cups
export cups_log_path=/config/cups/logs
export cups_ssl_path=/config/cups/ssl
export cups_client_cfg=client.conf.tempio
export cups_daemon_cfg=cupsd.conf.tempio
export cups_files_cfg=cups-files.conf.tempio

export cups_templates_path=/config/templates/cups
export cups_client_cfg=client.conf
export cups_daemon_cfg=cupsd.conf
export cups_files_cfg=cups-files.conf

export cups_templates_path=/config/templates/cups

export lp_folder_group=lpadmin

# Avahi
export avahi_config_path=/config/avahi
export avahi_services_path=/config/avahi/services
export avahi_templates_path=/config/templates/avahi

export src_avahi_templates_path=/usr/templates/avahi
export avahi_daemon_cfg=avahi-daemon.conf.tempio
