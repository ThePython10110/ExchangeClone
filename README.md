# ExchangeClone
Allows players to turn nodes into energy (stored in orbs), and energy from orbs into nodes. Supports all items in Minetest Game and MineClone 2!

[GitHub repo](https://github.com/thepython10110/exchangeclone)

[Forum topic](https://forum.minetest.net/viewtopic.php?f=9&t=29473)

[ContentDB](https://content.minetest.net/packages/ThePython/exchangeclone)

[Direct download](https://github.com/ThePython10110/ExchangeClone/archive/refs/heads/main.zip)

Dependencies: Minetest Game or MineClone.

## Features
- Orb that holds energy (left click while holding it to show charge)
- Collector that collects energy from the sun
- Deconstructor that can turn items into energy
- Constructor that can create items from energy

## Config
All energy values are in `energy.lua`. You can also change the speed at which the Energy Collector collects energy (default: every 5 seconds) in `minetest.conf` or the Minetest settings.

## New features added by ThePython10110
* Support for MineClone
* Better energy values (originally, you could convert a single diamond into a diamond block... incredibly OP).
* Shift-clicking works (`listring`s)
* Fixed a bug where items could be placed in the output slot of the Element Constructor
* Added the ability to add energy values by group
* Damaged tools now give less energy (based on wear)
* Added Philosopher's Stone
    * Right-click and sneak-right-click to increase and decrease transmutation range (0-4 blocks away from the block you are currently standing on)
    * Left-click and sneak-left-click to transmute blocks in range (two different modes with minor differences)
    * Aux1-left-click to open enchanting table (MineClone only)
    * Aux1-right-click to open crafting table (MineClone only)
    * Ability to exchange charcoal/coal/iron/copper/tin/gold/mese/emerald/diamond by crafting (the Philosopher's Stone is always returned)
    * Alchemical Coal, Mobius Fuel, and Aeternalis Fuel
    * Dark Matter Orbs, Blocks, and tools
    * Red Matter Orbs and Blocks
I don't actually own MineCraft, meaning I don't know how the original mod (Equivalent Exchange) works. I will probably make some minor mistakes, since all I have to go on is the internet. 

## Known issues:
* When items are inserted into the Energy Collector, Deconstructor, or Constructor with MineClone hoppers, it does not trigger the machines to start.
* When machines are exploded, they (and the items inside) do not drop.
* Dark Matter Shears will sometimes be treated as 

If you have a suggestion or notice a bug, visit the [GitHub issues page](https://github.com/thepython10110/exchangeclone/issues).

![MineClone Screenshot](screenshot.png)
![Minetest Game Screenshot](screenshot_mtg.png)

## Sources/license:
This mod is inspired by the "Equivalent Exchange" mod for MineCraft, and forked and modified from Enchant97's mod [Element Exchange](https://github.com/enchant97/minetest_element_exchange). Both this mod and Element Exchange are licensed under GPLv3+. The textures for the Constructor, Deconstructor, Collector, and Orb are from Element Exchange and have the same license.The Alchemical Coal, Mobius Fuel, and Aeternalis Fuel textures are modified versions of MineClone's coal texture (CC-BY-SA-3.0). All other textures are my own (inspired by Equivalent Exchange) and licensed under GPLv3+ just to make it match Element Exchange. 

Copyright (C) 2023 ThePython10110

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
