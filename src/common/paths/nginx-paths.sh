#!/command/with-contend bashio
# shellcheck disable=SC1091,SC2154

# shellcheck source="./base.sh"
source "/opt/common/paths/base.sh"

## Folder paths
# config folders
export nginx_config_path=$real_config_path/nginx
export nginx_log_path=$nginx_config_path/logs

# etc
export nginx_etc=/etc/nginx
export nginx_etc_sites=/etc/nginx/sites-available
export nginx_etc_enabled=/etc/nginx/sites-enabled/

# template folders
export src_nginx_templates_path=$templates_path/nginx
export nginx_templates_path=$nginx_config_path/templates

## File paths
# Template files
export nginx_default_cfg=cups.conf.tempio
export nginx_conf_cfg=nginx.conf.tempio

# Config files
export nginx_default=cups.conf
export nginx_conf=nginx.conf
