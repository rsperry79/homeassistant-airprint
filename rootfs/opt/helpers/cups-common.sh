#!/command/with-contend bashio
# shellcheck disable=SC2181

# HA File paths
export real_cups_path=/config/cups

# CUPS paths
export cups_templates_path=/config/templates/cups
export cups_client_cfg=client.conf
export cups_daemon_cfg=cupsd.conf
export cups_files_cfg=cups-files.conf

# SSL
export ssl_dir=/config/cups/ssl
export ssl_owner="root"
export ssl_group="root"
export ssl_perms="770"
