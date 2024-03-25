-- Exile always registers the legacy/unused items, register the recipes so we can assign EMC
local extra_exile_crafting_recipes = {
    {
        type   = "crafting_spot",
        output = "tech:grinding_stone",
        items  = {'nodes_nature:granite_boulder', 'nodes_nature:sand 8'},
        level  = 1,
        always_known = true,
    },
    {
        type   = "crafting_spot",
        output = "tech:weaving_frame",
        items  = {'tech:stick 12', 'group:fibrous_plant 8'},
        level  = 1,
        always_known = true,
    },
    {
        type   = "crafting_spot",
        output = "tech:chopping_block",
        items  = {'group:log'},
        level  = 1,
        always_known = true,
    },
    {
        type   = "chopping_block",
        output = "tech:chopping_block",
        items  = {'group:log'},
        level  = 1,
        always_known = true,
    },
    {
        type   = "chopping_block",
        output = "tech:hammering_block",
        items  = {'group:log'},
        level  = 1,
        always_known = true,
    },
    {
        type   = "mixing_spot",
        output = "tech:potash_block",
        items  = {'tech:potash 2'},
        level  = 1,
        always_known = true,
    },
}

local function register_translated_recipes()
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
                    minetest.log("verbose", "[ExchangeClone]: registered Exile crafting recipe: \n"..dump(final_recipe))
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
    local crafting_recipes = table.copy(crafting.recipes)
    for _, recipe in ipairs(extra_exile_crafting_recipes) do
        assert(crafting_recipes[recipe.type], "unknown exile crafting recipe type"..recipe.type)
        crafting_recipes[recipe.type] = table.copy(crafting_recipes[recipe.type])
        table.insert(crafting_recipes[recipe.type], recipe)
    end
    for craft_type, recipes in pairs(crafting_recipes) do
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
end

register_translated_recipes()

-- Exile always registers the legacy items, register the recipes so we can assign EMC
local function register_exile_legacy_recipes()
    crafting.register_recipe({
    type   = "crafting_spot",
    output = "tech:grinding_stone",
    items  = {'nodes_nature:granite_boulder', 'nodes_nature:sand 8'},
    level  = 1,
    always_known = true,
    })
    crafting.register_recipe({ --weaving_frame
    type   = "crafting_spot",
    output = "tech:weaving_frame",
    items  = {'tech:stick 12', 'group:fibrous_plant 8'},
    level  = 1,
    always_known = true,
    })
    crafting.register_recipe({ --chopping_block
    type   = "crafting_spot",
    output = "tech:chopping_block",
    items  = {'group:log'},
    level  = 1,
    always_known = true,
    })
    crafting.register_recipe({
    type   = "chopping_block",
    output = "tech:chopping_block",
    items  = {'group:log'},
    level  = 1,
    always_known = true,
    })
    crafting.register_recipe({ --hammering block
    type   = "chopping_block",
    output = "tech:hammering_block",
    items  = {'group:log'},
    level  = 1,
    always_known = true,
    })
end

register_exile_legacy_recipes()

local sorted_dump_action
---@param v any
---@param indent? nil|string
---@return string
local function sorted_dump(v, indent)
    if not indent then
        indent = ""
    end
    local action = sorted_dump_action[type(v)] or sorted_dump_action.default
    return action(v, indent)
end
sorted_dump_action = {
    ["nil"] = function(v, indent)
        return "nil"
    end,
    number = function(v, indent)
        return tostring(v)
    end,
    string = function(v, indent)
        return string.format("%q", v)
    end,
    boolean = function(v, indent)
        return string.format("%q", v)
    end,
    table = function(v, indent)
        local inner_indent = indent.."  "
        ---@type any[]
        local keys = {}
        for key, _ in pairs(v) do
            table.insert(keys, key)
        end
        table.sort(keys)
        local is_array = true
        for index, key in ipairs(keys) do
            if index ~= key then
                is_array = false
                break
            end
        end
        ---@type string[]
        local lines = {}
        if is_array then
            for _, key in ipairs(keys) do
                table.insert(lines, sorted_dump(v[key], inner_indent))
            end
        else
            for _, key in ipairs(keys) do
                local value = sorted_dump(v[key], inner_indent)
                if type(key) == "string" and key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
                    table.insert(lines, key.." = "..value)
                else
                    table.insert(lines, "["..sorted_dump(key, inner_indent).."] = "..value)
                end
            end
        end
        local lines_len_total = 0
        for _, line in ipairs(lines) do
            if line:match("\n") then
                lines_len_total = math.huge
                break
            end
            lines_len_total = lines_len_total + #line
        end
        if #lines == 0 then
            return "{}"
        end
        if #lines == 1 then
            return "{"..lines[1].."}"
        end
        if lines_len_total + 2 * #lines + 2 < 80 then
            return "{"..table.concat(lines, ", ").."}"
        end
        return "{\n"..inner_indent..table.concat(lines, ",\n"..inner_indent).."\n"..indent.."}"
    end,
    default = function(v, indent)
        return "<" .. type(v) .. ">"
    end
}

