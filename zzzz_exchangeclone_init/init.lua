-- The z's at the beginning of this mod's name (zzzz_exchangeclone_init) are to ensure that it
-- loads first, since Minetest loads mods in reverse alphabetical order. I've seen a GitHub
-- PR or issue or something that would *randomize* the mod load order, which makes no sense
-- and would break several mods.

---@class exchangeclone
exchangeclone = {recipes = {}}

if (not core.get_modpath("mcl_core")) and (not core.get_modpath("default")) then
    error("ExchangeClone requires Minetest Game, MineClone2, or Mineclonia (and possibly variant subgames).\nPlease use one of those games.")
end

-- Ensure that value is either true or nil
if core.get_game_info().id == "mineclonia" then exchangeclone.mcla = true end
if core.get_game_info().id == "mineclone2" then exchangeclone.mcl2 = true end
if exchangeclone.mcl2 or exchangeclone.mcla then exchangeclone.mcl = true end
if not exchangeclone.mcl then exchangeclone.mtg = true end

exchangeclone.pipeworks = core.get_modpath("pipeworks")
exchangeclone.keep_data = core.settings:get_bool("exchangeclone.keep_data", false)

local modpath = core.get_modpath(core.get_current_modname())
dofile(modpath.."/early_lib.lua")

-- Override crafting
local old_func = core.register_craft
---@diagnostic disable-next-line: duplicate-set-field
function core.register_craft(data, ...)
    local itemstring = ItemStack(data.output):get_name()
    local allowed = true
    -- Skip thousands of banner recipes in MCL/VL
    -- This does mean that if other banner recipes exist that don't use wool (or carpet),
    -- they will be ignored in MCL/VL... but I can't think of a better way to do this.
    if exchangeclone.mcl then
        if itemstring:sub(1, #"mcl_banners:") == "mcl_banners:" then
            allowed = false
            --if data.output == "mcl_banners:banner_item_green" then core.log(dump(data.recipe)) end
            if (not data.type) or data.type == "shaped" then
                for _, row in ipairs(data.recipe) do
                    for _, item in ipairs(row) do
                        if item:sub(1, #"mcl_wool:") == "mcl_wool:" then
                            allowed = true
                            break
                        end
                    end
                    if allowed then break end
                end
            end
        end
    end
    if allowed then
        exchangeclone.register_craft(data)
    end
    old_func(data, ...)
end

exchangeclone.register_craft_type("shaped", "shaped")
exchangeclone.register_craft_type("shapeless", "shapeless")
exchangeclone.register_craft_type("cooking", "cooking")

if core.get_modpath("technic") then
    exchangeclone.register_craft_type("technic", "shapeless")
    function exchangeclone.register_technic_recipe(typename, recipe)
        local data = technic.recipes[typename]
        if data.output_size == 1 then
            local result = {recipe = recipe.input, output = recipe.output, type = "technic"}
            exchangeclone.register_craft(result)
        end
    end
end

dofile(modpath.."/base_emc_values.lua")