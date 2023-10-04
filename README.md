# ExchangeClone
Allows players to turn items into energy (stored in orbs), and energy from orbs into items. Supports all items in Minetest Game and MineClone 2! Includes other things from Equivalent Exchange (the MineCraft mod)

[GitHub repo](https://github.com/thepython10110/exchangeclone)

[Forum topic](https://forum.minetest.net/viewtopic.php?f=9&t=29473)

[ContentDB](https://content.minetest.net/packages/ThePython/exchangeclone)

[Wiki](https://github.com/ThePython10110/ExchangeClone/wiki)

[Direct download](https://github.com/ThePython10110/ExchangeClone/archive/refs/heads/main.zip)

Dependencies: Minetest Game or MineClone.

See the [wiki](https://github.com/ThePython10110/ExchangeClone/wiki) for a list of features.

## Known issues:
* Dark and Red Matter armor look kind of terrible in MineClone. I might fix this eventually...
* There is an error reported in MineClone related to Red Matter armor setting health.
* In MineClone, it is impossible to heal past 20 health (10 hearts) without potions of healing (or the soul/life stones, which I haven't added yet)
* With a full set of red matter armor, you can almost instantly go back to 2000 health (1000 hearts), no matter what you health is, by removing one piece of red matter armor and putting it back on. I don't really know what to do about this, because of the previous issue. Normally, I would simply make 2000 the maximum health, and leave the player's health how it is, but that doesn't really work because the extra maximum health would be useless because it's unreachable.
* When items are inserted into the Energy Collector, Deconstructor, or Constructor with MineClone hoppers, it does not trigger the machines to start. I could probably fix this just by looking at the hopper API, so this could be fixed eventually.
* When machines are exploded, they (and the items inside) do not drop. I can't figure out why.
* Dark/Red matter shears will sometimes (randomly) be treated as normal shears when used by MineClone dispensers. This will not be fixed.
* Nodes destroyed by special abilities will not usually update surrounding nodes (so you may end up with floating gravel, flowers, torches, etc.). This will *probably* not be fixed, unless a change to Minetest makes it easier.

If you have a suggestion or notice a bug, visit the [GitHub issues page](https://github.com/thepython10110/exchangeclone/issues).

![MineClone Screenshot](screenshot.png)
![Minetest Game Screenshot](screenshot_mtg.png)

## Sources/license:
* Code: Forked and *heavily* modified from Enchant97's mod [Element Exchange](https://github.com/enchant97/minetest_element_exchange). Both this mod and Element Exchange are licenced under GPLv3+. Based on Equivalent Exchange and ProjectE, mods for MineCraft.
* Textures:
    * Energy Collector, Element Deconstructor, Element Constructor: Directly from Element Exchange, GPLv3+.
    * Exchange Orb: *Slightly* modified from Element Exchange (I just changed the color to white so it could change colors correctly)
    * Alchemical Coal, Mobius Fuel, and Aeternalis Fuel: modified versions of MineClone's coal texture (CC-BY-SA-3.0).
    * Dark and Red Matter Armor (and eventually Gem Armor): modified versions of diamond armor from 3D Armor (CC-BY-SA-3.0) and `mcl_armor` (CC-BY-SA-3.0).
* All other textures (and sounds): Created by me, inspired by Equivalent Exchange and licensed under CC-BY-SA-3.0.
<details><summary><h1>Changelog:</h1></summary>

# Changelog:
### 1.0.0
* Initial release
* New features:
    * MineClone support, including (sort of) hoppers
    * Added the ability to add items by group
    * Shift-clicking (listrings)!
* Changes:
    * Completely redone recipes, now includes all items.
    * Tools' energy value now depends on wear.
* Bugfixes:
    * Items can no longer be put in the Constructor's output slot.
    * Honestly, I'm going to count the broken energy values as a bug...

### 2.0
* New features:
    * Added a changelog (you're reading it now!)
    * Added all items from Why (a MineClone modpack I made)
    * Added Philosopher's Stone (these controls are now inaccurate; changed in 3.0)
        * Left click to increase range (minimum = 0, maximum = 4).
        * Shift+left click to decrease range.
        * Aux1+left click to open enchanting table (MineClone only).
        * Right click to transmute nodes in range (mode 1).
        * Shift+right click to transmute nodes in range (mode 2, has some differences).
        * Aux1+right click to open crafting table (MineClone only).
        * Can use to craft coal into iron, mese into diamonds, etc.
* Changes:
    * Changed version numbers from x.x.x to x.x.
    * Changed the recipe for the Exchange Orb
        * New recipe is a Philosopher's Stone in the middle, diamonds in the corners, and iron/steel ingots on the sides.
    * Changed the energy values of tin, copper, and bronze in Minetest Game.
    * Renamed images to reflect mod name change ("exchangeclone" instead of "ee" for Element Exchange)
    * Deleted unnecessary "config.lua"
* Bugfixes:
    * Ghost Blocks (from Why) are now worth 0 instead of 1 (to prevent infinite energy)
    * Fixed stairs and slabs not working in Minetest Game

### 3.0 (the most interesting release so far)
* New features:
    * Added Alchemical Coal, Mobius Fuel, Aeternalis Fuel, Dark Matter (blocks and orbs), and Red Matter (blocks and orbs)
    * Added PESA (Personal Energy Storage Accessor)
        * A single inventory slot in which an orb can be placed. Energy from the orb is used for special abilities.
    * Added Dark and Red Matter tools
        * Faster than any other tools (in unmodded MTG/MCL), each has an ability
        * Special abilities that break nodes (as well as shearing) drop items directly on the player.
        * Swords:
            * Can damage all mobs within a radius (Red Matter sword can toggle between hostile/all mobs), costing 384 energy.
        * Pickaxes:
            * Has 3x1 modes (long, tall, and wide, all slightly slower)
            * Can mine a full vein of ores, dropping items and experience on the player and costing 8 energy per node broken
        * Axes:
            * Can break all wood and leaves within a radius, costing 8 energy per node broken.
        * Shovels:
            * Can break all shovely nodes within a radius, costing 8 energy per node broken
            * Can create paths in a radius, costing 4 energy per node
        * Hoes:
            * Breaks dirt incredibly quickly
            * Has a 3x3 mode for digging dirt (slightly slower)
            * Can till all dirt within a radius, costs 4 energy per node
        * Hammers:
            * Breaks pickaxey nodes in a 3x3 area
            * Can break all pickaxey nodes within a radius, costing 8 energy per node broken
        * Shears:
            * More wool/mushrooms dropped when shearing, chance of cloning sheep/mooshrooms
            * Can shear all shearable plants/cobwebs within a radius, costing 8 energy per node broken.
* Changes:
    * Added a mod whitelist in `energy.lua`, any item from a mod NOT in the whitelist (`exchangeclone.whitelisted_mods`) will have an energy value of 0
    * Orbs now show their energy on right click instead of left click
    * Changed Philosopher's Stone controls to make everything more consistant
    * The Energy Collector setting is now energy/second instead of second/energy to fit much higher costs than Element Exchange (default is 5 energy/s).
    * Set gravel value to 1 to match sand/stone/dirt/etc (MineClone).
    * Tuff, blackstone, and basalt are now transmutable (MineClone).
    * A couple of minor transmutation changes (MineClone).
    * Changed emerald value to 4096 (MineClone).
    * Gold cannot be crafted into diamonds using the PS; it can now be crafted into emeralds and emeralds into diamonds (MineClone).
    * The PS's enchanting table now is limited to 8-bookshelf enchantments to make it more balanced (MineClone).
    * Fixed terracotta values (MineClone)
    * Enchanted tools/armor are now worth the same amount as unenchanted tools/armor instead of twice as much (MineClone).
    * Enchanted tools/armor cannot be created by the Constructor (MineClone).
    * It is now impossible to get stacks of invalid sizes with the Constructor (>16 ender pearls or >1 pickaxe, for example)
* Bugfixes:
    * Fixed freezing when attempting to deconstruct 0-energy items
    * The Constructor, Deconstructor, and Energy Collector are now not unbreakable in MineClone (I really should test in survival).
    * Copper blocks are now worth 4 times as much as copper ingots instead of 9 (MineClone).
    * The Energy Collector now drops its contents when broken (MineClone)
    * Fixed Exchange Orb energy value (forgot to change it after changing the recipe)
        * Changed Constructor, Deconstructor, and Collector recipes and energy values to make them cheaper.
### 3.1
* Changes:
    * Added new energy values from Why (and Why's new Minetest Game energy values)
* Bugfixes:
    * Fixed crash based on PESA inventory movement
    * Added `mcl_blackstone` to the mod whitelist
### 3.2
    * Changes:
        * Set MineClone mod namespace to exchangeclone
### 4.0
* New features:
    * The "Features that I plan on adding eventually" list below
    * Cooldowns for tool abilities to limit lag
    * Red Katar (combination of sword, axe, hoe, and shears)
    * Red Morningstar (combination of hammer, pickaxe, and shovel)
    * Dark Matter Armor (full set gives immunity to lava/fire and drowning)
    * Red Matter Armor (full set gives lava/fire/drowning immunity PLUS 2000 health, although you may want HUD Bars to see it)
    * Added energy values for MineClone's new items.
* Changes:
    * Changed the amount of damage done by Dark/Red Matter Sword special abilities (used to be `max_damage/distance`, now is `max_damage-distance`)
    * A whole bunch of things that won't be noticible when playing, mostly code reorganization. It's *possible* that tools that mine multiple nodes at a time (hammer, pickaxe, hoe, katar, and morningstar) will be slightly less laggy
    * Texture/sound license changed to CC-BY-SA-3.0 (because GPLv3+ isn't really meant as a media license).
* Bugfixes:
    * Fixed an issue where MineClone dispensers could ONLY be used with Dark/Red Matter Shears (whoops).

### 4.1
* Bugfixes:
    * Added energy values for new armor/tools
    * Removed unnecessary chestplate image (not only is it unused, but I put it in the wrong folder for some reason)

### 4.2
* Bugfixes:
    * Fixed a dependency error (thanks, @opfromthestart!)

### 4.3
* New features:
    * New items from Why (flying sausage, useful green potatoes, etc.)
* Changes:
    * The changelog now lives here!
    * Exchange Orbs now change color based on the amount of energy (black->red->green->blue->magenta).
    * Exchange Orbs now have a maximum energy of 51,200,000 (to match Equivalent Exchange's Klein Star Omegas).
    * Water is now worth 0 instead of 1 (since it's infinite)
* Bugfixes:
    * Exchange Orbs will now correctly display their energy value (I typed `orb` instead of `exchange_orb` in the energy value list)

### 4.3
* New Features
    * Mineclonia Support

### 5.0 (the new most insteresting release so far)
* New features:
    * Added a [wiki](https://github.com/ThePython10110/ExchangeClone/wiki)! This is where you can find more complete information on pretty much everything.
        * Because the wiki exists, I won't be including anywhere near as many details about how features work in the changelog.
    * Added the Transmutation Table(t): Much better than the constructor/deconstructor.
    * Alchemical Tome: Instantly teaches every item with an energy value to the Transmutation Table(t).
    * Dark/Red Matter Furnaces: Can be powered by Energy Collectors, much faster, and sometimes double ores.
    * Personal Energy Link: Allows you to use hoppers to get items into/out of your Personal Energy (MineClone)
    * Upgraded Energy Collectors: Now MK1-MK5. They use personal energy unless they have an orb.
    * The ability to upgrade dark/red matter tools to give them fortune, looting, fire aspect, and silk touch
    * The ability to upgrade dark/red matter armor to give it thorns and frost walker
    * Mind, Life, Body, and Soul Stones
    * Mod developers can now set their own energy values by setting `exchangeclone_custom_energy` in the item/node definition.
* Changes
    * Energy for Dark/Red Matter tool abilities (as well as the Transmutation Table) is no longer stored in an orb, but inside the player.
    * The amount of energy you currently have stored is visible in the top right of the screen.
    * Because of this, the PESA is now useless and deprecated. It will be removed after a few releases (so probably a couple months at least). Remove any Exchange Orbs from your personal storage.
    * A lot of items (including DM/RM tools and armor) will not burn in lava in MineClone2.
    * Energy Collectors now send their energy to the placer's personal energy by default.
    * Red Matter Armor now sets your maximum health to 200 instead of 2000
    * Exchange Orbs are now 18x better as fuel than they used to be
    * DM/RM Shovels will now only create paths on blocks below air.
* Bugfixes:
    * I must have skipped a row while going through MineClone's mod list. Several mods starting with `mcl_b` or `mcl_c` have been added to the whitelist.
    * Fixed right-clicking with an orb not showing charge
    * Removed unnecessary tool repair recipes from dark/red matter tools/armor
    * Fixed a couple of armor texture issues in Minetest Game (though it still looks like diamond armor; 3D Armor doesn't support texture modifiers)
    * The Red Katar is now actually craftable in Minetest Game (I just forgot that shears were only in MCL2)


### Features that I plan on adding eventually:
* Something that places nodes in a square (with varying range), possibly with a low energy cost
* Ability to smelt with the Philosopher's Stone and coal/charcoal (maybe?)
* Exchangeclone guidebook (maybe depend on doc mod?)
* As soon as Minetest 5.8 comes out, better textures for armor...
* Energy Condenser
* Divining Rods
* Rings (I'll probably add a new PESA-like item for holding rings)
    * Archangel's Smite (though arrows will not track targets)
    * Ring of Ignition
    * Zero Ring
    * Swiftwolf's Rending Gale (but without the force field; basically Why's Flying Sausage with a different texture)
    * Harvest Band?
    * Ring of Arcana (possibly without the Harvest Band)
* Gem Armor

</details>