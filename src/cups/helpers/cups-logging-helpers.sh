#!/command/with-contend bashio
# shellcheck disable=SC2181

# shellcheck source="../../common/paths/cups-paths.sh"
source "/opt/common/paths/cups-paths.sh"

# shellcheck source="../../common/settings/cups-settings.sh"
source "/opt/common/settings/cups-settings.sh"

export CUPS_LOG_LEVEL
export CUPS_LOG_TO_FILE
export CUPS_FATAL_ERROR_LEVEL
export CUPS_ACCESS_LOG_TO_FILE
export CUPS_ACCESS_LOG_LEVEL

function setup_cups_logging () {
    # Error Logging
    set_cups_error_log_to_file
    set_cups_error_log_level

    # Error fatal level
    set_cups_fatal_error

    # Access Logging
    set_cups_access_log_to_file
    set_cups_access_log_level
 }

function set_cups_error_log_level () {
    if bashio::config.has_value 'CUPS_LOGGING.CUPS_LOG_LEVEL'; then
         CUPS_LOG_LEVEL=$(bashio::config 'CUPS_LOGGING.CUPS_LOG_LEVEL')
    else
        CUPS_LOG_LEVEL=$CUPS_DEFAULT_LOG_LEVEL
    fi
}

function set_cups_error_log_to_file () {
# Log Error to file setting
    if bashio::config.has_value 'CUPS_LOGGING.cups_log_to_file_setting'; then
        cups_log_to_file_setting=$(bashio::config 'CUPS_LOGGING.cups_log_to_file_setting')
    else
        cups_log_to_file_setting=$CUPS_DEFAULT_LOG_TO_FILE
    fi
    # Log Error to file
    if [ "$cups_log_to_file_setting" = "false" ]; then
        CUPS_LOG_TO_FILE=stderr
    else
        CUPS_LOG_TO_FILE=$cups_log_path/cups.log#
    fi
}

function set_cups_fatal_error () {
    if bashio::config.has_value 'CUPS_LOGGING.CUPS_FATAL_ERROR_LEVEL'; then
        CUPS_FATAL_ERROR_LEVEL=$(bashio::config 'CUPS_LOGGING.CUPS_FATAL_ERROR_LEVEL')
    else
        CUPS_FATAL_ERROR_LEVEL=$CUPS_DEFAULT_FATAL_ERRORS
    fi
}

function set_cups_access_log_to_file () {
    if bashio::config.has_value 'CUPS_LOGGING.CUPS_ACCESS_LOG_TO_FILE'; then
        cups_access_log_to_file_setting=$(bashio::config 'CUPS_LOGGING.CUPS_ACCESS_LOG_TO_FILE')
    else
        cups_access_log_to_file_setting=$CUPS_DEFAULT_ACCESS_LOG_TO_FILE
    fi

    if [ "$cups_access_log_to_file_setting" = "false" ]; then
        CUPS_ACCESS_LOG_TO_FILE=stderr
    else
        CUPS_ACCESS_LOG_TO_FILE=$cups_log_path/access.log
    fi
}

function set_cups_access_log_level () {
    if bashio::config.has_value 'CUPS_LOGGING.CUPS_ACCESS_LOG_LEVEL'; then
        CUPS_ACCESS_LOG_LEVEL=$(bashio::config 'CUPS_LOGGING.CUPS_ACCESS_LOG_LEVEL')
    else
        CUPS_ACCESS_LOG_LEVEL=$CUPS_DEFAULT_ACCESS_LOG_LEVEL
    fi
}
