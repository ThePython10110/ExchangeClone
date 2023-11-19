dofile(minetest.get_modpath("_exchangeclone_energy").."/energy_values.lua")

local function get_cheapest_recipe(recipes)
    if not recipes then return end
    local cheapest
    for _, recipe in ipairs(recipes) do
        local ingredient_cost = 0
        local output_count = ItemStack(recipe.output):get_count()
        local skip = false
        if not recipe.type or recipe.type == "shaped" then
            for _, row in ipairs(recipe.recipe) do
                for _, item in ipairs(row) do
                    if item ~= "" then
                        local cost = exchangeclone.get_item_energy(item)
                        if (not cost) or cost == 0 then
                            skip = item
                        else
                            ingredient_cost = ingredient_cost + cost
                        end
                    end
                end
            end
        elseif (recipe.type == "shapeless") or (recipe.type == "technic") then
            for _, item in ipairs(recipe.recipe) do
                local cost = exchangeclone.get_item_energy(item)
                if (not cost) or cost == 0 then
                    skip = item
                else
                    ingredient_cost = ingredient_cost + cost
                end
            end
        elseif recipe.type == "cooking" then
            local cost = exchangeclone.get_item_energy(recipe.recipe)
            if (not cost) or cost == 0 then
                skip = recipe.recipe
            else
                ingredient_cost = ingredient_cost + cost
            end
        end
        if recipe.replacements and not skip then
            for _, item in ipairs(recipe.replacements) do
                local cost = exchangeclone.get_item_energy(item[2])
                if (not cost) or cost == 0 then
                    skip = item
                else
                    ingredient_cost = ingredient_cost - cost
                end
            end
        end
        if not skip then
            ingredient_cost = math.floor(ingredient_cost*4/output_count)/4 -- allow .25
            if (not cheapest) or (cheapest[1] > ingredient_cost) then
                cheapest = {ingredient_cost, recipe}
            end
        end
    end
    return cheapest and cheapest[1]
end

