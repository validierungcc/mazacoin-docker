#!/bin/bash

set -meuo pipefail

MAZA_DIR=/maza/.maza/
MAZA_CONF=/maza/.maza/maza.conf

if [ -z "${MAZA_RPCPASSWORD:-}" ]; then
  # Provide a random password.
  MAZA_RPCPASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 ; echo '')
fi

if [ ! -e "${MAZA_CONF}" ]; then
  tee -a >${MAZA_CONF} <<EOF
server=1
rpcuser=${MAZA_RPCUSER:-mazarpc}
rpcpassword=${MAZA_RPCPASSWORD}
rpcclienttimeout=${MAZA_RPCCLIENTTIMEOUT:-30}
EOF
echo "Created new configuration at ${MAZA_CONF}"
fi

if [ $# -eq 0 ]; then
  /usr/local/bin/mazad -rpcbind=0.0.0.0 -rpcport=12832 -rpcallowip=0.0.0.0/0 -printtoconsole=1
else
  exec "$@"
fi