---@class SedimentSoil
---@field soil string
---@field soil_wet string

---@class Sediment
---@field wet string
---@field wet_salty string
---@field ag string
---@field ag_wet string
---@field ag_depleted string
---@field ag_wet_depleted string
---@field soils? SedimentSoil[]

---@type table<string, Sediment>
local sediments = {}

for name, def in pairs(minetest.registered_items) do
    if name:match("^artifacts:wayfinder_[1-9][0-9]*$") then
        exchangeclone.register_alias("artifacts:wayfinder_0", name)
    end
    if def.groups.natural_slope or def.groups.not_in_creative_inventory then
        goto continue
    end
    minetest.log("verbose", "[ExchangeClone] exile_on_mods_loaded examining: "..name.." = "..sorted_dump(def))
    if def.groups.sediment then
        if def.groups.natural_slope then
        elseif def.groups.wet_sediment then
        elseif def.groups.bare_sediment then
            local dry = name
            sediments[dry] = sediments[dry] or {}
            sediments[dry].wet = def._wet_name
            sediments[dry].wet_salty = def._wet_salty_name
        elseif def.groups.agricultural_soil then
            local dry = def.drop
            sediments[dry] = sediments[dry] or {}
            sediments[dry].ag = name
            sediments[dry].ag_wet = def._wet_name
        elseif def.groups.depleted_agricultural_soil then
            local dry = def.drop
            sediments[dry] = sediments[dry] or {}
            sediments[dry].ag_depleted = name
            sediments[dry].ag_wet_depleted = def._wet_name
        else
            local dry = def.drop
            sediments[dry] = sediments[dry] or {}
            sediments[dry].soils = sediments[dry].soils or {}
            table.insert(sediments[dry].soils, {soil = name, soil_wet = def._wet_name})
        end
    end
    ::continue::
end

minetest.log("sediments = "..sorted_dump(sediments))

exchangeclone.register_craft_type("roasting", "cooking")
for recipe, output in pairs({
    ["tech:iron_and_slag"] = "tech:iron_bloom",
    ["tech:iron_smelting_mix"] = "tech:iron_and_slag",
    ["tech:crushed_iron_ore"] = "tech:roasted_iron_ore",
    ["tech:green_glass_mix"] = "tech:green_glass_ingot",
    ["tech:clear_glass_mix"] = "tech:clear_glass_ingot",
    ["tech:crushed_lime"] = "tech:quicklime",
}) do
    exchangeclone.register_craft({
        type = "roasting",
        output = output,
        recipe = recipe,
    })
end
exchangeclone.register_craft_type("fire_pottery", "cooking")
for recipe, output in pairs({
    ["tech:loose_brick_unfired"] = "tech:loose_brick",
    ["tech:roof_tile_loose_unfired"] = "tech:roof_tile_loose",
    ["tech:tile_block_unfired"] = "tech:tile_block",
    ["tech:cooking_pot_unfired"] = "tech:cooking_pot",
    ["tech:clay_water_pot_unfired"] = "tech:clay_water_pot",
    ["tech:clay_storage_pot_unfired"] = "tech:clay_storage_pot",
    ["tech:clay_oil_lamp_unfired"] = "tech:clay_oil_lamp_empty",
    ["tech:clay_watering_can_unfired"] = "tech:clay_watering_can",
}) do
    exchangeclone.register_craft({
        type = "fire_pottery",
        output = output,
        recipe = recipe,
    })
end
exchangeclone.register_craft_type("baking", "cooking")
local baking_map = {}
for name, _ in pairs(bake_table) do
    baking_map[name] = name.."_cooked"
    baking_map[name.."_cooked"] = name.."_burned"
end
for name, _ in pairs(exchangeclone.colors) do
    baking_map["ncrafting:bundle_treated_"..name] = "ncrafting:bundle_treated_blue" -- burning
    baking_map["ncrafting:bundle_"..name] = "ncrafting:bundle_treated_"..name
end
for recipe, output in pairs(baking_map) do
    if minetest.registered_items[recipe] and minetest.registered_items[output] then
        exchangeclone.register_craft({
            type = "baking",
            output = output,
            recipe = recipe,
        })
    end
