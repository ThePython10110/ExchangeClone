exchangeclone = {}
if (not minetest.get_modpath("mcl_core")) and (not minetest.get_modpath("default")) then
    error("ExchangeClone requires 'default' or 'mcl_core,' but Minetest doesn't let me mark one or the other as a dependency.")
else
	exchangeclone.mineclone = minetest.get_modpath("mcl_core")
end

exchangeclone.energy_max = 51200000 -- Max capacity of Klein Star Omega

local default_path = minetest.get_modpath("exchangeclone")

exchangeclone.collector_speed = minetest.settings:get("exchangeclone.energy_collector_speed") or 5

dofile(default_path.."/lib.lua")
dofile(default_path.."/constructor.lua")
dofile(default_path.."/deconstructor.lua")
dofile(default_path.."/energy_collector.lua")
dofile(default_path.."/orb.lua")
dofile(default_path.."/craftitems.lua")
if exchangeclone.mineclone or minetest.get_modpath("3d_armor") then
	dofile(default_path.."/armor.lua")
end
dofile(default_path.."/multidig.lua")
if exchangeclone.mineclone then
	mcl_item_id.set_mod_namespace("exchangeclone")
	dofile(default_path.."/shears.lua")
end
dofile(default_path.."/swords.lua")
dofile(default_path.."/axes.lua")
dofile(default_path.."/hoes.lua")
dofile(default_path.."/pickaxes.lua")
dofile(default_path.."/hammers.lua")
dofile(default_path.."/shovels.lua")
dofile(default_path.."/red_matter_multitools.lua")
dofile(default_path.."/philosophers_stone.lua")
dofile(default_path.."/pesa.lua")
dofile(default_path.."/transmutation_tablet.lua")
dofile(default_path.."/energy.lua")