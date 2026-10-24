# FF11-GearSwap-RNG-EN (v1.0, English edition)

A GearSwap job file for the Ranger in Final Fantasy XI. It checks that you moved before each Hover Shot, swaps the expensive Hauksbok ammo in and out around melee weapon skills, and switches DistancePlus between gun and bow.

This is the English edition of [FF11-GearSwap-RNG](https://github.com/hikaruoshino/FF11-GearSwap-RNG), which is written for the Japanese client. The logic is the same. All names are in English: weapons, equipment, weapon skills and buffs.

> **Not tested on the English client.** I play on the Japanese client. The names come from the game's resource files (`res/items.lua`, `res/weapon_skills.lua`, `res/buffs.lua`), mapped from the Japanese edition. Each file passes a Lua syntax check and a mock-environment test, but I have never run this build in game. If something does not swap, please open an issue and include the console message.

## Notice

The FFXI Terms of Service prohibit third-party tools, and Windower and GearSwap may fall under that. Your account could be penalized, so use this at your own risk. The author accepts no responsibility for any harm from using it.

This job file never uses weapon skills or spells for you. It changes your equipment, cancels a ranged attack when a condition is not met, and sends commands to DistancePlus.

## What it does

1. **Hover Shot movement check**
   - While the Hover Shot buff is active, a ranged attack or an Archery/Marksmanship weapon skill is cancelled if you have not moved at least 1 Ym since the last shot. This protects the Hover Shot stack.
   - With no previous position (right after Hover Shot, or against a new enemy) it is the first shot, so nothing is checked.
   - The result is printed in chat as `[Hover OK]` / `[Hover NG]` with the distance moved.
   - The position is recorded when a shot has actually finished. An interrupted or out-of-range shot is not recorded.
   - The record resets when you use Hover Shot again, when the buff is gained or lost, and when you change zones.
2. **Expensive ammo swap**
   - For a ranged attack it equips your normal ammo (`gear.GunPhysics`, etc.) according to the type of ranged weapon you hold (gun, bow, crossbow).
   - It equips Hauksbok Arrow before Savage Blade and Hauksbok Bullet before Aeolian Edge, and takes them off after the weapon skill.
   - If a Hauksbok arrow/bullet is still equipped, it is removed before the next action so it is not used up on a normal ranged attack.
3. **Double Shot**: ranged attacks while Double Shot is active use `sets.buff['Double Shot']`.
4. **Automatic DistancePlus switching (requires DistancePlus)**
   - When you change the ranged weapon with `gs c cycle RangeWeapons`, or when your status or buffs change while that weapon is equipped (also on `//gs c update`), it sends `//dp gun` or `//dp bow` to DistancePlus. Gun: Annihilator, Fomalhaut, Armageddon. Bow: Gandiva.
   - DistancePlus prints 5 chat lines every time it receives `//dp gun`, so it remembers the mode sent last and sends only when the mode changes.
   - Sparrowhawk is a bow, but it is carried for Savage Blade, so DistancePlus is not switched for it (it stays on the previous gun / bow mode).
   - There is no `//dp xbow` switching for crossbows (the ammo choice does support crossbows).
5. **Elemental obi**: for Trueflight and Aeolian Edge it adds the weather/day obi if `get_hachirin` exists (a function from user-globals.lua; otherwise it does nothing).

## Requirements

| Requirement | Notes |
| :--- | :--- |
| Windower 4 with GearSwap | The GearSwap addon that ships with Windower, including Mote-Include |
| **DistancePlus (must be installed)** | Needed for item 4. It is in Windower's official addon list. Without it the `//dp` commands go nowhere and the distance display is not switched; everything else still works |
| English client | Names in the files are the English ones |
| `user-globals.lua` (optional) | See the next section |

Load DistancePlus (`//lua load distanceplus`; to load it automatically, add `lua l distanceplus` to `init.txt`).

## About `user-globals.lua`

Weapon switching (`gs c cycle MainWeapons` and so on), the lockstyle, the shared weapon skill definitions (`init_weapon_skill`) and the obi (`get_hachirin`) assume the `user-globals.lua` from [greeds.net's GearSwap code list](https://greeds.net/gearswap-code-list/) (the files are in [ktgreeds/GearSwap](https://github.com/ktgreeds/GearSwap)). That file belongs to greeds. It has no license and no redistribution permission is stated, so **this repository includes neither the file nor any translation or modification of it.**

You do not need it to run this job file. `init_ranger_weapon_skills` in `RNG_gear.lua` holds a minimal table of which set each ranged weapon skill uses, and it is used when `init_weapon_skill` does not exist. Without that file, though, weapon switching with `gs c cycle MainWeapons` does nothing.

If you already use greeds's code on the English client, note that parts of it may use Japanese names (buff names, spell names, comments). I can point out which places need English names, in an issue on this repository. I will not post the file.

## Files and installation

```text
Windower4/addons/GearSwap/data/
├── RNG.lua                  <-- the logic
└── <your character name>/
    └── RNG_gear.lua         <-- your gear sets (rewrite them for your own gear)
```

1. Download this repository (Code > Download ZIP) and unzip it.
2. Put `RNG.lua` in `Windower4/addons/GearSwap/data/`.
3. Put `RNG_gear.lua` in `Windower4/addons/GearSwap/data/<your character name>/`, and **rewrite the sets for the gear you own.** The file contains my own gear.
4. Log in as a Ranger and run `//gs reload` (or `//gs load RNG`).

## Gear file (`RNG_gear.lua`)

| Setting | Used |
| :--- | :--- |
| `gear['Weapon Name']` | The definition used for weapon switching. Keep the names in line with `state.MainWeapons` / `SubWeapons` / `RangeWeapons` in `RNG.lua` |
| `gear.GunPhysics` / `BowPhysics` / `CrossbowPhysics` | The normal ammo equipped for ranged attacks |
| `gear['Hauksbok Arrow']` / `gear['Hauksbok Bullet']` | The ammo equipped before Savage Blade / Aeolian Edge |
| `sets.precast.RA` / `sets.midcast.RA` (`.Double` / `.ACC`) | Snapshot / ranged attack |
| `sets.buff['Double Shot']` | Ranged attacks while Double Shot is active |
| `sets.precast.WS.Damage` / `.Range` / `.Magic`, and per-weapon-skill sets | Weapon skills |
| `sets.idle` / `sets.engaged` and so on | Your normal gear |

## What has been tested

* Mock-environment tests pass for this build (Hover Shot check, ammo swap, DistancePlus switching, and the weapon skill table).
* The Japanese edition's DistancePlus switching was confirmed in game on 2026-10-24. This English build has not been run in game.
* The Hover Shot check and the ammo swap have not been tried in game in this cleaned-up version, and neither has the ammo swap when Savage Blade or Aeolian Edge are used several times in a row.
* `RNG_gear.lua` is my own gear, with the names converted to English.

## Credits and license

The base structure of this job file (the file layout, how the gear file is written, how weapon switching is organized) comes from the code and explanations of greeds ([greeds.net](https://greeds.net/gearswap-code-list/), [ktgreeds/GearSwap](https://github.com/ktgreeds/GearSwap)), which I customized and rebuilt. The Hover Shot criterion follows the hovershot addon. No license is attached; the rights to the original code belong to its authors. If there is a problem, please tell me and I will take this down.

## Changelog

* v1.0: first release. DistancePlus is told only when the ranged weapon type changes

## Feedback

A one-line "it works" is welcome too. With a GitHub account you can post from [Issues](../../issues/new/choose).