local function set_item_energy(itemstring, energy_value)
    if not (energy_value and itemstring) then return end
    energy_value = math.floor(energy_value*4)/4 -- floor to nearest .25
    if energy_value < 0 then return end
    local def = minetest.registered_items[itemstring]
    if not def then return end
    local description = def.description or ""
    local existing_energy_value = description:find("Energy Value: ([%d%.,]+)")
    if existing_energy_value then
        description = description:gsub("Energy Value: ([%d%.,]+)", "Energy Value: "..exchangeclone.format_number(energy_value))
    else
        if description[#description] ~= "\n" then
            description = description.."\n"
        end
        description = description.."Energy Value: "..exchangeclone.format_number(energy_value)
    end
    minetest.override_item(itemstring, {
        description = description,
        energy_value = energy_value,
    })
end

local function add_potion_energy(info)
    local base_cost = exchangeclone.get_item_energy("mcl_potions:water") or 1 --cost of water bottle
    -- TODO: Change dragon's breath when MineClone does.
    local dragon_breath_cost = exchangeclone.get_item_energy("mcl_potions:dragon_breath") or 8.5
    base_cost = math.floor(base_cost + (info.ingredient_cost / 3)) -- /3 because 3 potions/ingredient
    base_cost = base_cost + (info.custom_base_cost or (exchangeclone.get_item_energy("mcl_nether:nether_wart_item") or 24)/3)
    local splash_cost = base_cost + (exchangeclone.get_item_energy("mcl_mobitems:gunpowder") or 192)/3
    local lingering_cost = math.floor(base_cost + (dragon_breath_cost / 3))
    set_item_energy("mcl_potions:"..info.name, base_cost)
    set_item_energy("mcl_potions:"..info.name.."_splash", splash_cost)
    set_item_energy("mcl_potions:"..info.name.."_lingering", lingering_cost)
    if not info.no_arrow then
        local arrow_cost = math.floor(lingering_cost/8 + (exchangeclone.get_item_energy("mcl_bows:arrow") or 14))
        set_item_energy("mcl_potions:"..info.name.."_arrow", arrow_cost)
    end
    if info.plus then
        local plus_base_cost = base_cost + (exchangeclone.get_item_energy("mesecons:redstone") or 64)/3
        local plus_splash_cost = splash_cost + (exchangeclone.get_item_energy("mesecons:redstone") or 64)/3
        local plus_lingering_cost = lingering_cost + (exchangeclone.get_item_energy("mesecons:redstone") or 64)/3
        set_item_energy("mcl_potions:"..info.name.."_plus", plus_base_cost)
        set_item_energy("mcl_potions:"..info.name.."_plus_splash", plus_splash_cost)
        set_item_energy("mcl_potions:"..info.name.."_plus_lingering", plus_lingering_cost)
        if not info.no_arrow then
            local plus_arrow_cost = math.floor(plus_lingering_cost/8 + (exchangeclone.get_item_energy("mcl_bows:arrow") or 14))
            set_item_energy("mcl_potions:"..info.name.."_plus_arrow", plus_arrow_cost)
        end
    end
    if info.two then
        local two_base_cost = base_cost + (exchangeclone.get_item_energy("mcl_nether:glowstone_dust") or 384)/3
        local two_splash_cost = splash_cost + (exchangeclone.get_item_energy("mcl_nether:glowstone_dust") or 384)/3
        local two_lingering_cost = lingering_cost + (exchangeclone.get_item_energy("mcl_nether:glowstone_dust") or 384)/3
        set_item_energy("mcl_potions:"..info.name.."_2", two_base_cost)
        set_item_energy("mcl_potions:"..info.name.."_2_splash", two_splash_cost)
        set_item_energy("mcl_potions:"..info.name.."_2_lingering", two_lingering_cost)
        if not info.no_arrow then
            local two_arrow_cost = math.floor(two_lingering_cost/8 + (exchangeclone.get_item_energy("mcl_bows:arrow") or 14))
            set_item_energy("mcl_potions:"..info.name.."_2_arrow", two_arrow_cost)
        end
    end
end

-- Wait until all mods are loaded (to make sure all nodes have been registered)
-- This is much easier than making it depend on every single mod.
-- Actually, I'm kind of surprised that override_item still works...
minetest.register_on_mods_loaded(function()
    minetest.log("action", "ExchangeClone: Registering energy values")
    local auto = {}

    local groupnames = {}
    for index, group in ipairs(exchangeclone.group_values) do
        groupnames[#groupnames + 1] = group[1] --Get list of group names
    end
    local grouped_items = exchangeclone.get_group_items(groupnames, true, true)
    for index, group in ipairs(exchangeclone.group_values) do
        for i, item in pairs(grouped_items[group[1]]) do
            set_item_energy(item, group[2])
        end
    end

    if exchangeclone.mcl then
        for i = 0, 31 do
            exchangeclone.register_energy_alias("mcl_compass:18", "mcl_compass:"..i)
        end
        for i = 0, 63 do
            exchangeclone.register_energy_alias("mcl_clock:clock", "mcl_clock:clock_"..i)
        end
        exchangeclone.register_energy_alias("doc_identifier:identifier_solid", "doc_identifier:identifier_liquid")
    end

    for itemstring, energy_value in pairs(exchangeclone.energy_values) do
        set_item_energy(itemstring, energy_value)
    end

    for itemstring, def in pairs(minetest.registered_items) do
        if def.exchangeclone_custom_energy then
            set_item_energy(itemstring, def.exchangeclone_custom_energy)
        else
            local _, _, mod_name, item_name = itemstring:find("([%d_%l]+):([%d_%l]+)")
            if (
                def
                and item_name
                and mod_name
                and def.description
                and def.description ~= ""
                -- I hate recovery compasses.
                and ((minetest.get_item_group(itemstring, "not_in_creative_inventory") < 1) or (mod_name == "mcl_compass"))
                and (not exchangeclone.get_item_energy(itemstring))
                and (itemstring:sub(1,12) ~= "mcl_potions:")
                -- This does mean that other items in mcl_potions will be ignored unless explicitly specified,
                -- and items that are in groups mentioned above.
            ) then
                auto[itemstring] = true
            end
        end
    end

    -- handle aliases in exchangeclone.recipes
    for itemstring, recipes in pairs(exchangeclone.recipes) do
        local new_name = ItemStack(itemstring):get_name()
        if new_name ~= itemstring then
            exchangeclone.recipes[new_name] = recipes
        end
    end

    for i = 1, exchangeclone.num_passes do
        minetest.log("action", "ExchangeClone: \tPASS #"..i..":")
        if auto == {} then break end
        for itemstring, _ in pairs(auto) do
            local cheapest = get_cheapest_recipe(exchangeclone.recipes[itemstring])
            if cheapest then
                set_item_energy(itemstring, cheapest)
                auto[itemstring] = nil
            end
        end
    end

    --minetest.log(dump(auto))

    if exchangeclone.mcl then
        for _, info in ipairs(exchangeclone.mcl_potion_data) do
            add_potion_energy(info)
        end
        for _, state in ipairs({"exposed", "weathered", "oxidized"}) do
            set_item_energy("mcl_copper:block_"..state, exchangeclone.get_item_energy("mcl_copper:block"))
        end
        -- Concrete and banners/shields (don't remember why the shields don't work)
        for _, color in ipairs({"red", "orange", "yellow", "green", "dark_green", "cyan", "light_blue", "blue", "purple", "magenta", "pink", "black", "white", "silver", "grey", "brown"}) do
            set_item_energy("mcl_colorblocks:concrete_"..color, exchangeclone.get_item_energy("mcl_colorblocks:concrete_powder_"..color) or 2)
            set_item_energy("mcl_shields:shield_"..color, (exchangeclone.get_item_energy("mcl_banners:banner_item_"..color) or 340) + (exchangeclone.get_item_energy("mcl_shields:shield") or 304))
        end
        -- Enchanted/netherite tools
        for name, def in pairs(minetest.registered_items) do
            if def._mcl_enchanting_enchanted_tool then
                exchangeclone.register_energy_alias(name, def._mcl_enchanting_enchanted_tool)
            end
            if def._mcl_upgrade_item then
                if not name:find("enchanted") then
                    set_item_energy(def._mcl_upgrade_item, (exchangeclone.get_item_energy(name) or 0)+(exchangeclone.get_item_energy("mcl_nether:netherite_ingot") or 73728))
                end
            end
        end
        -- Recovery compasses use a random compass frame for the crafting recipe... Incredibly irritating.
        for i = 0, 31 do
            if exchangeclone.get_item_energy("mcl_compass:"..i.."_recovery") then
                minetest.log(i)
                for j = 0, 31 do
                    exchangeclone.register_energy_alias("mcl_compass:"..i.."_recovery", "mcl_compass:"..j.."_recovery")
                end
                break
            end
        end
    end

    -- Adds energy values to aliased items, even though they're not used (just so it's displayed)
    for alias, itemstring in pairs(exchangeclone.energy_aliases) do
        set_item_energy(alias, exchangeclone.get_item_energy(itemstring))
    end

    -- Free up memory (I assume this will do that?)
    exchangeclone.recipes = nil
    exchangeclone.energy_values = nil
    minetest.log("action", "ExchangeClone: Done registering energy values.")
end)