end
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
exchangeclone.register_craft({
    type = "melting",
    output = "tech:pane_clear",
    recipe = {"tech:clear_glass_ingot"},
})
exchangeclone.register_craft({
    type = "melting",
    output = "tech:pane_green",
    recipe = {"tech:green_glass_ingot"},
})
local fire_kinds = {
    ["tech:small_wood_fire"] = {
        unlit = "tech:small_wood_fire_unlit",
        extinguished = "tech:small_wood_fire_ext",
        smoldering = "tech:small_wood_fire_smoldering",
        charcoal_fire = "tech:small_charcoal_fire",
    },
    ["tech:large_wood_fire"] = {
        unlit = "tech:large_wood_fire_unlit",
        extinguished = "tech:large_wood_fire_ext",
        smoldering = "tech:large_wood_fire_smoldering",
        charcoal_fire = "tech:large_charcoal_fire",
    },
    ["tech:small_charcoal_fire"] = {
        unlit = "tech:charcoal",
        extinguished = "tech:small_charcoal_fire_ext",
        smoldering = "tech:small_charcoal_fire_smoldering",
    },
    ["tech:large_charcoal_fire"] = {
        unlit = "tech:charcoal_block",
        extinguished = "tech:large_charcoal_fire_ext",
        smoldering = "tech:large_charcoal_fire_smoldering",
    },
    ["tech:lantern_lit"] = {
        unlit = "tech:lantern_unlit",
        extinguished = "tech:lantern_unlit",
    },
    ["tech:clay_oil_lamp"] = {
        unlit = "tech:clay_oil_lamp_unlit",
    },
}
exchangeclone.register_craft_type("start_fire", "cooking")
exchangeclone.register_craft_type("extinguish_fire", "cooking", true)
exchangeclone.register_craft_type("to_smoldering", "cooking", true)
exchangeclone.register_craft_type("to_charcoal", "cooking")
for name, fire_kind in pairs(fire_kinds) do
    exchangeclone.register_craft({
        type = "start_fire",
        output = name,
        recipe = fire_kind.unlit,
    })
    if fire_kind.extinguished then
        exchangeclone.register_craft({
            type = "extinguish_fire",
            output = fire_kind.extinguished,
            recipe = name,
        })
    end
    if fire_kind.smoldering then
        exchangeclone.register_craft({
            type = "to_smoldering",
            output = fire_kind.smoldering,
            recipe = name,
        })
    end
    if fire_kind.charcoal_fire then
        exchangeclone.register_craft({
            type = "to_charcoal",
            output = fire_kinds[fire_kind.charcoal_fire].unlit,
            recipe = fire_kind.smoldering,
        })
    end
end

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
exchangeclone.register_craft_type("soaking", "cooking")
exchangeclone.register_craft({
    type = "soaking",
    output = "tech:retted_cana_bundle",
    recipe = "tech:unretted_cana_bundle",
})
exchangeclone.register_craft({
    type = "soaking",
    output = "tech:maraka_flour",
    recipe = "tech:maraka_flour_bitter",
})
--@type string[]
local liquid_containers = {
    "tech:clay_water_pot",
    "tech:wooden_water_pot",
    "tech:glass_bottle_green",
    "tech:glass_bottle_clear",
    "tech:clay_watering_can",
}

---@class LiquidKind
---@field container_suffixes string[]
---@field source string
---@field ice? string
---@field water? true

---@type table<string, LiquidKind>
local liquid_kinds = {
    freshwater = {
        container_suffixes = {"_freshwater"},
        source = "nodes_nature:freshwater_source",
        ice = "nodes_nature:ice",
        water = true,
    },
    salt_water = {
        container_suffixes = {"_salt_water", "_saltwater"},
        source = "nodes_nature:salt_water_source",
        ice = "nodes_nature:sea_ice",
        water = true,
    },
    potash = {
        container_suffixes = {"_potash"},
        source = "tech:potash_source",
    }
}
exchangeclone.register_craft_type("make_ag_depleted", "cooking")
exchangeclone.register_craft_type("ag_soil_to_soil", "cooking")
exchangeclone.register_craft_type("wetten", "shapeless")
---@param name string|nil
---@param wet_name string|nil
---@param liquid_kind LiquidKind
local function register_wetten(name, wet_name, liquid_kind)
    if not name or not wet_name then
        return
    end
    for _, container_suffix in ipairs(liquid_kind.container_suffixes) do
        local filled = liquid_containers[1]..container_suffix
        if minetest.registered_craftitems[filled] then
            exchangeclone.register_craft({
                type = "wetten",
                output = wet_name,
                recipe = {name, filled},
                replacements = {{filled, liquid_containers[1]}},
            })
        end
    end
end
---@param name string|nil
---@param ag_depleted string|nil
local function register_make_ag_depleted(name, ag_depleted)
    if not name or not ag_depleted then
        return
    end
    exchangeclone.register_craft({
        type = "make_ag_depleted",
        output = ag_depleted,
        recipe = name,
    })
