exchangeclone = {}
if (not minetest.get_modpath("mcl_core")) and (not minetest.get_modpath("default")) then
    error("ExchangeClone requires 'default' or 'mcl_core,' but Minetest doesn't let me mark one or the other as a dependency.")
else
	exchangeclone.mineclone = minetest.get_modpath("mcl_core")
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
    return minetest.registered_items[name].energy_value
end

exchangeclone.collector_speed = minetest.settings:get("exchangeclone.energy_collector_speed") or 5

dofile(default_path.."/constructor.lua")
dofile(default_path.."/deconstructor.lua")
dofile(default_path.."/energy_collector.lua")
dofile(default_path.."/orb.lua")
dofile(default_path.."/craftitems.lua")
dofile(default_path.."/tools.lua")
if exchangeclone.mineclone then
	dofile(default_path.."/shears.lua")
end
dofile(default_path.."/swords.lua")
dofile(default_path.."/philosophers_stone.lua")
dofile(default_path.."/pesa.lua")
dofile(default_path.."/energy.lua")