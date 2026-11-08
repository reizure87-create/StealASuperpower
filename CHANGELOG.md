# Changelog

All notable changes to the Steal a Superpower Hub are listed here.

## 1.1.0 - 2026-11-08

### Added
- **Power training:** Auto Train on Bench, adjustable training interval and bench range, Train at nearest bench button, and a bench scan diagnostic.
- **Power-based Auto Rebirth:** the Rebirth threshold now reads Power instead of Cash, matching the game's actual Rebirth requirement.
- **Potion automation:** Auto Use Luck / Power Potions, plus manual Luck and Power potion buttons.
- **Movement helpers:** Noclip, Infinite Jump, and Anti-Void with safe-position recovery.
- **Rejoin:** rejoin the current server in addition to low-population server hopping.
- **Game menu shortcuts:** open Codes, Cards / Index, Upgrades / Shop, Auras / Trails, and Rebirth panels through the game's own buttons.
- **Reset all settings to defaults** and automatic config persistence.
- **Teleports to Training Bench and Card Holders** in addition to Spawn, Base, Boss, and Zone.
- **Guided Learn Mode:** records the exact remote, method, and serialized arguments for 12 game actions and saves a per-`PlaceVersion` profile.
- **Decoder:** remote names are resolved by keyword and scored for the best match.
- **Debug API:** `getgenv().SAS_Hub` exposes settings, scanner, training, potions, economy, teleport, ESP, misc, GUI, and unload.
- **Repository support files:** `Loader.lua` for always-latest loading, `manifest.json` for metadata, `codes.json` for runtime codes, and a rewritten `README.md`.

### Changed
- Scanner and teleport discovery now use `IsA("BasePart")` / `IsA("Model")` instead of exact `ClassName` comparisons, so real `Part` and `Model` instances are detected.
- GUI visibility checks now stop at the DataModel root instead of incorrectly reporting hidden.
- Stats read from `leaderstats`, attributes, and visible labels, and no longer ignore legitimate zero values.
- Cooldown timers now treat `nil` as ready, so the first action after load is not suppressed.
- `notify` inside the select menu now calls `UI.notify` directly.
- `Learn.record` has a reentrancy guard and no longer recurses through `GetFullName`.
- Bench, holder, and portal scanners share the same robust scanning path.
- `Scanner`, `Teleport`, `Gui`, `Combat`, `Packs`, `Train`, `Codes`, and `Misc` first-run timers are initialized correctly.
- Unload now removes movement helpers, restores collision and lighting, clears the debug API, and destroys the GUI.
- Re-executing the script unloads the previous instance before starting a new one.
- GUI is fully responsive: desktop panel and a bottom-anchored touch layout on phones.

### Fixed
- `notify` was undefined inside `UI.addSelect`, causing a runtime error when the option list failed.
- GUI visibility chain walked past the DataModel root and returned `false` for valid game UI.
- Cooldown gates defaulting to `0` blocked the first pack, potion, combat, code, and Rebirth action.
- `Stats` skipped zero Cash / Power / Rebirth values because it checked truthiness instead of `nil`.
- `Teleport.refresh` skipped its first scan because of a zero-timestamp gate.
- `Learn.record` could recurse through `GetFullName` during capture.
- `Misc` was used by the UI before its forward declaration existed.
- ESP billboards could fail to attach when a model had no `Head` or `PrimaryPart`.

### Verified
- `luac5.1 -p` syntax check passes.
- `luacheck`: 0 errors.
- 38 functional checks pass in a mocked desktop runtime (1280x720).
- 38 functional checks pass in a mocked mobile runtime (390x844, touch input).

## 1.0.0 - 2026-11-08

### Added
- Initial single-owner hub for **[⚡] Steal a Superpower!** (universe `10770228857`, place `74183246285569`).
- Auto Farm, Kill Aura, Auto Boss, Auto Zones, Auto Movement.
- Pack automation: claim, grab, open, bank, fuse, place best, equip best aura / trail.
- Auto Upgrade, Auto Rewards, Auto Codes with the nine verified active codes.
- Teleports to Spawn, Base, Boss, Zone, and scanned points.
- Player, Boss, Pack, and Chest ESP with name tags.
- Anti-AFK, stats HUD, speed / jump modifiers, Fullbright, FPS cap.
- Discord webhook, server hop, unload, and config persistence.
- Runtime remote discovery, keyword auto-resolution, and Learn Mode scaffolding.
- Responsive PC and mobile UI with a floating toggle button.

### Known limitations
- Not executed in a live Roblox server; the game is server-authoritative and its remotes are not public.
- Some features may require Learn Mode mapping after a game update.
- Codes, UI labels, and remote names can change at any time.
