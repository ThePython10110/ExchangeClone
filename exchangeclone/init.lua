if not (exchangeclone and minetest.get_modpath("_exchangeclone_energy")) then
	error("Disable and re-enable the ExchangeClone modpack.")
end

if (not minetest.get_modpath("mcl_core")) and (not minetest.get_modpath("default")) then
    error("ExchangeClone requires 'default' or 'mcl_core,' but Minetest doesn't let me mark one or the other as a dependency.")
else
	exchangeclone.mcl = minetest.get_modpath("mcl_core")
end

exchangeclone.mineclonia = minetest.get_game_info().id == "mineclonia" -- if exchangeclone.mineclonia, exchangeclone.mcl is also defined.


exchangeclone.orb_max = 51200000 -- Max capacity of Klein Star Omega in ProjectE

local modpath = minetest.get_modpath("exchangeclone")

exchangeclone.orb_max = minetest.settings:get("exchangeclone.orb_max") or 51200000
exchangeclone.num_passes = minetest.settings:get("exchangeclone.num_passes") or 10

minetest.log("action", "Loading Exchangeclone")

dofile(modpath.."/lib.lua")
dofile(modpath.."/constructor.lua")
dofile(modpath.."/deconstructor.lua")
dofile(modpath.."/energy_collector.lua")
dofile(modpath.."/orb.lua")
dofile(modpath.."/craftitems.lua")
if exchangeclone.mcl or minetest.get_modpath("3d_armor") then
	dofile(modpath.."/armor.lua")
end
if exchangeclone.mcl then
	mcl_item_id.set_mod_namespace("exchangeclone")
	dofile(modpath.."/shears.lua")
	dofile(modpath.."/tool_upgrades.lua")
end
dofile(modpath.."/multidig.lua")
dofile(modpath.."/swords.lua")
dofile(modpath.."/axes.lua")
dofile(modpath.."/hoes.lua")
dofile(modpath.."/pickaxes.lua")
dofile(modpath.."/hammers.lua")
dofile(modpath.."/shovels.lua")
dofile(modpath.."/red_matter_multitools.lua")
dofile(modpath.."/covalence_dust.lua")
if minetest.get_modpath("hopper") then
	dofile(modpath.."/hopper_compat.lua")
end
dofile(modpath.."/philosophers_stone.lua")
dofile(modpath.."/pesa.lua")
dofile(modpath.."/infinite_food.lua")
dofile(modpath.."/alchemical_chests.lua")
dofile(modpath.."/transmutation_table.lua")
dofile(modpath.."/furnaces.lua")