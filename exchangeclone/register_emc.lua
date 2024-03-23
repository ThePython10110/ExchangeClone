local exchangeclone = exchangeclone

-- Calculates the cheapest recipe given an itemstring.
-- Would probably benefit from another function, since there's quite a bit
-- of duplicate code.
local function get_cheapest_recipe(itemstring, log)
    itemstring = ItemStack(itemstring):get_name()
    local recipes = exchangeclone.recipes[itemstring]
    if not recipes then return end
    local cheapest
    for _, recipe in pairs(recipes) do
        local ingredient_cost = 0
        local output_count = ItemStack(recipe.output):get_count()
        local skip = false
        local identical_replacements = {}
        if recipe.replacements then
            for _, replacement in pairs(recipe.replacements) do
                if replacement[1] == replacement[2] then
                    identical_replacements[replacement[1]] = (identical_replacements[replacement[1]] or 0) + 1
                end
            end
        end
        if not recipe.type or exchangeclone.craft_types[recipe.type].type == "shaped" then
            for _, row in pairs(recipe.recipe) do
                for _, item in pairs(row) do
                    if item ~= "" then
                        if item == itemstring then
                            output_count = math.max(0, output_count - 1)
                        else
                            local replaced = identical_replacements[item]
                            if replaced and replaced > 0 then
                                identical_replacements[item] = replaced - 1
                            else
                                local cost = exchangeclone.get_item_emc(item)
                                if (not cost) or cost == 0 then
                                    skip = item
                                else
                                    ingredient_cost = ingredient_cost + cost
                                end
                            end
                        end
                    end
                end
            end
        elseif exchangeclone.craft_types[recipe.type].type == "shapeless" then
            for _, item in pairs(recipe.recipe) do
                if item ~= "" then
                    if item == itemstring then
                        output_count = math.max(0, output_count - 1)
                    else
                        local replaced = identical_replacements[item]
                        if replaced and replaced > 0 then
                            identical_replacements[item] = replaced - 1
                        else
                            local cost = exchangeclone.get_item_emc(item)
                            if (not cost) or cost == 0 then
                                skip = item
                            else
                                ingredient_cost = ingredient_cost + cost
                            end
                        end
                    end
                end
            end
        elseif exchangeclone.craft_types[recipe.type].type == "cooking" then
            local item = recipe.recipe
            if item ~= "" then
                if item == itemstring then
                    output_count = math.max(0, output_count - 1)
                else
                    local replaced = identical_replacements[item]
                    if replaced and replaced > 0 then
                        identical_replacements[item] = replaced - 1
                    else
                        local cost = exchangeclone.get_item_emc(item)
                        if (not cost) or cost == 0 then
                            skip = item
                        else
                            ingredient_cost = ingredient_cost + cost
                        end
                    end
                end
            end
        elseif exchangeclone.craft_types[recipe.type].type == "emc" then
            ingredient_cost = recipe.recipe
        end
        if recipe.replacements and not skip then
            for _, item in pairs(recipe.replacements) do
                if item[1] ~= item[2] then
                    local cost = exchangeclone.get_item_emc(item[2])
                    if (not cost) or cost == 0 then
                        skip = item[2]
                    else
                        ingredient_cost = ingredient_cost - cost
                    end
                end
            end
        end
        if output_count < 1 then skip = true end
        if not skip then
            local total_cost = math.floor(ingredient_cost*20/math.max(1, output_count))/20 -- allow .05, won't work with huge numbers
            if (not cheapest) or (cheapest[1] > total_cost) then
                cheapest = {total_cost, recipe}
            end
        end
        if log then minetest.log("action", dump({
            recipe = recipe,
            ingredient_cost = ingredient_cost,
            output_count = output_count
        })) end
    end
    return cheapest and cheapest[1]
end

exchangeclone.emc_values = {}

