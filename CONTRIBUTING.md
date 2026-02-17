# Contributing to Dirty Tricks

Thank you for your interest in contributing to Dirty Tricks! This document provides guidelines for contributors.

## Ways to Contribute

### 🐛 Bug Reports
- Check existing issues first to avoid duplicates
- Include WoW version, addon version, and your class (Rogue/Hunter)
- Describe steps to reproduce
- Include error messages (use BugSack/BugGrabber to capture Lua errors)
- Screenshots or videos are helpful!

### 💡 Feature Requests
- Explain the use case and how it helps hunters or rogues
- Consider how it fits with the addon's macro-based approach
- Check if similar features have been requested

### 🔧 Code Contributions
- Fork the repository
- Create a feature branch (`git checkout -b feature/amazing-feature`)
- Make your changes
- Test thoroughly in-game (solo, party, raid)
- Commit with clear messages
- Push to your fork
- Open a Pull Request

## Development Setup

1. Clone the repository to your WoW AddOns folder:
   ```
   cd "World of Warcraft\_retail_\Interface\AddOns"
   git clone https://github.com/PorterFC85/dirty-tricks.git "Dirty Tricks"
   ```

2. Make changes to the Lua files:
   - **Core.lua** - Main logic, tank detection, macro creation
   - **Settings.lua** - UI dialog and user preferences
   - **Profiles.lua** - Profile data (currently unused)
   - **SecureButtons.lua** - Deprecated (do not modify)

3. Test in-game:
   - `/reload` to reload the UI
   - `/sar` to open settings
   - Join a party/raid to test tank detection
   - Check macros in your macro list

4. Check for errors:
   - Use BugSack/BugGrabber addons to catch Lua errors
   - Test in combat to ensure no taint issues
   - Test with multiple tanks in a raid

## Code Style

### Lua Conventions
- Use 2 spaces for indentation
- Local variables preferred over globals
- Descriptive variable names (`tankUnit` not `tu`)
- Comment complex logic

### WoW API Best Practices
- Use modern APIs: `C_Spell.GetSpellInfo()` not `GetSpellInfo()`
- Use `C_AddOns` namespace for addon functions
- Respect protected/tainted contexts (avoid combat issues)
- Use `UnitGroupRolesAssigned()` for tank detection

### Macro System Guidelines
- Keep macros under 255 character limit
- Use `[@unitid,help,nodead]` conditionals for targeting
- Test macro generation with 5+ tanks (raid scenarios)
- Ensure `#showtooltip` is first line of macros

## Testing Checklist

Before submitting a PR, verify:

- [ ] No Lua errors when loading addon
- [ ] Settings dialog opens and closes without errors
- [ ] Macros are created successfully
- [ ] Tank detection works in party
- [ ] Tank detection works in raid
- [ ] Solo mode works for hunters (pet targeting)
- [ ] Preferred tank setting persists across /reload
- [ ] Chat announcements show correct class colors
- [ ] No taint errors during combat
- [ ] SavedVariables persist correctly

## Adding New Features

### Adding Support for New Redirect Abilities

If Blizzard adds new redirect abilities:

1. Edit `Core.lua` - Add spell ID and name
2. Update `PLAYER_ABILITIES` table with new spell data
3. Add macro creation logic in `CreateOrUpdateMacro()`
4. Update README.md feature list
5. Test thoroughly on PTR

### Adding New Tank Detection Logic

To improve tank detection:

1. Edit `DetectTanks()` function in `Core.lua`
2. Prioritize: Main Tank > Role Assignment > Class
3. Test with various group compositions
4. Ensure fallback logic works

### Adding New Settings

1. Add to `SARDB` saved variables structure
2. Create UI element in `Settings.lua`
3. Add slash command in `Core.lua` if needed
4. Apply setting in macro generation

## Release Process

Maintainers handle releases:

1. Update version in `.toc` files and Lua headers
2. Update `CHANGELOG.md` with changes
3. Create git tag (`v1.1.0`)
4. Package for CurseForge/Wago
5. Update GitHub release notes

## Questions?

- Open a GitHub Discussion for general questions
- Join Discord (if available) for real-time chat
- Check existing Issues for similar questions

## Code of Conduct

- Be respectful and constructive
- Focus on improving the addon
- Help newcomers learn
- No harassment or toxicity

## License

By contributing, you agree that your contributions will be licensed under the All Rights Reserved license.

---

**Thank you for making Dirty Tricks better!** 🙏
