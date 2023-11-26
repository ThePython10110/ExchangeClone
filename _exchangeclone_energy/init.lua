-- Registers all energy values

-- Gets lists of energy values
dofile(minetest.get_modpath("_exchangeclone_energy").."/energy_values.lua")

local function get_cheapest_recipe(recipes, log)
    if not recipes then return end
    local cheapest
    for _, recipe in ipairs(recipes) do
        local ingredient_cost = 0
        local output_count = ItemStack(recipe.output):get_count()
        local output_name = ItemStack(recipe.output):get_name()
        local skip = false
        if not recipe.type or recipe.type == "shaped" then
            for _, row in ipairs(recipe.recipe) do
                for _, item in ipairs(row) do
                    if item ~= "" then
                        if item == output_name then
                            output_count = output_count - 1
                        else
                            local cost = exchangeclone.get_item_energy(item)
                            if (not cost) or cost == 0 then
                                skip = item
                            else
                                ingredient_cost = ingredient_cost + cost
                            end
                        end
                    end
                end
            end
        elseif (recipe.type == "shapeless") or (recipe.type == "technic") then
            for _, item in ipairs(recipe.recipe) do
                if item == output_name then
                    output_count = output_count - 1
                else
                    local cost = exchangeclone.get_item_energy(item)
                    if (not cost) or cost == 0 then
                        skip = item
                    else
                        ingredient_cost = ingredient_cost + cost
                    end
                end
            end
        elseif recipe.type == "cooking" or recipe.type == "stonecutting" then
            local cost = exchangeclone.get_item_energy(recipe.recipe)
            if (not cost) or cost == 0 then
                skip = recipe.recipe
            else
                ingredient_cost = cost
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
            ingredient_cost = math.floor(ingredient_cost*20/output_count)/20 -- allow .05, won't work with huge numbers
            if (not cheapest) or (cheapest[1] > ingredient_cost) then
                cheapest = {ingredient_cost, recipe}
            end
        end
        if log then minetest.log(dump({
            recipe = recipe,
            ingredient_cost = ingredient_cost,
            output_count = output_count
        })) end
    end
    return cheapest and cheapest[1]
end

