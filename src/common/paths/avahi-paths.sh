#!/command/with-contend bashio

# shellcheck source="./base.sh"
source "/opt/common/paths/base.sh"

# Folder paths
export avahi_config_path=$real_config_path/avahi
export avahi_services_path=$avahi_config_path/services
export avahi_templates_path=$avahi_config_path/templates
export src_avahi_templates_path=$templates_path/avahi

# Template files
export avahi_daemon_cfg=avahi-daemon.conf.tempio

# Config files
export avahi_daemon=avahi-daemon.conf
