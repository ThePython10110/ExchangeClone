local S = minetest.get_translator()

exchangeclone.tool_types = exchangeclone.tool_types or {}

for group, amount in pairs({
    sword = 2,
    pickaxe = 3,
    pick = 3,
    axe = 3,
    shovel = 1,
    hoe = 2,
    hammer = 2,
    shears = 2,
    helmet = 5,
    chestplate = 8,
    leggings = 7,
    boots = 4,
    shield = exchangeclone.mcl and 1 or 7,
}) do
    exchangeclone.tool_types[group] = exchangeclone.tool_types[group] or amount
end

local charcoal_itemstring = exchangeclone.mcl and "mcl_core:charcoal_lump" or "group:tree"

minetest.register_craftitem("exchangeclone:low_covalence_dust", {
    description = S("Low Covalence Dust"),
    groups = {covalence_dust = 1},
    inventory_image = "exchangeclone_low_covalence_dust.png",
    wield_image = "exchangeclone_low_covalence_dust.png",
})
minetest.register_craftitem("exchangeclone:medium_covalence_dust", {
    description = S("Medium Covalence Dust"),
    groups = {covalence_dust = 2},
    inventory_image = "exchangeclone_medium_covalence_dust.png",
    wield_image = "exchangeclone_medium_covalence_dust.png",
})

minetest.register_craftitem("exchangeclone:high_covalence_dust", {
    description = S("High Covalence Dust"),
    groups = {covalence_dust = 3},
    inventory_image = "exchangeclone_high_covalence_dust.png",
    wield_image = "exchangeclone_high_covalence_dust.png",
})

minetest.register_craft({
    output = "exchangeclone:low_covalence_dust 40",
    type = "shapeless",
    recipe = {
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        exchangeclone.itemstrings.cobble,
        charcoal_itemstring,
    }
})

minetest.register_craft({
    output = "exchangeclone:medium_covalence_dust 40",
    type = "shapeless",
    recipe = {
        exchangeclone.itemstrings.iron, exchangeclone.itemstrings.redstoneworth
    }
})

minetest.register_craft({
    output = "exchangeclone:high_covalence_dust 40",
    type = "shapeless",
    recipe = {
        exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.coal
    }
})

local listnames = {exchangeclone_covalence_dust = true, exchangeclone_covalence_gear = true, exchangeclone_covalence_output = true}

local function is_repairable_gear(item)
    item = ItemStack(item)
    if item:get_wear() <= 0 then return end
    if minetest.get_item_group(item:get_name(), "disable_repair") > 0 then return end
    if (exchangeclone.get_item_emc(item) or 0) <= 0 then return end
    local def = item:get_definition()
    if def
    and def.type == "tool"
    and (not def.wear_represents or def.wear_represents == "mechanical_wear")
    and item:get_wear() > 0 then
        local result = 0
        for group, amount in pairs(exchangeclone.tool_types) do
            if minetest.get_item_group(item:get_name(), group) > 0 then
                result = result + amount
            end
        end
        return (result > 0) and result
    end
end

minetest.register_allow_player_inventory_action(function(player, action, inventory, info)
    if action == "take" and listnames[info.listname] then
        return info.stack:get_count()
    elseif action == "move" and listnames[info.to_list] then
        if info.to_list == "exchangeclone_covalence_output" then
            return 0
        elseif info.to_list == "exchangeclone_covalence_gear" then
            local stack = inventory:get_stack(info.from_list, info.from_index)
            return is_repairable_gear(stack) and info.count or 0
        elseif info.to_list == "exchangeclone_covalence_dust" then
            local stack = inventory:get_stack(info.from_list, info.from_index)
            return (minetest.get_item_group(stack:get_name(), "covalence_dust") > 0) and info.count or 0
        end
    elseif action == "put" and listnames[info.listname] then
        if info.listname == "exchangeclone_covalence_output" then
            return 0
        elseif info.listname == "exchangeclone_covalence_gear" then
            return is_repairable_gear(info.stack) and info.stack:get_count() or 0
        elseif info.listname == "exchangeclone_covalence_dust" then
            return (minetest.get_item_group(info.stack:get_name(), "covalence_dust") > 0) and info.stack:get_count() or 0
        end
    end
end)

-- I'm aware that this does not account for tools that can stack, but that's just because I don't think that's even possible.
minetest.register_on_player_inventory_action(function(player, action, inventory, info)
    if ((action == "take" or action == "put") and listnames[info.listname])
    or (action == "move" and (listnames[info.to_list] or listnames[info.from_list])) then
        local gear_stack = inventory:get_stack("exchangeclone_covalence_gear", 1)
        local dust_stack = inventory:get_stack("exchangeclone_covalence_dust", 1)
        if gear_stack:is_empty() or dust_stack:is_empty() then return end
        if not inventory:room_for_item("exchangeclone_covalence_output", gear_stack) then return end
        local amount = is_repairable_gear(gear_stack)
        local emc_value = exchangeclone.get_item_emc(gear_stack)
        local tier = 3
        if emc_value/amount < 50 then
            tier = 1
        elseif emc_value/amount < 6000 then
            tier = 2
        end
        if minetest.get_item_group(dust_stack:get_name(), "covalence_dust") >= tier and dust_stack:get_count() >= amount then
            local new_stack = ItemStack(gear_stack)
            new_stack:set_wear(0)
            inventory:add_item("exchangeclone_covalence_output", new_stack)
            inventory:set_stack("exchangeclone_covalence_gear", 1, ItemStack(""))
            dust_stack:set_count(dust_stack:get_count() - amount)
            inventory:set_stack("exchangeclone_covalence_dust", 1, dust_stack)
        end
    end
end)

minetest.register_on_joinplayer(function(player, time_since_whatever)
    for listname, _ in pairs(listnames) do
        player:get_inventory():set_size(listname, 1)
    end
end)