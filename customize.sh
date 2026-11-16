SKIPUNZIP=0

ui_print "=================================================="
ui_print " Xiaomi 12X (psyche) ColorOS 16 FOD & AOD Fix     "
ui_print " Powered by hoshikv Rust HALs:                    "
ui_print " - MiOplusFingerprint-rs (b2954ad4)               "
ui_print " - mfp-daemon-rs                                  "
ui_print " - oplus_vibrator-aidl                            "
ui_print " - vendor_oplus-charger-rs                        "
ui_print " - kave-thermalized                               "
ui_print "=================================================="

DEVICE=$(getprop ro.product.vendor.device)
BOARD=$(getprop ro.board.platform)
ui_print "- Detected vendor device: ${DEVICE:-unknown} (platform: ${BOARD:-unknown})"

if [ "$DEVICE" != "psyche" ] && [ "$BOARD" != "kona" ]; then
  ui_print "! Warning: Module is tuned for Xiaomi 12X (psyche / sm8250-ac)."
  ui_print "! Continuing installation with SM8250 sysfs defaults..."
fi

# Check for underlying Xiaomi Goodix HAL blob in vendor
if [ -f /vendor/lib64/libgf_hal.so ] || [ -f /vendor/lib64/hw/fingerprint.goodix_fod.default.so ] || [ -f /odm/lib64/libgf_hal.so ]; then
  ui_print "- Found Xiaomi Goodix FOD HAL library in vendor/odm"
else
  ui_print "! Notice: libgf_hal.so not found in standard path; check /vendor/lib64"
fi

# Check if compiled Rust binaries are present in system/vendor/bin/hw
if [ -f "$MODPATH/system/vendor/bin/hw/mioplus-fingerprint-service" ]; then
  ui_print "- Found precompiled Rust HAL binaries in module package"
else
  ui_print "- Note: Rust HAL binaries not yet injected into system/vendor/bin/hw."
  ui_print "  Run the included GitHub Actions workflow (.github/workflows/build-magisk-module.yml)"
  ui_print "  to auto-compile hoshikv repos and produce the binary-packed zip,"
  ui_print "  or drop compiled binaries into /data/adb/modules/coloros16_psyche_fod_aod_fix/system/vendor/bin/hw/"
fi

# Set executable permissions on scripts and HAL binaries
set_perm_recursive "$MODPATH" 0 0 0755 0644
if [ -d "$MODPATH/system/vendor/bin" ]; then
  set_perm_recursive "$MODPATH/system/vendor/bin" 0 2000 0755 0755
fi
chmod 0755 "$MODPATH/post-fs-data.sh" "$MODPATH/service.sh"

ui_print "- Permissions and SELinux rules configured."
ui_print "- Reboot your Xiaomi 12X to activate the FOD & AOD bridge."
