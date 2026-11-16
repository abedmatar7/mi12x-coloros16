#!/system/bin/sh
MODDIR=${0%/*}

# Ensure Xiaomi 12X (psyche) DRM & mi_display sysfs/dev nodes have HAL rw permissions
for node in \
  /dev/goodix_fp \
  /dev/mi_display/disp_feature \
  /dev/uhid \
  /sys/class/drm/card0-DSI-1/disp_param \
  /sys/class/drm/card0-DSI-1/doze_brightness \
  /sys/class/drm/card0-DSI-1/fod_ui \
  /sys/class/thermal/thermal_message/sconfig; do
  if [ -e "$node" ]; then
    chown system:system "$node" 2>/dev/null
    chmod 0666 "$node" 2>/dev/null
  fi
done

# Fallback bind-mount for VINTF manifest fragment if /vendor/etc/vintf is not magic-mounted
if [ -f "$MODDIR/system/vendor/etc/vintf/manifest/manifest_mioplus_fp_aod.xml" ] && [ -d /vendor/etc/vintf/manifest ]; then
  if [ ! -f /vendor/etc/vintf/manifest/manifest_mioplus_fp_aod.xml ]; then
    cp -f "$MODDIR/system/vendor/etc/vintf/manifest/manifest_mioplus_fp_aod.xml" /dev/manifest_mioplus_fp_aod.xml 2>/dev/null
    chmod 0644 /dev/manifest_mioplus_fp_aod.xml 2>/dev/null
  fi
fi
