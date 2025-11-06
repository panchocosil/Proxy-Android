# proxy-android

Script en **bash** para configurar o desactivar un proxy local (por defecto `127.0.0.1:8080`) en uno o varios dispositivos Android conectados mediante **ADB**.

Permite redirigir el tráfico HTTP del dispositivo hacia tu equipo host, útil para pruebas de seguridad, interceptación con Burp Suite, Charles Proxy, mitmproxy, etc.

---

## 🚀 Características

- Configura el proxy HTTP del sistema Android.
- Redirige automáticamente el puerto local con `adb reverse`.
- Soporta **múltiples dispositivos** conectados (usa `adb -s <serial>`).
- Compatible con macOS (bash 3.2), Linux y bash modernos.
- Permite especificar un **puerto personalizado**.

---

## 🧰 Requisitos

- `adb` (Android Platform Tools) instalado y en el `PATH`.
- Un dispositivo Android conectado por USB y autorizado (`adb devices` debe mostrar `device`).
- Permisos de ejecución sobre el script.

---

## ⚙️ Instalación

```bash
# Copiar el script al directorio de binarios del usuario
sudo mv proxy-android.sh /usr/local/bin/proxy-android

# Dar permisos de ejecución
sudo chmod +x /usr/local/bin/proxy-android

Si macOS bloquea la ejecución (mensaje “operation not permitted”), elimina atributos extendidos:

sudo xattr -c /usr/local/bin/proxy-android

O usa una ruta local:

mkdir -p ~/.local/bin
mv proxy-android ~/.local/bin/proxy-android
chmod +x ~/.local/bin/proxy-android
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc


⸻

🖥️ Uso

proxy-android on           # Activa el proxy (por defecto 127.0.0.1:8080)
proxy-android off          # Desactiva el proxy
proxy-android on -p 8081   # Activa el proxy en otro puerto

El script aplica los cambios a todos los dispositivos conectados.

⸻

📋 Ejemplo de salida

[*] Dispositivos detectados:
    - emulator-5554
    - R58M1234ABC
[+] (emulator-5554) Activando proxy 127.0.0.1:8080 ...
[+] (R58M1234ABC) Activando proxy 127.0.0.1:8080 ...
[✓] Listo.


⸻

🧠 Cómo funciona

Al activar (on)
	1.	Ejecuta adb reverse tcp:8080 tcp:8080 para redirigir el tráfico del dispositivo al host.
	2.	Configura el proxy del sistema Android:

adb shell settings put global http_proxy 127.0.0.1:8080



Al desactivar (off)
	1.	Elimina la redirección:

adb reverse --remove tcp:8080


	2.	Limpia el proxy:

adb shell settings put global http_proxy :0



⸻

⚠️ Notas
	•	Solo afecta tráfico HTTP (no HTTPS si las apps no respetan la configuración del sistema).
	•	Algunos dispositivos requieren activar “Opciones de desarrollador → Depuración USB → Permitir ajustes ADB”.
	•	Puedes usarlo junto a Burp Suite, mitmproxy, OWASP ZAP, etc.

⸻