-- Sets the EMC value of an item, must be called during load time.
local function register_emc(itemstring, emc_value)
    if not (emc_value and itemstring) then return end
    emc_value = math.floor(emc_value*20)/20 -- floor to nearest .05
    if emc_value < 0 then return end
    local def = minetest.registered_items[itemstring]
    if not def then return end
    local description = def.description or ""

    -- Override EMC value if it already exists
    local existing_emc_value = description:find("EMC: ([%d%.,]+)")
    if existing_emc_value then
        description = description:gsub("EMC: ([%d%.,]+)", "EMC: "..exchangeclone.format_number(emc_value))
    else
        if description[#description] ~= "\n" then
            description = description.."\n"
        end
        description = description.."EMC: "..exchangeclone.format_number(emc_value)
    end
    minetest.override_item(itemstring, {
        description = description,
        emc_value = emc_value,
    })
    if emc_value > 0 then
        exchangeclone.emc_values[itemstring] = emc_value
    else
        exchangeclone.emc_values[itemstring] = nil
    end
end

local auto = {}

if exchangeclone.exile then
    local seen_unknown_crafting_types = {}
    local did_cooking_warning = false
    local replacements_actions = {}
    -- Exile doesn't have lava buckets and uses an alternative,
    -- so just eat the input item
    replacements_actions[dump({{
        exchangeclone.itemstrings.lava_bucket,
        exchangeclone.itemstrings.empty_bucket,
    }})] = {just_eat_input = true}
    -- we're already using a philosopher's stone to do the crafting,
    -- don't add to recipe so we don't need two
    replacements_actions[dump({{
        "exchangeclone:philosophers_stone",
        "exchangeclone:philosophers_stone",
    }})] = {remove_from_input = "exchangeclone:philosophers_stone"}
    -- used for recipe for iron band -- crafting mod doesn't support
    -- replacements, there is another recipe for the iron band,
    -- so just ignore the recipe
    replacements_actions[dump({{
        "exchangeclone:volcanite_amulet",
        "exchangeclone:volcanite_amulet",
    }})] = {ignore_recipe = true}
    local replacement_itemstrings = {
        ["group:tree"] = "group:log",
    }
    for _, recipes in pairs(exchangeclone.recipes) do
        for _, recipe in ipairs(recipes) do
            local mt_craft_type = recipe.type and exchangeclone.craft_types[recipe.type].type
            if not mt_craft_type or mt_craft_type == "shaped" or mt_craft_type == "shapeless" then
                ---@type table<string, integer>
                local item_counts = {}
                local remove_from_input = nil
                local ignore_recipe = false
                if recipe.replacements then
                    local replacements_value = dump(recipe.replacements)
                    local replacements_action = replacements_actions[replacements_value]
                    assert(replacements_action, "[ExchangeClone] unimplemented replacements style: "..replacements_value)
                    if replacements_action.remove_from_input then
                        remove_from_input = replacements_action.remove_from_input
                    elseif replacements_action.ignore_recipe then
                        ignore_recipe = true
                    else
                        assert(replacements_action.just_eat_input, "unhandled replacements_action"..dump(replacements_action))
                    end
                end
                local worklist = table.copy(recipe.recipe)
                while #worklist > 0 do
                    local item = table.remove(worklist)
                    if type(item) == "table" then
                        for _, v in ipairs(item) do
                            table.insert(worklist, v)
                        end
                    elseif item and item ~= remove_from_input and item ~= "" then
                        local count = item_counts[item] or 0
                        item_counts[item] = count + 1
                    end
                end
                local items_array = {}
                for itemstring, count in pairs(item_counts) do
                    itemstring = replacement_itemstrings[itemstring] or itemstring
                    local item = ItemStack(itemstring)
                    item:set_count(count)
                    if not itemstring:find("^group:") and not item:is_known() then
                        ignore_recipe = true
                        break
                    end
                    assert(item:to_string() ~= "", dump({itemstring=itemstring,count=count,recipe=recipe}))
                    table.insert(items_array, item:to_string())
                end
                if not ignore_recipe then
                    local final_recipe = {
                        type = "exchangeclone_crafting",
                        output = recipe.output,
                        items = items_array,
                        always_known = true,
                    }
                    minetest.log("[ExchangeClone]: registered Exile crafting recipe: \n"..dump(final_recipe))
                    crafting.register_recipe(final_recipe)
                end
            elseif mt_craft_type == "cooking" then
                if not did_cooking_warning then
                    minetest.log("warning", "[ExchangeClone] cooking crafts aren't implemented for Exile, ignoring")
                end
                did_cooking_warning = true
            else
                local unknown_craft_type = dump(mt_craft_type)
                if not seen_unknown_crafting_types[unknown_craft_type] then
                    minetest.log("warning", "[ExchangeClone] unknown minetest crafting type: "..unknown_craft_type)
                end
                seen_unknown_crafting_types[unknown_craft_type] = true
            end
        end
    end
    for craft_type, recipes in pairs(crafting.recipes) do
        if craft_type ~= "exchangeclone_crafting" then
            exchangeclone.register_craft_type(craft_type, "shapeless")
            for _, orig_recipe in ipairs(recipes) do
                local recipe = {}
                for _, item in ipairs(orig_recipe.items) do
                    item = ItemStack(item)
                    for _ = 1, item:get_count() do
                        table.insert(recipe, item:get_name())
                    end
                end
                exchangeclone.register_craft({
                    type = orig_recipe.type,
                    output = orig_recipe.output,
                    recipe = recipe,
                })
            end
        end
    end
    exchangeclone.register_craft_type("thawing", "cooking", true)
    exchangeclone.register_craft({
        type = "thawing",
        output = "nodes_nature:freshwater_source",
        recipe = "nodes_nature:ice",
    })
    exchangeclone.register_craft({
        type = "thawing",
        output = "nodes_nature:salt_water_source",
        recipe = "nodes_nature:sea_ice",
    })
    exchangeclone.register_craft_type("roasting", "cooking")
    exchangeclone.register_craft({
        type = "roasting",
        output = "tech:iron_bloom",
        recipe = "tech:iron_and_slag",
    })
    exchangeclone.register_craft({
        type = "roasting",
        output = "tech:iron_and_slag",
        recipe = "tech:iron_smelting_mix",
    })
    exchangeclone.register_craft({
        type = "roasting",
        output = "tech:green_glass_ingot",
        recipe = "tech:green_glass_mix",
    })
    exchangeclone.register_craft({
        type = "roasting",
        output = "tech:clear_glass_ingot",
        recipe = "tech:clear_glass_mix",
    })
    exchangeclone.register_craft({
        type = "roasting",
        output = "tech:quicklime",
        recipe = "tech:crushed_lime",
    })
    exchangeclone.register_craft_type("melting", "shapeless")
    exchangeclone.register_craft({
        type = "melting",
        output = "tech:pane_tray_clear",
        recipe = {"tech:clear_glass_ingot", "tech:pane_tray"},
    })
    exchangeclone.register_craft({
        type = "melting",
        output = "tech:pane_tray_green",
        recipe = {"tech:green_glass_ingot", "tech:pane_tray"},
    })
    exchangeclone.register_craft_type("start_fire", "cooking")
    exchangeclone.register_craft({
        type = "start_fire",
        output = "tech:small_wood_fire",
        recipe = "tech:small_wood_fire_unlit",
    })
    exchangeclone.register_craft({
        type = "start_fire",
        output = "tech:large_wood_fire",
        recipe = "tech:large_wood_fire_unlit",
    })
    exchangeclone.register_craft({
        type = "start_fire",
        output = "tech:small_charcoal_fire",
        recipe = "tech:charcoal",
    })
    exchangeclone.register_craft({
        type = "start_fire",
        output = "tech:large_charcoal_fire",
        recipe = "tech:charcoal_block",
    })
    exchangeclone.register_craft_type("extinguish_fire", "cooking", true)
    exchangeclone.register_craft({
        type = "extinguish_fire",
        output = "tech:small_wood_fire_ext",
        recipe = "tech:small_wood_fire",
    })
    exchangeclone.register_craft({
        type = "extinguish_fire",
        output = "tech:large_wood_fire_ext",
        recipe = "tech:large_wood_fire",
    })
    exchangeclone.register_craft({
        type = "extinguish_fire",
        output = "tech:small_charcoal_fire_ext",
        recipe = "tech:small_charcoal_fire",
    })
    exchangeclone.register_craft({
        type = "extinguish_fire",
        output = "tech:large_charcoal_fire_ext",
        recipe = "tech:large_charcoal_fire",
    })
    exchangeclone.register_craft_type("to_smoldering", "cooking", true)
    exchangeclone.register_craft({
        type = "to_smoldering",
        output = "tech:small_wood_fire_smoldering",
        recipe = "tech:small_wood_fire",
    })
    exchangeclone.register_craft({
        type = "to_smoldering",
        output = "tech:large_wood_fire_smoldering",
        recipe = "tech:large_wood_fire",
    })
    exchangeclone.register_craft({
        type = "to_smoldering",
        output = "tech:small_charcoal_fire_smoldering",
        recipe = "tech:small_charcoal_fire",
    })
    exchangeclone.register_craft({
        type = "to_smoldering",
        output = "tech:large_charcoal_fire_smoldering",
        recipe = "tech:large_charcoal_fire",
    })

    exchangeclone.register_craft_type("hammer_place", "cooking")
    exchangeclone.register_craft({
        type = "hammer_place",
        output = "tech:hammer_basalt_placed",
        recipe = "tech:hammer_basalt",
    })
    exchangeclone.register_craft({
        type = "hammer_place",
        output = "tech:hammer_granite_placed",
        recipe = "tech:hammer_granite",
    })
    exchangeclone.register_craft_type("retting", "cooking")
    exchangeclone.register_craft({
        type = "retting",
        output = "tech:retted_cana_bundle",
        recipe = "tech:unretted_cana_bundle",
    })
    local extended_sed_list = table.copy(sed_list)
    local artificial_seds = {broken_pottery_block = {mod_name = 'tech'}}
    for name, _ in pairs(artificial_seds) do
        table.insert(extended_sed_list, {name})
    end
    local water_pots = {
        "tech:clay_water_pot",
        "tech:wooden_water_pot",
        "tech:glass_bottle_green",
        "tech:glass_bottle_clear",
    }
    local wetnesses = {
        [""] = {water_pot_suffix = "", source = ""},
        ["_wet"] = {water_pot_suffix = "_freshwater", source = "nodes_nature:freshwater_source"},
        ["_wet_salty"] = {water_pot_suffix = "_salt_water", source = "nodes_nature:salt_water_source"},
    }
    local ag_soils = {
        {ag = "", depleted = ""},
        {ag = "_agricultural_soil", depleted = ""},
        {ag = "_agricultural_soil", depleted = "_depleted"},
    }
    exchangeclone.register_craft_type("make_ag_depleted", "cooking")
    exchangeclone.register_craft_type("ag_soil_to_soil", "cooking")
    exchangeclone.register_craft_type("wetten", "shapeless")
    for _, v in ipairs(extended_sed_list) do
        local name = v[1]
        local mod_name = "nodes_nature"
        if artificial_seds[name] then
            mod_name = artificial_seds[name].mod_name
        end
        for wetness, wetness_data in pairs(wetnesses) do
            for _, ag_soil in ipairs(ag_soils) do
                if wetness == "_wet" or (wetness == "_wet_salty" and ag_soil.ag == "") then
                    exchangeclone.register_craft({
                        type = "wetten",
                        output = mod_name..":"..name..ag_soil.ag..wetness..ag_soil.depleted,
                        recipe = {
                            mod_name..":"..name..ag_soil.ag..ag_soil.depleted,
                            water_pots[1]..wetness_data.water_pot_suffix,
                        },
                        replacements = {{water_pots[1]..wetness_data.water_pot_suffix, water_pots[1]}},
                    })
                end
            end
            if wetness ~= "_wet_salty" then
                exchangeclone.register_craft({
                    type = "make_ag_depleted",
                    output = mod_name..":"..name.."_agricultural_soil"..wetness.."_depleted",
                    recipe = mod_name..":"..name..wetness,
                })
            end
        end
    end
    exchangeclone.register_craft_type("fill_water_pot", "shapeless")
    for wetness, wetness_data in pairs(wetnesses) do
        if wetness ~= "" then
            for _, water_pot in ipairs(water_pots) do
                exchangeclone.register_craft({
                    type = "fill_water_pot",
                    output = water_pot..wetness_data.water_pot_suffix,
                    recipe = {
                        water_pot,
                        wetness_data.source,
                    },
                })
            end
        end
    end
    for _, v in ipairs(soil_list) do
        local name = v[1]
        local sed_name = v[4]
        for wetness, wetness_data in pairs(wetnesses) do
            if wetness ~= "_wet_salty" then
                exchangeclone.register_craft({
                    type = "ag_soil_to_soil",
                    output = "nodes_nature:"..name..wetness,
                    recipe = "nodes_nature:"..sed_name.."_agricultural_soil"..wetness,
                })
            end
        end
    end
end

-- Handle stonecutter recipes and decaychains in Mineclonia
if exchangeclone.mcla then
    exchangeclone.register_craft_type("stonecutting", "cooking")
    -- TODO: Check recipe_yield for every Mineclonia update
    local recipe_yield = { --maps itemgroup to the respective recipe yield, default is 1
        ["slab"] = 2,
        ["cut_copper"] = 4,
    }
    for result, def in pairs(minetest.registered_items) do
        if minetest.get_item_group(result,"not_in_creative_inventory") == 0 then
            if def._mcl_stonecutter_recipes then
                for _, source in pairs(def._mcl_stonecutter_recipes) do
                    local yield = 1
                    for k,v in pairs(recipe_yield) do if minetest.get_item_group(result,k) > 0 then yield = v end end
                    exchangeclone.register_craft({output = result.." "..yield, type = "stonecutting", recipe = source})
                end
            end
        end
    end

    if mcl_copper then
        exchangeclone.register_craft_type("decaychain", "cooking")
        exchangeclone.register_craft_type("preserving", "cooking")
        local decaychains = mcl_copper.registered_decaychains
        for name, data in pairs(decaychains) do
            for i, itemstring in ipairs(data.nodes) do
                if minetest.get_item_group(name,"not_in_creative_inventory") == 0 then
                    local preserved_itemstring = itemstring.."_preserved"
                    exchangeclone.register_craft({output = preserved_itemstring, type = "preserving", recipe = {itemstring, "group:"..data.preserve_group}})
                    if i > 1 then
                        exchangeclone.register_craft({output = itemstring, type = "decaychain", recipe = data.nodes[i-1]})
                    end
                end
            end
        end
    end
end

-- Register clock/compass aliases, handle enchanted/netherite stuff, potions, and concrete, and register coral EMC values
if exchangeclone.mcl then
    for i = 0, 31 do
        exchangeclone.register_alias("mcl_compass:18", "mcl_compass:"..i)
        exchangeclone.register_alias("mcl_compass:18", "mcl_compass:"..i.."_lodestone")
    end
    for i = 0, 63 do
        exchangeclone.register_alias("mcl_clock:clock", "mcl_clock:clock_"..i)
    end
    exchangeclone.register_alias("doc_identifier:identifier_solid", "doc_identifier:identifier_liquid")
    exchangeclone.register_alias("mcl_books:writable_book", "mcl_books:written_book")
    exchangeclone.register_craft({output = "mcl_bamboo:bamboo_block_stripped", type = "cooking", recipe = "mcl_bamboo:bamboo_block"})

    -- Potions
    exchangeclone.register_craft_type("brewing", "shapeless")
    local function add_potion_recipe(info)
        if not info.bases then info.bases = {"mcl_potions:awkward"} end
        for _, base in pairs(info.bases) do
            local ingredient = info.ingredient
            local normal = "mcl_potions:"..info.name
            local splash = normal.."_splash"
            local lingering = normal.."_lingering"
            exchangeclone.register_craft({output = normal.." 3", type = "brewing", recipe = {base, base, base, ingredient}})
            exchangeclone.register_craft({output = normal.."_splash 3", type = "brewing", recipe = {normal, normal, normal, "mcl_mobitems:gunpowder"}})
            exchangeclone.register_craft({output = normal.."_lingering 3", type = "brewing", recipe = {normal, normal, normal, "mcl_potions:dragon_breath"}})
            if info.plus then
                exchangeclone.register_craft({output = normal.."_plus 3", type = "brewing", recipe = {normal, normal, normal, "mcl_nether:glowstone_dust"}})
                exchangeclone.register_craft({output = normal.."_plus_splash 3", type = "brewing", recipe = {splash, splash, splash, "mcl_nether:glowstone_dust"}})
                exchangeclone.register_craft({output = normal.."_plus_lingering 3", type = "brewing", recipe = {lingering, lingering, lingering, "mcl_nether:glowstone_dust"}})
            end
            if info.two then
                exchangeclone.register_craft({output = normal.."_2 3", type = "brewing", recipe = {normal, normal, normal, "mesecons:redstone"}})
                exchangeclone.register_craft({output = normal.."_2_splash 3", type = "brewing", recipe = {splash, splash, splash, "mesecons:redstone"}})
                exchangeclone.register_craft({output = normal.."_2_lingering 3", type = "brewing", recipe = {lingering, lingering, lingering, "mesecons:redstone"}})
            end
        end
    end
    for _, info in pairs(exchangeclone.mcl_potion_data) do
        add_potion_recipe(info)
    end

    -- Enchanted/netherite tools
    exchangeclone.register_craft_type("upgrading", "shapeless")
    for name, def in pairs(minetest.registered_items) do
        if def._mcl_enchanting_enchanted_tool then
            exchangeclone.register_alias(name, def._mcl_enchanting_enchanted_tool)
        end
        if def._mcl_upgrade_item then
            if not name:find("enchanted") then
                exchangeclone.register_craft({output = def._mcl_upgrade_item, type = "upgrading", recipe = {name, "mcl_nether:netherite_ingot"}})
            end
        end
    end

    exchangeclone.register_craft_type("hardening", "cooking")
    -- Concrete and banners/shields (don't remember why the shields don't work)
    for color, color_data in pairs(exchangeclone.colors) do
        exchangeclone.register_craft({output = "mcl_colorblocks:concrete_"..color, type = "hardening", recipe = "mcl_colorblocks:concrete_powder_"..color})
        --exchangeclone.register_craft({output = "mcl_shields:shield_"..color, type = "shapeless", recipe = {"mcl_banners:banner_item_"..color, "mcl_shields:shield"}})
    end

    -- Maps
    exchangeclone.register_alias("mcl_maps:empty_map", "mcl_maps:filled_map")
    local mcl_skins_enabled = minetest.global_exists("mcl_skins")
    if mcl_skins_enabled then
        -- Generate a node for every skin
        local list = mcl_skins.get_skin_list()
        for _, skin in pairs(list) do
            exchangeclone.register_alias("mcl_maps:empty_map", "mcl_maps:filled_map_" .. skin.id)
        end
    else
        exchangeclone.register_alias("mcl_maps:empty_map", "mcl_maps:filled_map_hand")
    end

    -- Sponges
    exchangeclone.register_alias("mcl_sponges:sponge", "mcl_sponges:sponge_wet")
    exchangeclone.register_alias("mcl_sponges:sponge", "mcl_sponges:sponge_wet_river_water")
end

-- Register copper block/stonecutting EMC recipes in MineClone2
if exchangeclone.mcl2 then
    exchangeclone.register_craft_type("oxidation", "cooking")
    local states = {"", "_exposed", "_weathered", "_oxidized"}
    for i = 2, #states do
        exchangeclone.register_craft({output = "mcl_copper:block"..states[i], type = "oxidation", recipe = "mcl_copper:block"..states[i-1]})
    end
    exchangeclone.register_craft_type("stonecutting", "cooking")
    for input, outputs in pairs(mcl_stonecutter.registered_recipes) do
        for output, amount in pairs(outputs) do
            exchangeclone.register_craft({output = output.." "..amount, type = "stonecutting", recipe = input})
        end
    end
end

if exchangeclone.mtg then
    exchangeclone.register_alias("default:book", "default:book_written")
end


if minetest.global_exists("logistica") then
    exchangeclone.register_craft_type("lava_furnace", "shapeless") -- weird that it's not cooking but I can't see any way around that
    exchangeclone.register_craft({
        output = "logistica:silverin",
        type = "lava_furnace",
        recipe = {
            exchangeclone.mcl and "mcl_core:sand" or "default:silver_sand",
            exchangeclone.itemstrings.ice
        }
    })
    exchangeclone.register_craft({
        output = "logistica:silverin_circuit",
        type = "lava_furnace",
        recipe = {
            "logistica:silverin_slice",
            exchangeclone.mcl and "mesecons:redstone" or "default:mese_crystal_fragment"
        }
    })
    exchangeclone.register_craft({
        output = "logistica:silverin_mirror_box",
        type = "lava_furnace",
        recipe = {
            exchangeclone.itemstrings.glass,
            "logistica:silverin_slice",
            "logistica:silverin_slice",
            "logistica:silverin_slice",
            "logistica:silverin_slice",
            "logistica:silverin_slice",
            "logistica:silverin_slice",
        }
    })
    exchangeclone.register_craft({
        output = "logistica:silverin_plate",
        type = "lava_furnace",
        recipe = {
            "logistica:silverin",
            exchangeclone.itemstrings.iron,
        }
    })
    exchangeclone.register_craft({
        output = "logistica:wireless_crystal",
        type = "lava_furnace",
        recipe = {
            "logistica:silverin",
            exchangeclone.itemstrings.emeraldworth,
        }
    })
end



-- Up to this point, no EMC values have actually been set.



-- Register group EMC values
local groupnames = {}
for index, group in ipairs(exchangeclone.group_values) do
    groupnames[#groupnames + 1] = group[1] --Get list of group names
end
local grouped_items = exchangeclone.get_group_items(groupnames, true, true)
for index, group in ipairs(exchangeclone.group_values) do
    for i, item in pairs(grouped_items[group[1]]) do
        register_emc(item, group[2])
    end
end

-- Register base EMC values
for itemstring, emc_value in pairs(exchangeclone.base_emc_values) do
    register_emc(itemstring, emc_value)
end

--minetest.log('[ExchangeClone] recipes:\n' .. dump(exchangeclone.recipes))
-- Register `exchangeclone_custom_emc` values and decide whether to automatically register EMC values
for itemstring, def in pairs(minetest.registered_items) do
    if def.exchangeclone_custom_emc then
        register_emc(itemstring, def.exchangeclone_custom_emc)
    else
        itemstring = exchangeclone.handle_alias(itemstring) or itemstring
        def = minetest.registered_items[itemstring] -- in case itemstring changed
        local _, _, mod_name, item_name = itemstring:find("([%d_%l]+):([%d_%l]+)")
        local add_to_auto = def and item_name and mod_name
        add_to_auto = add_to_auto and def.description and def.description ~= ""
        if minetest.get_item_group(itemstring, "not_in_creative_inventory") ~= 0 and mod_name ~= "mcl_compass" then
            add_to_auto = false
        elseif exchangeclone.exile and minetest.get_item_group(itemstring, "natural_slope") ~= 0 then
            add_to_auto = false
        elseif exchangeclone.get_item_emc(itemstring) then
            add_to_auto = false
        end
        if add_to_auto and exchangeclone.recipes[itemstring] then
            auto[itemstring] = true
        elseif add_to_auto then
            minetest.log("[ExchangeClone] skipping " .. itemstring .. "\n" .. dump(def))
        end
    end
end

-- handle aliases in exchangeclone.recipes
for itemstring, recipes in pairs(exchangeclone.recipes) do
    local new_name = ItemStack(itemstring):get_name()
    if new_name and new_name ~= "" and new_name ~= itemstring then
        exchangeclone.recipes[new_name] = exchangeclone.recipes[new_name] or {}
        for _, recipe in pairs(recipes) do
            table.insert(exchangeclone.recipes[new_name], recipe)
        end
    end
end

local old_auto
local same = false
local i = 1
-- Automatically register EMC values
while not same do
    minetest.log("action", "[ExchangeClone] \tIteration #"..i)
    if auto == {} then break end
    if old_auto then
        same = true
        for itemstring, _ in pairs(old_auto) do
            if itemstring ~= "" and not auto[itemstring] then
                same = false
                break
            end
        end
    end
    if same then
        minetest.log("action", "[ExchangeClone]\tNo change, stopping.")
        break
    end
    old_auto = table.copy(auto)
    for itemstring, _ in pairs(auto) do
        local cheapest = get_cheapest_recipe(itemstring)
        if cheapest then
            register_emc(itemstring, cheapest)
            auto[itemstring] = nil
        end
    end
    i = i + 1
end

if exchangeclone.mcl then
    register_emc("mcl_campfires:campfire", exchangeclone.get_item_emc("mcl_campfires:campfire_lit"))
    register_emc("mcl_campfires:soul_campfire", exchangeclone.get_item_emc("mcl_campfires:soul_campfire_lit"))
    -- Recovery compasses use a random compass frame for the crafting recipe... Incredibly irritating.
    for i = 0, 31 do
        if exchangeclone.get_item_emc("mcl_compass:"..i.."_recovery") then
            for j = 0, 31 do
                exchangeclone.register_alias("mcl_compass:"..i.."_recovery", "mcl_compass:"..j.."_recovery")
            end
            break
        end
    end
end

local cheapest_color = {""}

for color, color_data in pairs(exchangeclone.colors) do
    local dye_itemstring = (exchangeclone.mcl and "mcl_dye:" or "dye:")..color
    local dye_emc = exchangeclone.get_item_emc(dye_itemstring)
    if dye_emc then
        if (not cheapest_color[2]) or (dye_emc < cheapest_color[2])  then
            cheapest_color[1] = color
            cheapest_color[2] = dye_emc
        end
    end
end

cheapest_color = cheapest_color[1] -- No idea why I'm doing it this way.

local cheapest_advanced_itemstring = "exchangeclone:advanced_alchemical_chest_"..cheapest_color

for color, color_data in pairs(exchangeclone.colors) do
    local advanced_itemstring = "exchangeclone:advanced_alchemical_chest_"..color
    register_emc(advanced_itemstring, exchangeclone.get_item_emc(cheapest_advanced_itemstring))
end

-- Adds EMC values to aliased items, even though they're not used (just so it's displayed)
for alias, itemstring in pairs(exchangeclone.emc_aliases) do
    register_emc(itemstring, exchangeclone.get_item_emc(alias))
end

minetest.log("items without EMC" .. dump(auto))
-- Delete unnecessary data (waste of memory)
if not exchangeclone.keep_data then
    exchangeclone.recipes = nil
    exchangeclone.base_emc_values = nil
end