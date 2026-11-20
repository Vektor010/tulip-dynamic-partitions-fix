# Project Changelog

All notable technical updates to this toolkit are documented in this file.

---

## [2.0.0] - 2026-11-20

### Added
* Full bilingual documentation architecture: dedicated `docs/ru/` and `docs/en/` directories with 10 structured guides each.
* Visual storage architecture diagrams and error troubleshooting workflows (`docs/diagrams/architecture.md`).
* Official signed USB drivers (`drivers/xiaomi_usb_driver` and `drivers/google_usb_driver`) with a 1-click installer (`drivers/install_drivers.cmd`).
* Strict CRC32 archive integrity testing (`testzip()`) in `scripts/patch_tulip_dynamic_rom.py`.
* Safety verification in `patch_tulip_dynamic_rom.py` ensuring byte substitution only modifies `cust` block device entries.

### Changed
* Redesigned root `README.md` to professional 2026 open-source standards with clear scope limitations and capability tables.
* Re-organized reference telemetry dumps, baseline benchmarks, and technical reports into `docs/reference/`.

### Fixed
* Corrected PowerShell string interpolation syntax issues in `optimize_android17.ps1` and `restore_android17.ps1` for Windows PowerShell 5.1 compatibility.
* Corrected technical conflation between recovery partition wipes and physical GPT block device checks.
