# Element Exchange
A [Minetest](https://www.minetest.net/) mod to exchange nodes into other nodes. This is mod is inspired by the "Equivalent Exchange" mod for MineCraft, and forked and modified from [Element Exchange](https://github.com/enchant97/minetest_element_exchange). In other words, a lot of the code is not mine.

![In Game Screenshot](screenshot.png)

[GitHub repo](https://github.com/thepython10110/exchangeclone)

## Features
- Orb that holds energy (left click while holding it to show charge)
- Collector that collects energy from the sun
- Deconstructor that can turn items into energy
- Constructor that can create items from energy

## Config
You can change the default values in the Minetest settings under `mods > exchangeclone`.

## New features added by ThePython10110
* Working on support for MineClone, including hoppers (all features work, just need to add energy values)
* Shift-clicking works (`listring`s)
* Fixed a bug where items could be placed in the output slot of the Element Constructor
* Added the ability to add energy values by group
* Damaged tools now give less energy (based on wear)
* Orbs now can be turned into energy (based on how much is stored)
I plan to add more features from Equivalent Exchange (Energy Condenser, Philosopher's Stone, dark matter, etc.), but I don't actually own MineCraft, meaning I will probably make some minor mistakes, since all I have to go on is the internet. Please report any issues on the [GitHub issues page](https://github.com/thepython10110/exchangeclone/issues).

## Original License
Copyright (C) 2021 Leo Spratt

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