local function set_item_energy(itemstring, energy_value)
    if not (energy_value and itemstring) then return end
    energy_value = math.floor(energy_value*20)/20 -- floor to nearest .05
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

    -- Handle stonecutter recipes
    if exchangeclone.mineclonia then
        -- TODO: Check this for every Mineclonia update
        local recipe_yield = { --maps itemgroup to the respective recipe yield, default is 1
            ["slab"] = 2,
        }
        for name, def in pairs(minetest.registered_items) do
            if def._mcl_stonecutter_recipes then
                local yield = 1
                for k,v in pairs(recipe_yield) do if minetest.get_item_group(name,k) > 0 then yield = v end end
                for _, result in pairs(def._mcl_stonecutter_recipes) do
                    if minetest.get_item_group(name,"not_in_creative_inventory") == 0 then
                        if not exchangeclone.recipes[result] then exchangeclone.recipes[result] = {} end
                        table.insert(exchangeclone.recipes[result],{output = name.." "..yield, type = "stonecutting", recipe = result})
                    end
                end
            end
        end
    end

    local auto = {}

    -- Register group energy values
    local groupnames = {}
    for _, group in ipairs(exchangeclone.group_values) do
        groupnames[#groupnames + 1] = group[1] --Get list of group names
    end
    local grouped_items = exchangeclone.get_group_items(groupnames, true, true)
    for _, group in ipairs(exchangeclone.group_values) do
        for _, item in pairs(grouped_items[group[1]]) do
            item = exchangeclone.handle_alias(item)
            set_item_energy(item, group[2])
        end
    end

    -- Register energy aliases and certain energy values
    if exchangeclone.mcl then
        for i = 0, 31 do
            exchangeclone.register_energy_alias("mcl_compass:18", "mcl_compass:"..i)
            exchangeclone.register_energy_alias("mcl_compass:18", "mcl_compass:"..i.."_lodestone")
        end
        for i = 0, 63 do
            exchangeclone.register_energy_alias("mcl_clock:clock", "mcl_clock:clock_"..i)
        end
        exchangeclone.register_energy_alias("doc_identifier:identifier_solid", "doc_identifier:identifier_liquid")
        exchangeclone.register_energy_alias("mcl_books:writable_book", "mcl_books:written_book")

        for _, coral_type in ipairs({"brain", "bubble", "fire", "horn", "tube"}) do
            for thing, value in pairs({[coral_type.."_coral"] = 16, [coral_type.."_coral_block"] = 64, [coral_type.."_coral_fan"] = 16}) do
                set_item_energy("mcl_ocean:"..thing, value)
                set_item_energy("mcl_ocean:dead_"..thing, value/16)
            end
        end
    end

    for itemstring, energy_value in pairs(exchangeclone.energy_values) do
        set_item_energy(itemstring, energy_value)
    end

    if exchangeclone.mcl then
        local cheapest = get_cheapest_recipe(exchangeclone.recipes["mcl_copper:block"])
        if cheapest then
            set_item_energy("mcl_copper:block", cheapest)
            minetest.log(cheapest)
            minetest.log(dump(exchangeclone.get_item_energy("mcl_copper:block")))
        end
        for _, state in ipairs({"exposed", "weathered", "oxidized"}) do
            set_item_energy("mcl_copper:block_"..state, exchangeclone.get_item_energy("mcl_copper:block"))
        end
        
    end

    -- handle aliases in exchangeclone.recipes
    for itemstring, recipes in pairs(exchangeclone.recipes) do
        local new_name = exchangeclone.handle_alias(itemstring)
        if new_name ~= itemstring then
            exchangeclone.recipes[new_name] = recipes
        end
    end

    -- Should energy values be automatically registered?
    for itemstring, def in pairs(minetest.registered_items) do
        itemstring = exchangeclone.handle_alias(itemstring) or itemstring
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
                and exchangeclone.recipes[itemstring]
                -- This does mean that other items in mcl_potions will be ignored unless explicitly specified,
                -- and items that are in groups mentioned above.
            ) then
                auto[itemstring] = true
            end
        end
    end

    for i = 1, exchangeclone.num_passes do
        minetest.log("action", "ExchangeClone: \tPASS #"..i)
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
        exchangeclone.mcl_potion_data = exchangeclone.mcl_potion_data or {}
        table.insert_all(exchangeclone.mcl_potion_data, { -- automatically assumes base cost is awkward potion if not specified
            {name = "water", ingredient_cost = 0, custom_base_cost = 0, no_arrow = true},
            {name = "awkward", ingredient_cost = 0, no_arrow = true},
            {name = "fire_resistance", ingredient_cost = 768, plus = true},
            {name = "poison", ingredient_cost = 128, plus = true, two = true},
            {name = "harming", ingredient_cost = 192, custom_base_cost = 52, two = true},
            {name = "healing", ingredient_cost = 1852, two = true},
            {name = "leaping", ingredient_cost = 64, plus = true, two = true},
            {name = "mundane", ingredient_cost = 32, no_arrow = true, custom_base_cost = 0},
            {name = "night_vision", ingredient_cost = 1840, plus = true},
            {name = "regeneration", ingredient_cost = 4096, plus = true, two = true},
            {name = "slowness", ingredient_cost = 192, custom_base_cost = 20, plus = true, two = true},
            {name = "swiftness", ingredient_cost = 32, plus = true, two = true},
            {name = "thick", ingredient_cost = 384, no_arrow = true, custom_base_cost = 0},
            {name = "water_breathing", ingredient_cost = 64, plus = true},
            {name = "invisibility", ingredient_cost = 192, custom_base_cost = 623, plus = true},
            {name = "withering", ingredient_cost = 128, plus = true, two = true}
        })
        for _, info in ipairs(exchangeclone.mcl_potion_data) do
            add_potion_energy(info)
        end
        -- Concrete and banners/shields (don't remember why the shields don't work)
        for _, color in ipairs({"red", "orange", "yellow", "lime", "dark_green", "cyan", "light_blue", "blue", "purple", "magenta", "pink", "black", "white", "silver", "grey", "brown"}) do
            set_item_energy("mcl_colorblocks:concrete_"..color, exchangeclone.get_item_energy("mcl_colorblocks:concrete_powder_"..color) or 2)
            set_item_energy("mcl_stairs:stair_concrete_"..color, get_cheapest_recipe(exchangeclone.recipes["mcl_stairs:stair_concrete_"..color]))
            set_item_energy("mcl_stairs:slab_concrete_"..color, get_cheapest_recipe(exchangeclone.recipes["mcl_stairs:slab_concrete_"..color]))
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