# ExchangeClone
Allows players to turn nodes into energy (stored in orbs), and energy from orbs into nodes. Supports all items in Minetest Game and MineClone 2!

[GitHub repo](https://github.com/thepython10110/exchangeclone)
[Forum topic](https://forum.minetest.net/viewtopic.php?f=9&t=29473)

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
* Orbs now can be turned into energy (based on how much is stored)
I plan to add more features from Equivalent Exchange (Energy Condenser, Philosopher's Stone, dark matter, etc.), but I don't actually own MineCraft, meaning I will probably make some minor mistakes, since all I have to go on is the internet. 

## Known issues:
* When items are inserted into machines with MineClone hoppers, it does not trigger the machines to start.
* When machines are exploded, they (and the items inside) do not drop.
If you have a suggestion or notice a bug, visit the [GitHub issues page](https://github.com/thepython10110/exchangeclone/issues).

![MineClone Screenshot](screenshot.png)
![Minetest Game Screenshot](screenshot_mtg.png)

## Sources/license:
This mod is inspired by the "Equivalent Exchange" mod for MineCraft, and forked and modified from Enchant97's mod [Element Exchange](https://github.com/enchant97/minetest_element_exchange). Both this mod and Element Exchange are licensed under GPLv3+. The textures for the Constructor, Deconstructor, Collector, and Orb are from Element Exchange and have the same license.

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