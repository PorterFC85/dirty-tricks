# Dirty Tricks

An automatic macro-based redirect addon for World of Warcraft. Dynamically creates and updates macros for **Tricks of the Trade** (Rogue) and **Misdirection** (Hunter) that automatically target the current group's tank.

Perfect for Mythic+ dungeons, raids, and any group content where you need reliable threat redirection.

## Features

✅ **Automatically detects tanks** in raid or party  
✅ **Works with multiple tanks** (adds conditional fallbacks)  
✅ **Works solo** with hunter pets  
✅ **Updates in real-time** as group composition changes  
✅ **Colored chat messages** with class colors for tank names  
✅ **Announces tank selection** when joining groups  
✅ **No secure frame restrictions** — pure macro based  
✅ **Modern WoW API** (compatible with current patches)  
✅ **ElvUI compatible** dark theme for settings dialog  

## How It Works

The addon creates two global macros:
- **Dirty Tricks of the Trade** — Automatically targets the tank in raid/party (Rogue)
- **Dirty Misdirection** — Automatically targets the tank in raid/party (Hunter)

These macros are **dynamically updated** whenever group composition changes, so they always redirect to the appropriate tank (raid3, raid4, party1, pet, etc.).

## Installation

1. Extract the addon folder to `World of Warcraft\_retail_\Interface\AddOns\`
2. Restart WoW or type `/reload`
3. Enable "Dirty Tricks" in your Add-ons list

## Usage

1. **Load in WoW**: Enable the addon in your add-ons list
2. **Open settings**: Type `/sar` to toggle the settings popup (movable & draggable)
3. **Configure**:
   - Toggle the addon on/off
   - Enter a preferred tank name (optional) or leave blank for auto-detection
   - Click OK to save
4. **Find the macros**: Open your macro list (Macros button in Game Menu)
5. **Drag to action bar**: Find "Dirty Tricks of the Trade" or "Dirty Misdirection" and drag to your action bar
6. **Use like normal**: Click the macro or bind it to a key—it will always redirect to your target

## Commands

| Command | Action |
|---------|--------|
| `/sar` | Open/close settings popup (movable & draggable) |
| `/sar toggle` | Enable/disable the addon |
| `/sar settank <name>` | Set preferred tank/player name |
| `/sar cleartank` | Clear preferred tank (use auto-detection) |
| `/sar help` | Show all available commands |

## Features

✅ Automatically detects tanks in raid or party  
✅ Works with multiple tanks (adds conditional fallbacks)  
✅ Works solo with hunter pets  
✅ Updates in real-time as group composition changes  
✅ Colored chat messages with class colors for tank names  
✅ Announces tank selection when joining groups  
✅ No secure frame restrictions—pure macro based  
✅ Modern WoW API (compatible with current patches)  
✅ ElvUI compatible dark theme for settings dialog  

## How the Macro System Works

This addon uses **global macros** with WoW macro conditionals (`[@unitid,help,nodead]`) rather than secure buttons or direct spell casting. This approach provides:

- **Reliability**: Uses WoW's native macro system
- **Security Compliance**: User explicitly triggers the cast (no addon-driven execution)
- **Raid Safety**: No restrictions on casting from within macros
- **Flexibility**: Easily customizable through WoW's macro editor

### Example Macro
```
#showtooltip
/cast [@raid3,help,nodead][@raid4,help,nodead][@party1,help,nodead][@pet,help,nodead] Tricks of the Trade
```

The addon dynamically generates these conditionals based on detected tanks.

## Files

| File | Purpose |
|------|---------|
| **Core.lua** | Main addon logic; tank detection, macro creation, and slash commands |
| **Settings.lua** | Popup settings dialog, UI configuration, and player detection |
| **Profiles.lua** | Profile data structure (for future expansion) |
| **SecureButtons.lua** | Deprecated (kept for reference) |
| **Dirty Tricks.toc** | Addon manifest with metadata and load order |

## Supported Classes

- **Rogue** — Uses "Tricks of the Trade"
- **Hunter** — Uses "Misdirection"

## Compatibility

- **WoW Version**: Dragonflight/Midnight (Patch 12.0+)
- **Interface**: 110207, 120000, 120001
- **Modern API**: Uses current WoW APIs (`C_Spell.GetSpellInfo()`, `UnitGroupRolesAssigned()`, etc.)

## Troubleshooting

**Addon says "incompatible":**
- Update WoW to the latest patch
- Verify the addon is enabled in your Add-ons list

**Macros not showing in macro list:**
- Reload the UI (`/reload`)
- Open the settings with `/sar` to retrigger macro creation

**Tank not redirecting:**
- Verify the macro is on your action bar
- Check that a tank is detected (open `/sar` settings to see detected tanks)
- Manually set a tank name with `/sar settank <name>` if auto-detection fails

**Settings dialog not appearing:**
- Type `/sar help` to verify the addon is loaded
- Try `/reload` to reload the UI

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- Report bugs
- Suggest features
- Submit pull requests
- Help with localization

## License

All Rights Reserved - See [LICENSE](LICENSE) file for full text.

Copyright (c) 2026 Dirty Tricks

## Credits

Created by PorterFC85  
For rogues and hunters who want reliable threat redirection in group content.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

### Current Version: 1.1.0
- Enhanced settings dialog with tank auto-detection display
- Class-colored tank names in announcements
- Modern WoW API compatibility (12.0+)
- ElvUI-compatible dark theme

---

**Never manually update your redirect macros again!** 🎯

## Support

- **Issues**: Report bugs on GitHub Issues (https://github.com/PorterFC85/dirty-tricks)
- **CurseForge**: Install via CurseForge (Sneaky85)
- **Updates**: Check CurseForge or Wago.io for latest versions

## For Developers

### File Structure
```
Dirty Tricks/
├── Core.lua              # Main logic, tank detection, macro creation
├── Settings.lua          # UI dialog and preferences
├── Profiles.lua          # Profile system (future expansion)
├── SecureButtons.lua     # Deprecated (kept for reference)
├── Dirty Tricks.toc      # Addon manifest
├── LICENSE               # All Rights Reserved License
├── README.md             # This file
├── CHANGELOG.md          # Version history
└── CONTRIBUTING.md       # Contribution guidelines
```

### Key Functions
- `DetectTanks()` - Finds all tanks in group via role assignment
- `CreateOrUpdateMacro()` - Generates macro with conditional targeting
- `OnGroupRosterUpdate()` - Triggers macro updates on group changes
- `SlashCommand()` - Handles `/sar` commands

---

**Version**: 1.1.0  
**Author**: PorterFC85  
**License**: All Rights Reserved
