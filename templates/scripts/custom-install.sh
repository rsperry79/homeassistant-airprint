#!/command/with-contenv bashio
# shellcheck disable=SC1091,SC2154
# This script is used to install custom packages and run custom scripts for the HomeAssistant Addon..
# All custom packages and scripts should be placed in the /config/packages directory.
export package_dir=/config/packages

# Loads a common set of bash functions to aid in installing packages.
# shellcheck source="./script-helpers.sh"
source "/config/packages/script-helpers.sh"

function run() {
    # bashio allows HomeAssistant to display the output of the script in the HomeAssistant logs among other benefits.
    # see <https://github.com/hassio-addons/bashio> for more information on bashio and how to use it.
    bashio::log.info "Running Custom install script"

    # Example of running a custom install script using bashio with a hard failure example. The script should be located in the /config/packages directory.
    bashio "$package_dir/example-sub-script.sh" || bashio::"exit.nok" "Failed to run custom install script"
}

setup_custom_install # located in script-helpers.sh
run
