#!/command/with-contend bashio
# Logging Defaults
export CUPS_DEFAULT_LOG_LEVEL="info"
export CUPS_DEFAULT_LOG_TO_FILE="false"
export CUPS_DEFAULT_FATAL_ERRORS="permissions"
export CUPS_DEFAULT_ACCESS_LOG_LEVEL="all"
export CUPS_DEFAULT_ACCESS_LOG_TO_FILE="false"

# SSL
export CUPS_DEFAULT_ENCRYPTION="IfRequested"

# SNMP
export CUPS_DEFAULT_SNMP_COMMUNITY="public"
export CUPS_DEFAULT_SNMP_ADDRESS="@LOCAL"
