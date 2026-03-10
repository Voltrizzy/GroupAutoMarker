# GroupAutoMarker

A World of Warcraft addon for **Midnight (Patch 12.0)** that automatically assigns raid markers to your party members by role when you enter a Midnight Mythic dungeon.

---

## Features

- Automatically marks the **Tank**, **Healer**, and up to **3 DPS** players when you zone into a Midnight Mythic dungeon.
- Configurable per-role marker assignments via **Esc > Options > AddOns > Group Auto Marker**.
- Enforces **unique marker assignments** — selecting a marker already in use by another role will automatically clear it from the previous role.
- Marks are only applied when:
  - You are in a group.
  - The instance is a **Midnight expansion Mythic dungeon**.
  - You are the **party leader or raid officer**.
- Marks are re-applied on group roster changes and zone transitions.

---

## Supported Dungeons

Marking is active in all eight Midnight expansion Mythic dungeons:

| Dungeon | Zone |
|---------|------|
| Windrunner Spire | Eversong Woods |
| Magister's Terrace | Isle of Quel'Danas |
| Murder Row | Silvermoon City |
| The Blinding Vale | Harandar |
| Den of Nalorakk | Zul'Aman |
| Maisara Caverns | Zul'Aman |
| Voidscar Arena | Voidstorm |
| Nexus Point Xenas | Voidstorm |

---

## Installation

1. Download or clone this repository.
2. Copy the `GroupAutoMarker` folder into your addons directory:
   ```
   World of Warcraft/_retail_/Interface/AddOns/GroupAutoMarker/
   ```
3. Launch the game and enable the addon in the **AddOns** menu on the character select screen.

---

## Configuration

1. Open **Esc > Options > AddOns > Group Auto Marker**.
2. Use the dropdown for each role to choose a raid marker icon.
3. Changes are saved automatically and persist across sessions.

**Default assignments:**

| Role   | Default Marker |
|--------|---------------|
| Tank   | Square (6)    |
| Healer | No Marker     |
| DPS 1  | No Marker     |
| DPS 2  | No Marker     |
| DPS 3  | No Marker     |

**Available markers:** No Marker, Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull.

---

## Requirements

- World of Warcraft: **Midnight** (Patch 12.0.0+)
- You must be the **party leader or raid officer** for markers to be applied.

---

## Files

| File | Purpose |
|------|---------|
| `GroupAutoMarker.toc` | Addon metadata and load order |
| `Data.lua` | Dungeon IDs, marker definitions, and role defaults |
| `Options.lua` | Settings panel UI and save/load logic |
| `Core.lua` | Auto-marking engine and event handling |

---

## License

See [LICENSE](LICENSE) for details.
