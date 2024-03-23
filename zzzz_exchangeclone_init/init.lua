-- The z's at the beginning of this mod's name (zzzz_exchangeclone_init) are to ensure that it
-- loads first, since Minetest loads mods in reverse alphabetical order.

exchangeclone = {recipes = {}}

-- detect games:
-- don't use minetest.get_game_info().id because that returns the name of
-- the folder the game is stored in, which users can name whatever they like.

-- Ensure that game identifier values are either true or nil
if minetest.get_modpath("mcl_core") then
    -- mineclonia makes a big deal about excluding hamburgers, but you could add mineclone2's copy
    local has_mcl_hamburger = minetest.get_modpath("mcl_hamburger")
    local has_mcl_base_textures = minetest.get_modpath("mcl_base_textures")
    local has_mcl_playerplus = minetest.get_modpath("mcl_playerplus")
    if has_mcl_hamburger and has_mcl_playerplus then
        exchangeclone.mcl2 = true
    elseif has_mcl_base_textures then
        exchangeclone.mcla = true
    else
        minetest.log("warning", "[ExchangeClone] unable to determine if you're running MineClonia or MineClone2")
    end
    exchangeclone.mcl = true
elseif minetest.get_modpath("exile_env_sounds") then
    exchangeclone.exile = true
elseif minetest.get_modpath("default") then
    exchangeclone.mtg = true
else
    error("ExchangeClone requires Minetest Game, Exile, MineClone2, or MineClonia (and possibly variant subgames).\n" ..
        "Please use one of those games.")
end

exchangeclone.pipeworks = minetest.get_modpath("pipeworks")
exchangeclone.keep_data = minetest.settings:get_bool("exchangeclone.keep_data", false)

local modpath = minetest.get_modpath("zzzz_exchangeclone_init")
dofile(modpath.."/lib.lua")

-- Override crafting
local old_func = minetest.register_craft
function minetest.register_craft(data, ...)
    local itemstring = ItemStack(data.output):get_name()
    local allowed = true
    -- Skip thousands of banner recipes in MCL2
    -- This does mean that if other banner recipes exist that don't use wool (or carpet),
    -- they will be ignored in MCL2... but I can't think of a better way to do this.
    if exchangeclone.mcl then
        if itemstring:sub(1, #"mcl_banners:") == "mcl_banners:" then
            allowed = false
            --if data.output == "mcl_banners:banner_item_green" then minetest.log(dump(data.recipe)) end
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

if minetest.get_modpath("technic") then
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