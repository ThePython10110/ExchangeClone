if not exchangeclone then
	error("Disable and re-enable the ExchangeClone modpack.")
end

minetest.log("action", "ExchangeClone: Registering own stuff")

-- Decides what mod to use for sounds
exchangeclone.sound_mod = exchangeclone.mcl and mcl_sounds or default

local modpath = minetest.get_modpath("exchangeclone")

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

minetest.log("action", "ExchangeClone: Done.")

minetest.register_on_mods_loaded(function()
	local start_time = minetest.get_us_time()
	minetest.log("action", "ExchangeClone: Registering energy values")
	dofile(modpath.."/register_energy.lua")
	local total_time = minetest.get_us_time() - start_time
	minetest.log("action", "ExchangeClone: Done registering energy values ("..total_time.." microseconds)")
end)