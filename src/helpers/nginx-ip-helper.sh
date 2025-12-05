#!/command/with-contend bashio
# shellcheck source="../common/paths.sh"
source "/opt/common/paths.sh"

# shellcheck disable=SC2181
echo "listen $(ip -o -4 a s docker0 | awk '{ print $4 }' | cut -d/ -f1):$nginx_port;" | tee /config/nginx/docker_ip
echo "listen $(ip -o -4 a s hassio | awk '{ print $4 }' | cut -d/ -f1):$nginx_port;" | tee /config/nginx/hassio_ip
