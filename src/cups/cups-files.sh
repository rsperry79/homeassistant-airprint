#!/command/with-contend bashio
# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

# Cups config folder
if ! bashio::fs.directory_exists "${real_cups_path}"; then
    install -d -m "$svc_file_perms" -g "$svc_group" "${real_cups_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups config folder'
fi

# Cups log folder
if ! bashio::fs.directory_exists "${cups_log_path}"; then
    install -d -m "$svc_file_perms" -g "$svc_group" "${cups_log_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups logging folder'
fi

# cups templates folder
if ! bashio::fs.directory_exists "${cups_templates_path}"; then
    install -d -m "$svc_file_perms" -g "$svc_group" "${cups_templates_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups templates folder'
fi

# cups ssl folder
if ! bashio::fs.directory_exists "${cups_ssl_path}"; then
    install -d -m "$svc_file_perms" -g "$svc_group" "${cups_ssl_path}" ||
        bashio::exit.nok 'Failed to create a persistent cups templates folder'
fi

if [ ! -e "$cups_templates_path/$cups_client_cfg".tempio ]; then
    cp "$src_cups_templates_path/$cups_client_cfg" "$cups_templates_path/$cups_client_cfg"
fi

if [ ! -e "$cups_templates_path/$cups_daemon_cfg".tempio ]; then
    cp "$src_cups_templates_path/$cups_daemon_cfg" "$cups_templates_path/$cups_daemon_cfg"
fi

if [ ! -e "$cups_templates_path/$cups_files_cfg".tempio ]; then
    cp "$src_cups_templates_path/$cups_files_cfg" "$cups_templates_path/$cups_files_cfg"
fi
