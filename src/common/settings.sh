#!/command/with-contend bashio

# shellcheck source="./paths/common.sh"
source "/opt/common/paths/common.sh"

# shellcheck source="./paths/avahi-paths.sh"
source "/opt/common/paths/avahi-paths.sh"

# shellcheck source="./paths/cups-paths.sh"
source "/opt/common/paths/cups-paths.sh"

# shellcheck source="./paths/nginx-paths.sh"
source "/opt/common/paths/nginx-paths.sh"

### Homeassistant Paths
export ha_config_file="/homeassistant/configuration.yaml"

### Ports
export nginx_port=5150

### Svc Acct Settings
export svc_acct="lp"
export svc_group="lp"
export svc_file_perms="0640"
