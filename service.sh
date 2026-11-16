#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE="/data/local/tmp/coloros16_psyche_fod_aod.log"

log_msg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_msg "Starting Xiaomi 12X (psyche) ColorOS 16 FOD & AOD service script..."

# Wait until boot completes
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1
done

# 1. Re-apply permissions on Xiaomi SM8250 DRM & Goodix nodes after boot
for node in \
  /dev/goodix_fp \
  /dev/mi_display/disp_feature \
  /sys/class/drm/card0-DSI-1/disp_param \
  /sys/class/drm/card0-DSI-1/doze_brightness \
  /sys/class/drm/card0-DSI-1/fod_ui; do
  if [ -e "$node" ]; then
    chown system:system "$node" 2>/dev/null
    chmod 0666 "$node" 2>/dev/null
  fi
done

# 2. If MiOplusFingerprint-rs / mfp-daemon-rs binaries are installed, stop legacy Xiaomi HIDL FP daemon
#    so it does not lock /dev/goodix_fp, then start the Rust AIDL services.
if [ -x /vendor/bin/hw/mioplus-fingerprint-service ] || [ -x "$MODDIR/system/vendor/bin/hw/mioplus-fingerprint-service" ]; then
  log_msg "Found mioplus-fingerprint-service binary; stopping conflicting legacy HIDL fingerprint services..."
  stop vendor.fps_hal 2>/dev/null
  stop fps_hal 2>/dev/null
  killall -9 android.hardware.biometrics.fingerprint@2.1-service 2>/dev/null
  killall -9 android.hardware.biometrics.fingerprint@2.3-service.xiaomi 2>/dev/null

  if [ -x /vendor/bin/hw/mfp-daemon ]; then
    log_msg "Starting mfp-daemon-rs..."
    /vendor/bin/hw/mfp-daemon >/dev/null 2>&1 &
    sleep 1
  fi

  log_msg "Starting MiOplusFingerprint-rs (FOD + oplusdisplaypanelfeature + Full AOD)..."
  /vendor/bin/hw/mioplus-fingerprint-service >/dev/null 2>&1 &
else
  log_msg "mioplus-fingerprint-service binary not yet present; activating SM8250 sysfs FOD HBM/AOD guard loop."
fi

# 3. Start optional hoshikv companion Rust services if compiled and present
if [ -x /vendor/bin/hw/vendor.oplus.hardware.vibrator-service ]; then
  log_msg "Starting oplus_vibrator-aidl..."
  /vendor/bin/hw/vendor.oplus.hardware.vibrator-service >/dev/null 2>&1 &
fi

if [ -x /vendor/bin/hw/vendor.oplus.hardware.charger-service ]; then
  log_msg "Starting vendor_oplus-charger-rs..."
  /vendor/bin/hw/vendor.oplus.hardware.charger-service >/dev/null 2>&1 &
fi

if [ -x /vendor/bin/kave-thermalized ]; then
  log_msg "Starting kave-thermalized..."
  stop mi_thermald 2>/dev/null
  /vendor/bin/kave-thermalized >/dev/null 2>&1 &
fi

# 4. SM8250 (psyche) Display Parameter Guard for Stuck HBM & AOD Brightness
#    Monitors fod_ui & screen state so HBM turns off cleanly after FOD auth or fail.
DISP_PARAM="/sys/class/drm/card0-DSI-1/disp_param"
FOD_UI="/sys/class/drm/card0-DSI-1/fod_ui"
DOZE_NODE="/sys/class/drm/card0-DSI-1/doze_brightness"

if [ -f "$DISP_PARAM" ] && [ -f "$FOD_UI" ]; then
  LAST_FOD="0"
  while true; do
    CUR_FOD=$(cat "$FOD_UI" 2>/dev/null || echo "0")
    if [ "$CUR_FOD" != "$LAST_FOD" ]; then
      if [ "$CUR_FOD" = "1" ]; then
        # Enable local FOD HBM without full-screen dim layer
        echo "0x20000" > "$DISP_PARAM" 2>/dev/null
      else
        # Clear FOD HBM immediately on finger-up / auth fail / unlock
        echo "0x0" > "$DISP_PARAM" 2>/dev/null
      fi
      LAST_FOD="$CUR_FOD"
    fi
    sleep 0.15
  done &
fi

log_msg "Service initialization complete."
