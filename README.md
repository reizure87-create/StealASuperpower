# Steal a Superpower Hub

A feature-rich, universal automation hub for **[[⚡] Steal a Superpower!](https://www.roblox.com/games/74183246285569)** on PC and mobile.

- **Universe:** `10770228857`
- **Place:** `74183246285569`
- **Game reference checked:** 2026-11-08
- **Hub version:** 1.1.0
- **No key system. No account data collection.**

> This game is a **packs / holders / bosses / Bench training** game, not a base-raid "steal" game. The hub prioritizes the mechanics that actually exist: pack opening, card holders, Bench Power training, bosses, Rebirth, potions, auras, trails, and Index rewards.

---

## Load the script

Use this one-liner in any executor that supports `loadstring` and HTTP requests:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/reizure87-create/StealASuperpower/main/Loader.lua"))()
```

The loader downloads the current `StealASuperpower.lua` from this repository and runs it. The main script checks the game's universe ID and exits in other games.

### Direct script URL

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/reizure87-create/StealASuperpower/main/StealASuperpower.lua"))()
```

---

## Features

### Combat and farming
- Auto Farm nearest enemy
- Kill Aura with multi-target attacks
- Auto Boss priority mode
- Auto Unlock / Enter Zones
- Auto Movement
- Optional teleport-to-target mode
- Target other players (off by default)
- GUI ability-button fallback
- Adjustable farm range, attack range, and attack delay
- Equip Best Tool and Attack Nearest buttons

### Packs and cards
- Auto Claim Packs
- Auto Grab Dropped Packs
- Auto Open Packs
- Auto Bank Packs
- Auto Fuse Cards
- Auto Place Best Cards
- Auto Equip Best Aura / Trail
- Auto Use Luck / Power Potions
- Manual Luck and Power potion buttons
- Adjustable pack action interval

### Power training and Rebirth
- Auto Train on Bench
- Adjustable training interval
- Adjustable bench search range
- Train-at-nearest-bench button
- Bench diagnostics: shows how many bench objects were found and the nearest distance
- **Power-based** Auto Rebirth (not Cash)
- Adjustable Rebirth Power threshold
- Manual Trigger Rebirth button

### Economy and codes
- Auto Upgrade
- Auto Claim Rewards
- Auto Codes
- Custom code list (comma separated)
- Reset tried-code history
- GUI shortcuts for Codes, Cards / Index, Upgrades / Shop, Auras / Trails, and Rebirth
- Reset all settings to defaults

### Teleports and ESP
- Go to Spawn
- Go to Base
- Go to nearest Boss
- Go to next Zone / Portal
- Go to Training Bench
- Go to Card Holders
- Teleport to any scanned point
- Player ESP
- Boss ESP
- Pack ESP
- Chest / Loot ESP
- Name tags
- Clear all ESP

### Quality of life
- Anti-AFK
- Stats HUD: Cash, Power, Rebirth, remotes, FPS
- Speed modifier
- Jump modifier
- Noclip
- Infinite Jump
- Anti-Void
- Fullbright
- FPS cap
- Optional Discord webhook
- Server hop (low population)
- Rejoin current server
- Unload and clean up

### Learn Mode
The game updates and changes its remote names. Learn Mode records the exact `FireServer` / `InvokeServer` call that the game itself makes while you perform an action once:

1. Open **Learn**.
2. Press **Start capture**.
3. Select the step (for example, "Open a pack").
4. Do that action once in the game.
5. Press **Save current step**.
6. Repeat for each action you want to map.

Profiles are saved per `PlaceVersion` under the executor's workspace:

```
StealASuperpower/profiles/<PlaceVersion>.json
StealASuperpower/profile.json
```

Do not run Learn Mode while another hub is hooking the same remote calls.

---

## Mobile instructions

The UI is responsive and uses a touch-safe bottom layout on phones. On mobile:

- Use the floating **SAS** button at the bottom-right to reopen the menu.
- The menu keybind (`RightShift` by default) requires a physical keyboard and is optional; tap the SAS button instead.
- Sliders and toggles support touch input.
- Large teleports and server actions can be rate-limited by the game or executor; use them sparingly.

The same loader one-liner works on mobile executors.

---

## Quick start

1. Load the script in **Steal a Superpower**.
2. Open the **Codes** menu in-game once, then use **Economy -> Auto Codes** or **Try next code now**.
3. Go to the training area and enable **Farm -> Auto Train on Bench**. Press **Diagnose bench scan** if no bench is found.
4. Enable **Packs -> Auto Open Packs** and **Auto Use Luck / Power Potions**.
5. Enable **Packs -> Auto Place Best Cards** and **Auto Equip Best Aura / Trail**.
6. Use **Auto Boss** and **Auto Unlock / Enter Zones** to progress.
7. When Power is high enough, enable **Economy -> Auto Rebirth**. Set the threshold to a value you are comfortable with.
8. Use **Teleport** buttons if movement is slow or the map is confusing.

---

## Codes

The hub ships with the codes verified on **2026-11-07/08**:

| Code | Reward |
|---|---|
| `10KCCU` | Mystery Pack (can roll any card in your World) |
| `50KLIKES` | All tier potions at 3x |
| `30KLIKES` | Luck or Power potions |
| `SOZFORUPDATES` | Luck or Power potions |
| `20KLIKES` | Luck or Power potions |
| `10KLIKES` | Luck or Power potions |
| `1KCCU` | Luck or Power potions |
| `POTIONS` | Luck or Power potions |
| `DISCORD` | Legend Pack |

Codes are **one-time per account** and can expire or lag on old servers. The hub also downloads `codes.json` from this repository at startup. If a code fails, update `codes.json` or add your own list in **Economy -> Custom codes**.

---

## Configuration

Settings are saved automatically when you change a toggle, slider, or text box:

```
StealASuperpower/config.json
```

The config is per executor workspace, not per Roblox account. Use **Economy -> Reset all settings to defaults** if a setting causes problems.

---

## Repository files

| File | Purpose |
|---|---|
| `StealASuperpower.lua` | Main hub, single-file build |
| `Loader.lua` | Always-latest loader |
| `manifest.json` | Version, game reference, codes, feature metadata |
| `codes.json` | Code list fetched at runtime |
| `README.md` | This document |
| `CHANGELOG.md` | Version history |

---

## Testing and limitations

This build was checked with:

- `luac5.1 -p` syntax validation
- `luacheck` (no errors)
- **38 functional checks** in a mocked desktop Roblox runtime
- The same **38 checks** in a mocked mobile runtime (390x844 touch viewport)

The mock tests cover scanner discovery, stats from `leaderstats`, Bench training prompts, potion clicks, pack opening, combat fallback, Power-based Rebirth, code entry, teleports, speed/noclip/anti-void, infinite jump, UI show/hide, UI button wiring, Learn capture, ESP, config reset, and unload.

**Important:** this has not been executed inside a live Roblox server. Roblox is server-authoritative, and the game's remote names and UI labels are not public. The hub uses runtime discovery, UI fallbacks, and Learn Mode for that reason. Some features may need a Learn Mode mapping after a game update.

Other limitations:

- Auto features depend on visible UI labels or `leaderstats` for Cash/Power/Rebirth detection.
- Large teleports may be rejected by the server or anti-cheat.
- Potion automation assumes a button with a name containing "Luck Potion" or "Power Potion" and a "Use"-style confirmation button. If the menu is different, use Learn Mode.
- Server hop uses the public Roblox server list and may fail during outages or after API changes.
- The optional Discord webhook sends only the messages you enable. Do not put private information in it.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Menu does not appear | Re-execute the loader. On mobile, tap the floating SAS button. |
| "This script only works in..." | You are in the wrong game or a different place/universe. |
| Auto Open finds no pack | Walk to the pack area, press **Claim nearest pack**, or map `openPack` in Learn Mode. |
| Auto Train finds no bench | Stand in the training area and press **Diagnose bench scan**; raise the search range. |
| Rebirth does nothing | Raise Power above the threshold, open the Rebirth menu once, or map `rebirth` in Learn Mode. |
| Cash/Power show `?` | Open the game's main HUD once so the scanner can read the labels, or use a server with visible leaderstats. |
| GUI buttons are not clicked | Some games block synthetic input. Map the action in Learn Mode or use the direct server call. |
| Settings look wrong | **Economy -> Reset all settings to defaults**, then reload. |

---

## Disclaimer

This is a third-party automation tool. It violates the game's intended rules and can get an account banned. **Test on an alt account first.** The author is not responsible for bans, lost items, or account damage. The script is provided as-is, with no warranty.

No key system, no obfuscation, no account cookies, and no hidden data collection. The only network requests are to GitHub raw files for updates/codes and, if you explicitly enable it, your own Discord webhook URL.
