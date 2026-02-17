# Changelog

All notable changes to Dirty Tricks will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-02-16

### Added
- Enhanced settings dialog with improved UI
- Class-colored tank names in chat announcements
- Auto-detection display showing current tanks in settings panel
- Slash command `/sar help` for command reference
- Modern WoW API compatibility (C_Spell, C_AddOns namespaces)
- ElvUI-compatible dark theme for settings dialog
- Real-time macro updates when group composition changes

### Changed
- Improved tank detection algorithm (prioritizes role assignment over class)
- Enhanced chat messages with class colors
- Updated to Interface 120001 (The War Within)
- Modernized code to use current WoW APIs

### Fixed
- Macro not updating when tanks leave/join mid-dungeon
- Settings dialog positioning on ultrawide monitors
- Compatibility with latest WoW patch (12.0+)

### Technical
- Migrated from GetSpellInfo() to C_Spell.GetSpellInfo()
- Migrated from GetAddOnMetadata() to C_AddOns.GetAddOnMetadata()
- Removed deprecated secure button system
- Optimized macro creation to avoid trigger limits

## [1.0.0] - 2025-11-20

### Added
- Initial release
- Automatic macro creation for Tricks of the Trade (Rogue)
- Automatic macro creation for Misdirection (Hunter)
- Dynamic tank detection in raids and parties
- Preferred tank setting via `/sar settank <name>`
- Settings popup with enable/disable toggle
- Solo mode support (Hunter pet targeting)
- Slash commands (`/sar`, `/sar toggle`, `/sar settank`, `/sar cleartank`)

### Features
- Works with multiple tanks (fallback conditionals)
- Updates macros on group roster changes
- Announces tank selection when joining groups
- Stores settings per-character via SavedVariables

### Supported Classes
- Rogue (Tricks of the Trade)
- Hunter (Misdirection)

## [Unreleased]

### Planned Features
- Per-character profiles
- Multiple preferred tanks (priority list)
- Tank selection UI (dropdown in settings)
- Localization support (esES, deDE, frFR, etc.)
- Option to disable chat announcements
- Macro icon customization
- Integration with WeakAuras for tank status
- Support for other redirect abilities (if added to WoW)

---

[1.1.0]: https://github.com/PorterFC85/dirty-tricks/releases/tag/v1.1.0
[1.0.0]: https://github.com/PorterFC85/dirty-tricks/releases/tag/v1.0.0
