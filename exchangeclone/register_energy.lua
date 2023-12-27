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
                        local cost = exchangeclone.get_item_energy(item)
                        if (not cost) or cost == 0 then
                            skip = item
                        else
                            ingredient_cost = ingredient_cost + cost
                        end
                    end
                end
            end
        elseif exchangeclone.craft_types[recipe.type].type == "energy" then
            ingredient_cost = recipe.recipe
        end
        if recipe.replacements and not skip then
            for _, item in pairs(recipe.replacements) do
                if item[1] ~= item[2] then
                    local cost = exchangeclone.get_item_energy(item[2])
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

exchangeclone.energy_values = {}

-- Sets the energy value of an item, must be called during load time.
local function set_item_energy(itemstring, energy_value)
    if not (energy_value and itemstring) then return end
    energy_value = math.floor(energy_value*20)/20 -- floor to nearest .05
    if energy_value < 0 then return end
    local def = minetest.registered_items[itemstring]
    if not def then return end
    local description = def.description or ""

    -- Override energy value if it already exists
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
    if energy_value > 0 then
        exchangeclone.energy_values[itemstring] = energy_value
    else
        exchangeclone.energy_values[itemstring] = nil
    end
end

local auto = {}

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

-- Register clock/compass aliases, handle enchanted/netherite stuff, potions, and concrete, and register coral energy values
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

-- Register copper block/stonecutting energy recipes in MineClone2
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

if not exchangeclone.mcl then
    exchangeclone.register_alias("default:book", "default:book_written")
end




-- Up to this point, no energy values have actually been set.




-- Register group energy values
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

-- Register base energy values
for itemstring, energy_value in pairs(exchangeclone.base_energy_values) do
    set_item_energy(itemstring, energy_value)
end

-- Register `exchangeclone_custom_energy` values and decide whether to automatically register energy values
for itemstring, def in pairs(minetest.registered_items) do
    if def.exchangeclone_custom_energy then
        set_item_energy(itemstring, def.exchangeclone_custom_energy)
    else
        itemstring = exchangeclone.handle_alias(itemstring) or itemstring
        def = minetest.registered_items[itemstring] -- in case itemstring changed
        local _, _, mod_name, item_name = itemstring:find("([%d_%l]+):([%d_%l]+)")
        if (
            def
            and item_name
            and mod_name
            and def.description
            and def.description ~= ""
            and ((minetest.get_item_group(item_name, "not_in_creative_inventory") < 1) or mod_name == "mcl_compass")
            and (not exchangeclone.get_item_energy(itemstring))
            and exchangeclone.recipes[itemstring]
        ) then
            auto[itemstring] = true
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
-- Automatically register energy values
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
            set_item_energy(itemstring, cheapest)
            auto[itemstring] = nil
        end
    end
    i = i + 1
end

if exchangeclone.mcl then
    set_item_energy("mcl_campfires:campfire", exchangeclone.get_item_energy("mcl_campfires:campfire_lit"))
    set_item_energy("mcl_campfires:soul_campfire", exchangeclone.get_item_energy("mcl_campfires:soul_campfire_lit"))
    -- Recovery compasses use a random compass frame for the crafting recipe... Incredibly irritating.
    for i = 0, 31 do
        if exchangeclone.get_item_energy("mcl_compass:"..i.."_recovery") then
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
    local dye_energy = exchangeclone.get_item_energy(dye_itemstring)
    if dye_energy then
        if (not cheapest_color[2]) or (dye_energy < cheapest_color[2])  then
            cheapest_color[1] = color
            cheapest_color[2] = dye_energy
        end
    end
end

cheapest_color = cheapest_color[1] -- No idea why I'm doing it this way.

local cheapest_advanced_itemstring = "exchangeclone:advanced_alchemical_chest_"..cheapest_color

for color, color_data in pairs(exchangeclone.colors) do
    local advanced_itemstring = "exchangeclone:advanced_alchemical_chest_"..color
    set_item_energy(advanced_itemstring, exchangeclone.get_item_energy(cheapest_advanced_itemstring))
end

-- Adds energy values to aliased items, even though they're not used (just so it's displayed)
for alias, itemstring in pairs(exchangeclone.energy_aliases) do
    set_item_energy(itemstring, exchangeclone.get_item_energy(alias))
end

-- Delete unnecessary data (waste of memory)
if not exchangeclone.keep_data then
    exchangeclone.recipes = nil
    exchangeclone.base_energy_values = nil
end