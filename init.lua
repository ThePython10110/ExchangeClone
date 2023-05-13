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

function exchangeclone.get_inventory_drops(pos, inventory, drops) --removes default dependency
	local inv = minetest.get_meta(pos):get_inventory()
	local n = #drops
	for i = 1, inv:get_size(inventory) do
		local stack = inv:get_stack(inventory, i)
		if stack:get_count() > 0 then
			drops[n+1] = stack:to_table()
			n = n + 1
		end
	end
end

local default_path = minetest.get_modpath("exchangeclone")

function exchangeclone.get_item_energy(name)
    return minetest.registered_items[name].energy_value or 1
end

exchangeclone.collector_interval = minetest.settings:get("exchangeclone.collector_interval") or 5

dofile(default_path.."/config.lua")
dofile(default_path.."/constructor.lua")
dofile(default_path.."/deconstructor.lua")
dofile(default_path.."/energy_collector.lua")
dofile(default_path.."/energy.lua")
dofile(default_path.."/orb.lua")
