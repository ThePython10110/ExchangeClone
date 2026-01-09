local modpath = core.get_modpath(core.get_current_modname())

local files = {
    "axes",
    "hammers",
    "hoes",
    "pickaxes",
    "red_matter_multitools",
    "shovels",
    "swords"
}

for _, file in ipairs(files) do
	dofile(modpath.."/"..file..".lua")
end

if exchangeclone.mcl then
	dofile(modpath.."/shears.lua")
end