-- Finally organized this somewhat.

local files = {
    "aliases",
    "cooldowns",
    "digging",
    "emc",
    "get_drops",
    "item_transfer",
    "nodes",
    "passives",
    "tool_utils",
    "utils",
    "values"
}

local modpath = core.get_modpath(core.get_current_modname())
for _, file in pairs(files) do dofile(modpath.."/"..file..".lua") end