#!/command/with-contend bashio
# shellcheck disable=SC2181

# # shellcheck source="../common/settings.sh"
# source "/opt/common/settings.sh"

ingress_port=$(bashio::addon.ingress_port)

echo "listen $(ip -o -4 a s docker0 | awk '{ print $4 }' | cut -d/ -f1):$ingress_port;" | tee /config/nginx/docker_ip
echo "listen $(ip -o -4 a s hassio | awk '{ print $4 }' | cut -d/ -f1):$ingress_port;" | tee /config/nginx/hassio_ip
