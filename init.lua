exchangeclone = {}
if (not minetest.get_modpath("mcl_core")) and (not minetest.get_modpath("default")) then
    error("ExchangeClone requires 'default' or 'mcl_core,' but Minetest doesn't let me mark one or the other as a dependency.")
elseif minetest.get_modpath("mcl_core") then
    exchangeclone["mineclone"] = true
    minetest.log("Loading ExchangeClone with MineClone configuration")
else
    exchangeclone["mineclone"] = false
    minetest.log("Loading ExchangeClone with MTG configuration")
end

local default_path = minetest.get_modpath("exchangeclone")

function get_item_energy(name)
    return minetest.registered_items[name].energy_value or 1
end

dofile(default_path.."/config.lua")
dofile(default_path.."/constructor.lua")
dofile(default_path.."/deconstructor.lua")
dofile(default_path.."/energy_collector.lua")
dofile(default_path.."/energy.lua")
dofile(default_path.."/orb.lua")
