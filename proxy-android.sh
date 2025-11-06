#!/usr/bin/env bash
# Uso:
#   proxy-android on        --> aplica a todos los dispositivos conectados
#   proxy-android off
#   proxy-android on -p 8081  # puerto opcional

set -euo pipefail

PORT=8080

# Parseo simple del puerto opcional: -p <puerto>
if [[ "${2:-}" == "-p" ]]; then
  if [[ -n "${3:-}" && "${3:-}" =~ ^[0-9]+$ ]]; then
    PORT="$3"
  else
    echo "[-] Debes indicar un puerto numérico después de -p" >&2
    exit 1
  fi
fi

PROXY="127.0.0.1:${PORT}"

need_adb() {
  command -v adb >/dev/null 2>&1 || {
    echo "[-] adb no está en el PATH. Instala Android Platform Tools." >&2
    exit 1
  }
}

list_connected_devices() {
  # Sólo estado "device" (excluye unauthorized/offline)
  adb devices | awk 'NR>1 && $2=="device"{print $1}'
}

enable_for_device() {
  local serial="$1"
  echo "[+] (${serial}) Activando proxy ${PROXY} ..."
  adb -s "$serial" reverse "tcp:${PORT}" "tcp:${PORT}" || true
  adb -s "$serial" reverse --list | grep -E "tcp:${PORT}\>" || true
  adb -s "$serial" shell settings put global http_proxy "${PROXY}"
  echo "[+] (${serial}) Proxy actual:"
  adb -s "$serial" shell settings get global http_proxy
}

disable_for_device() {
  local serial="$1"
  echo "[+] (${serial}) Desactivando proxy en puerto ${PORT} ..."
  adb -s "$serial" reverse --remove "tcp:${PORT}" || true
  adb -s "$serial" shell settings put global http_proxy ":0"
  echo "[+] (${serial}) Proxy actual:"
  adb -s "$serial" shell settings get global http_proxy
}

main() {
  need_adb

  if [[ $# -lt 1 ]]; then
    echo "Uso: $0 {on|off} [-p PUERTO]" >&2
    exit 1
  fi

  local action="$1"

  # Compatibilidad bash 3.2 (sin mapfile): guardo como string y recorro
  local DEVICES_STR
  DEVICES_STR="$(list_connected_devices || true)"

  if [[ -z "$DEVICES_STR" ]]; then
    echo "[-] No hay dispositivos con estado 'device'. Conecta y autoriza el/los teléfono(s) y reintenta."
    exit 2
  fi

  echo "[*] Dispositivos detectados:"
  # shellcheck disable=SC2086
  for d in $DEVICES_STR; do
    echo "    - $d"
  done

  case "$action" in
    on)
      for d in $DEVICES_STR; do
        enable_for_device "$d"
      done
      ;;
    off)
      for d in $DEVICES_STR; do
        disable_for_device "$d"
      done
      ;;
    *)
      echo "Uso: $0 {on|off} [-p PUERTO]" >&2
      exit 1
      ;;
  esac

  echo "[✓] Listo."
}

main "$@"
