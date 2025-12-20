#!/command/with-contenv bashio
# shellcheck disable=SC1091,SC2154

# shellcheck source="./base.sh"
source "/opt/common/paths/base.sh"

export packages_path=/config/packages
export install_script=custom-install.sh
export example_subscript=example-sub-script.sh
export script_helpers=script-helpers.sh
export src_custom_script_template_path=$templates_path/scripts
