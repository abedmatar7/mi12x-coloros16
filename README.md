# Xiaomi 12X (`psyche`) ColorOS 16 FOD & AOD Fix — Magisk Module

This Magisk module integrates the reverse-engineered Xiaomi/Oplus Rust HAL bridges by `hoshikv` to resolve **FOD (Fingerprint on Display)**, **no-dim HBM brightness**, **screen-off FOD**, and **Full AOD** bugs on **Xiaomi 12X (`psyche`, Snapdragon 870 / `sm8250-ac`)** running a ColorOS 16 port ([`toraidl/coloros_port`](https://github.com/toraidl/coloros_port/blob/COS16/OOS16/README_en-US.md)).

## Integrated Upstream Sources
- **Oplus Fingerprint + DisplayPanelFeature Rust HAL**: [`hoshikv/MiOplusFingerprint-rs`](https://github.com/hoshikv/MiOplusFingerprint-rs) (including commit [`b2954ad49e56eb76537891face554aa1fd2da0b6`](https://github.com/hoshikv/MiOplusFingerprint-rs/commit/b2954ad49e56eb76537891face554aa1fd2da0b6) for no-dim brightness during FOD auth, HBM off on auth fail/progress, Oplus QuickLaunch, and Full AOD)
- **Xiaomi HyperOS Fingerprint Daemon Rust Reimplementation**: [`hoshikv/mfp-daemon-rs`](https://github.com/hoshikv/mfp-daemon-rs)
- **Oplus AIDL Vibrator HAL**: [`hoshikv/oplus_vibrator-aidl`](https://github.com/hoshikv/oplus_vibrator-aidl)
- **Oplus QCOM Charger HAL**: [`hoshikv/vendor_oplus-charger-rs`](https://github.com/hoshikv/vendor_oplus-charger-rs)
- **Custom Thermal Daemon**: [`hoshikv/kave-thermalized`](https://github.com/hoshikv/kave-thermalized)
- **Xiaomi 12X (`psyche` / `sm8250`) Device References**: [`xiaomi-psyche-development/android_device_xiaomi_psyche`](https://github.com/xiaomi-psyche-development/android_device_xiaomi_psyche), [`EndCredits/android_device_xiaomi_sm8250-common`](https://github.com/EndCredits/android_device_xiaomi_sm8250-common), and FOD coordinate properties (`441,1808`) from [`zhixiaowei/ADBLib`](https://github.com/zhixiaowei/ADBLib/blob/master/ADBLib/src/com/adb/process/android/AndroidSystem.java)

## How to Build the Rust Binaries via GitHub Actions (Zero Local Setup)
1. Extract or push the contents of `ColorOS16-Psyche-FOD-AOD-Fix-Magisk.zip` to a new repository under your GitHub account (`abedmatar7`).
2. Open the **Actions** tab and run **Build Xiaomi 12X (psyche) ColorOS 16 FOD & AOD Magisk Module** (`.github/workflows/build-magisk-module.yml`).
3. Download the compiled `ColorOS16-Psyche-FOD-AOD-Fix-Magisk` artifact and flash the resulting `.zip` in Magisk or KernelSU.
