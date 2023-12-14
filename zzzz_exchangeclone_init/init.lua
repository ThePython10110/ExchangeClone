exchangeclone = {recipes = {}, base_energy_values = {}, group_values = {}}

-- Override crafting
local old_func = minetest.register_craft
function minetest.register_craft(data, ...)
    if data and data.output then
        local itemstring = ItemStack(data.output):get_name()
        exchangeclone.recipes[itemstring] = exchangeclone.recipes[itemstring] or {}
        table.insert(exchangeclone.recipes[itemstring], table.copy(data))
        --[[ -- reverse cooking recipes too
        if arg.type == "cooking" then
            itemstring = ItemStack(arg.recipe):get_name()
            local reverse_arg = table.copy(arg)
            reverse_arg.recipe, reverse_arg.output = reverse_arg.output, reverse_arg.recipe
            exchangeclone.recipes[itemstring] = exchangeclone.recipes[itemstring] or {}
            table.insert(exchangeclone.recipes[itemstring], table.copy(reverse_arg))
        end --]]
    end
    old_func(data, ...)
end

if (not minetest.get_modpath("mcl_core")) and (not minetest.get_modpath("default")) then
    error("ExchangeClone requires Minetest Game, MineClone2, or MineClonia (and possibly other spinoffs).\nPlease use one of those games.")
else
	exchangeclone.mcl = minetest.get_modpath("mcl_core")
end

exchangeclone.mineclonia = minetest.get_game_info().id == "mineclonia" -- if exchangeclone.mineclonia, exchangeclone.mcl is also defined.
exchangeclone.pipeworks = minetest.get_modpath("pipeworks")
exchangeclone.orb_max = 51200000 -- Max capacity of Klein Star Omega in ProjectE
exchangeclone.orb_max = minetest.settings:get("exchangeclone.orb_max") or 51200000

local modpath = minetest.get_modpath("zzzz_exchangeclone_init")
dofile(modpath.."/lib.lua")

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

dofile(modpath.."/base_energy_values.lua")