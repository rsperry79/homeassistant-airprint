#!/command/with-contend bashio

### Svc Acct Settings
export svc_acct="root"
export svc_group="root"
export svc_file_perms="777"

# Base Folders
export real_config_path=/config
export templates_path=/usr/templates

#### Common
export packages_path=/config/packages
export install_script=custom-install.sh
export src_custom_script_template_path=$templates_path/scripts

#### CUPS paths
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
# Config files
export cups_client=client.conf
export cups_daemon=cupsd.conf
export cups_files=cups-files.conf

#### Avahi
# Folder paths
export avahi_config_path=$real_config_path/avahi
export avahi_services_path=$avahi_config_path/services
export avahi_templates_path=$avahi_config_path/templates
export src_avahi_templates_path=$templates_path/avahi
# Template files
export avahi_daemon_cfg=avahi-daemon.conf.tempio
# Config files
export avahi_daemon=avahi-daemon.conf
