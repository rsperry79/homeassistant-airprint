#!/command/with-contend bashio
# shellcheck disable=SC2181
export file_owner="root"
export file_group="root"
export file_perms="770"

export real_config_path=/config
export templates_path=/usr/templates
export lp_folder_group=lpadmin

# CUPS paths
# Folder paths
export real_cups_path=$real_config_path/cups

export cups_log_path=$real_cups_path/logs
export cups_ssl_path=$real_cups_path/ssl
export cups_templates_path=$real_cups_path/templates

export src_cups_templates_path=$templates_path/cups
export cups_client_cfg=client.conf.tempio
export cups_daemon_cfg=cupsd.conf.tempio
export cups_files_cfg=cups-files.conf.tempio

export cups_client_cfg=client.conf
export cups_daemon_cfg=cupsd.conf
export cups_files_cfg=cups-files.conf

# Avahi
export avahi_config_path=$real_config_path/avahi
export avahi_services_path=$real_config_path/avahi/services
export avahi_templates_path=$templates_path/avahi
export src_avahi_templates_path=$src_avahi_templates_path/avahi

export avahi_daemon_cfg=avahi-daemon.conf.tempio
export avahi_daemon_cfg=avahi-daemon.conf

export packages_path=/config/packages
export install_script=custom-install.sh
export src_custom_script_template_path=/usr/templates/scripts
