local modpath = core.get_modpath(core.get_current_modname())

local files = {
    "amulets",
    "black_hole_band",
    "gem_of_eternal_density",
    "infinite_food",
    "passive_stones",
    "rings",
    "talisman_of_repair",
}

for _, file in pairs(files) do dofile(modpath.."/"..file..".lua") end