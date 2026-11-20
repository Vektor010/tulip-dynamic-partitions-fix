---
name: android-adb-script-audit
description: Rigorous auditing and safety engineering for Android, ADB, Fastboot, and Qualcomm device automation scripts.
---

# Android ADB Script Audit Skill

## Overview
This skill establishes strict safety constraints, validation patterns, and diagnostic mandates for scripts communicating with Android devices via ADB, Fastboot, or local shell environments (specifically tailored for Qualcomm Snapdragon devices such as **Redmi Note 6 Pro / Tulip**).

## 1. Identity & Environment Gates (Fail-Closed)
- **Codename Verification:**
  - Never issue destructive or device-specific configuration commands blindly.
  - Query `getprop ro.product.device` and `getprop ro.build.product`.
  - Abort immediately with a non-zero exit code if the device does not match supported targets (`tulip`, `twolip`, `bouquet`).
- **Android Version & API Verification:**
  - Query `getprop ro.build.version.release` and `getprop ro.build.version.sdk`.
  - Do not apply version-specific tweaks (such as cgroup v2 App Freezer or `disable_window_blurs`) to unsupported Android releases.
- **Root Privilege Gate:**
  - Verify `adb shell id` output contains `uid=0(root)`. If root is required and unavailable, exit immediately without making partial changes.

## 2. Kernel & Hardware Tweak Rules
- **Sysfs Existence Validation:**
  - Never write directly to `/sys/` or `/proc/` paths without testing file existence in shell:
    `if [ -e /sys/block/zram0 ]; then ... fi`
- **Thermal Safety:**
  - NEVER disable thermal management daemons (`thermal-engine`, `mi_thermald`) or overwrite thermal trip points.
- **SELinux Enforcement:**
  - NEVER switch SELinux to Permissive (`setenforce 0`) for everyday operations. Scripts must operate cleanly within Enforcing mode.
- **Clock Frequencies & Voltages:**
  - Do not modify raw CPU/GPU PLL frequencies, voltage regulators, or under-volt tables via unverified sysfs writes.

## 3. Reversibility & Transactional Guarantees
- **Package Debloating:**
  - Use `pm uninstall -k --user 0 <pkg>` (keeps APK cached in system partition, instant 1-second restoration via `cmd package install-existing <pkg>`).
  - Do not mount system as read-write (`mount -o remount,rw /`) or `rm -rf` APK binaries from system partitions.
- **1:1 Rollback Invariant:**
  - Every optimization applied by an install script MUST have an exact inverse operation in the rollback script (`restore_android17.ps1`).
