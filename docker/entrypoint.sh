#!/bin/sh
set -eu

DATA_DIR="/data"
SECRET_FILE="${DATA_DIR}/secret"
CONFIG_DIR="/opt/MTProxy"
SECRET_SOURCE="${CONFIG_DIR}/proxy-secret"
MULTI_CONF="${CONFIG_DIR}/proxy-multi.conf"

PORT="${PORT:-443}"
WORKERS="${WORKERS:-1}"
TLS_DOMAIN="${TLS_DOMAIN:-}"

mkdir -p "${DATA_DIR}"

if [ ! -f "${SECRET_FILE}" ]; then
  head -c 16 /dev/urandom | xxd -p -c 32 > "${SECRET_FILE}"
  chmod 600 "${SECRET_FILE}"
fi

curl -fsSL https://core.telegram.org/getProxySecret -o "${SECRET_SOURCE}"
curl -fsSL https://core.telegram.org/getProxyConfig -o "${MULTI_CONF}"

SECRET="$(tr -d '\n\r' < "${SECRET_FILE}")"

echo "Starting MTProxy on port ${PORT}"
echo "Client secret: ${SECRET}"

if [ -n "${TLS_DOMAIN}" ]; then
  echo "Fake TLS enabled for domain: ${TLS_DOMAIN}"
  exec /opt/MTProxy/objs/bin/mtproto-proxy \
    -u nobody \
    -p 8888 \
    -H "${PORT}" \
    -S "${SECRET}" \
    -D "${TLS_DOMAIN}" \
    --aes-pwd "${SECRET_SOURCE}" "${MULTI_CONF}" \
    -M "${WORKERS}"
fi

exec /opt/MTProxy/objs/bin/mtproto-proxy \
  -u nobody \
  -p 8888 \
  -H "${PORT}" \
  -S "${SECRET}" \
  --aes-pwd "${SECRET_SOURCE}" "${MULTI_CONF}" \
  -M "${WORKERS}"