end
---@param ag string|nil
---@param soil string|nil
local function register_ag_soil_to_soil(ag, soil)
    if not ag or not soil then
        return
    end
    exchangeclone.register_craft({
        type = "ag_soil_to_soil",
        output = soil,
        recipe = ag,
    })
end
for name, sediment in pairs(sediments) do
    register_wetten(name, sediment.wet, liquid_kinds.freshwater)
    register_wetten(name, sediment.wet_salty, liquid_kinds.salt_water)
    register_wetten(sediment.ag, sediment.ag_wet, liquid_kinds.freshwater)
    register_wetten(sediment.ag_depleted, sediment.ag_wet_depleted, liquid_kinds.freshwater)
    for _, soil in ipairs(sediment.soils or {}) do
        register_wetten(soil.soil, soil.soil_wet, liquid_kinds.freshwater)
        register_ag_soil_to_soil(sediment.ag, soil.soil)
    end
    register_make_ag_depleted(name, sediment.ag_depleted)
end
exchangeclone.register_craft_type("thawing", "cooking", true)
exchangeclone.register_craft_type("fill_water_pot", "shapeless")
for _, liquid_kind in pairs(liquid_kinds) do
    if liquid_kind.ice then
        exchangeclone.register_craft({
            type = "thawing",
            output = liquid_kind.source,
            recipe = liquid_kind.ice,
        })
    end
    for _, container in ipairs(liquid_containers) do
        for _, container_suffix in ipairs(liquid_kind.container_suffixes) do
            local filled = container..container_suffix
            if minetest.registered_items[filled] then
                exchangeclone.register_craft({
                    type = "fill_water_pot",
                    output = filled,
                    recipe = {container, liquid_kind.source},
                })
            end
        end
    end
end
exchangeclone.register_craft_type("make_potash_source", "shapeless")
exchangeclone.register_craft({
    type = "make_potash_source",
    output = liquid_kinds.potash.source,
    recipe = {"tech:wood_ash_block", liquid_kinds.freshwater.source},
})
exchangeclone.register_craft_type("make_potash", "shapeless")
exchangeclone.register_craft({
    type = "make_potash",
    output = "tech:dry_potash_pot",
    recipe = {"tech:clay_water_pot_potash"},
})
exchangeclone.register_craft({
    type = "make_potash",
    output = "tech:potash",
    recipe = {"tech:clay_water_pot_potash"},
    replacements = {{"tech:clay_water_pot_potash", "tech:clay_water_pot"}},
})
exchangeclone.register_craft_type("transporter_activate", "cooking")
exchangeclone.register_craft({
    type = "transporter_activate",
    output = "artifacts:transporter_pad_active",
    recipe = "artifacts:transporter_pad_charging",
})
exchangeclone.register_craft({
    type = "transporter_activate",
    output = "artifacts:transporter_pad_charging",
    recipe = "artifacts:transporter_pad",
})
exchangeclone.register_craft_type("make_latern", "shapeless")
exchangeclone.register_craft({
    type = "make_latern",
    output = "tech:lantern_case_wick",
    recipe = {"tech:lantern_case", "tech:coarse_fibre"},
})
exchangeclone.register_craft({
    type = "make_latern",
    output = "tech:lantern_case_glass",
    recipe = {"tech:lantern_case", "tech:pane_clear"},
})
exchangeclone.register_craft({
    type = "make_latern",
    output = "tech:lantern_unlit",
    recipe = {"tech:lantern_case_wick", "tech:pane_clear"},
})
exchangeclone.register_craft_type("dye_crafting", "shapeless")
for name, color_data in pairs(exchangeclone.colors) do
    exchangeclone.register_craft({
        type = "make_latern",
        output = color_data.dye.." 2",
        recipe = {"ncrafting:bundle_treated_"..name},
    })
end
exchangeclone.register_craft_type("lime_slaking", "shapeless")
exchangeclone.register_craft({
    type = "lime_slaking",
    output = "tech:slaked_lime",
    recipe = {"tech:quicklime", liquid_kinds.freshwater.source},
})
exchangeclone.register_craft({
    type = "lime_slaking",
    output = "tech:slaked_lime_ruined",
    recipe = {"tech:quicklime", liquid_kinds.salt_water.source},
})
exchangeclone.register_craft_type("fermenting", "cooking")
exchangeclone.register_craft({
    type = "fermenting",
    output = "tech:tang",
    recipe = "tech:tang_unfermented",
})
exchangeclone.register_craft({
    type = "fermenting",
    output = "tech:wooden_tang",
    recipe = "tech:wooden_tang_unfermented",
})
