#!/command/with-contend bashio

# shellcheck source="./paths.sh"
source "/opt/common/paths.sh"

function run_setup() {
    if ! bashio::fs.directory_exists "${real_config_path}"; then
        install -d -m "$svc_file_perms" -g "$svc_group" "${real_config_path}" ||
            bashio::exit.nok 'Failed to create a persistent cups logging folder'
    fi
}

run_setup
