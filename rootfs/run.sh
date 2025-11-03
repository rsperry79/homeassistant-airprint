#!/usr/bin/with-contenv bashio

ulimit -n 1048576

# Get all possible hostnames from configuration
bashio::log.info "ran run.sh"

exec /bin/bash
