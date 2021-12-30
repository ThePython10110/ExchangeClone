local default_path = minetest.get_modpath("element_exchange")

function get_item_energy(name)
    return minetest.registered_items[name].energy_value or 1
end

dofile(default_path.."/config.lua")
dofile(default_path.."/constructor.lua")
dofile(default_path.."/deconstructor.lua")
dofile(default_path.."/energy_collector.lua")
dofile(default_path.."/energy.lua")
dofile(default_path.."/orb.lua")
