#!/usr/bin/with-contenv bashio

ulimit -n 1048576

# Get all possible hostnames from configuration
result=$(bashio::api.supervisor GET /core/api/config true || true)
internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)
external=$(bashio::jq "$result" '.external_url' | cut -d'/' -f3 | cut -d':' -f1)

bashio::log.info "result $result\r\n"
bashio::log.info "Int $internal\r\n"
bashio::log.info "Ext $external"
