exchangeclone.density_targets = {
    exchangeclone.itemstrings.iron,
    exchangeclone.itemstrings.gold,
    exchangeclone.itemstrings.diamond,
    "exchangeclone:dark_matter",
    "exchangeclone:red_matter",
}

local function get_gem_description(itemstack)
    local meta = itemstack:get_meta()
    local current_target = math.max(meta:get_int("density_target"), 1)
    local target_message = "Target: "..ItemStack(exchangeclone.density_targets[current_target]):get_short_description()
    local emc = exchangeclone.get_item_emc(itemstack:get_name())
    local stored = exchangeclone.get_item_emc(itemstack) - emc
    return "Gem of Eternal Density\n"..target_message.."\nEMC: "..exchangeclone.format_number(emc).."\nStored EMC: "..exchangeclone.format_number(stored)
end

local function condense(player, itemstack)
    local meta = itemstack:get_meta()
    local inv = player:get_inventory()
    local filter_inv = minetest.get_inventory({type = "detached", name = player:get_player_name().."_exchangeclone_goed"})
    local list = inv:get_list("main")
    -- Don't include hotbar
    local min = player:hud_get_hotbar_itemcount() + 1
    if player:get_wield_index() >= min then return end

    local total_emc = exchangeclone.get_item_emc(itemstack) - exchangeclone.get_item_emc(itemstack:get_name())
    local target = exchangeclone.density_targets[math.max(meta:get_int("density_target"),  1)]
    local filter
    local current_mode = player:get_meta():get_string("exchangeclone_goed_filter_type")
    if current_mode == "" or current_mode == "Blacklist" then
        filter = function(stack)
            return not filter_inv:contains_item("main", stack:get_name())
        end
    elseif current_mode == "Whitelist" then
        filter = function(stack)
            return filter_inv:contains_item("main", stack:get_name())
        end
    else
        local learned_items = minetest.deserialize(player:get_meta():get_string("exchangeclone_transmutation_learned_items")) or {}
        filter = function(stack)
            return table.indexof(learned_items, exchangeclone.handle_alias(stack:get_name())) > -1
        end
    end
    for i = min, #list do
        local stack = list[i]
        if filter(stack) and stack:get_name() ~= target then
            local emc = exchangeclone.get_item_emc(stack) or 0
            local individual_emc = exchangeclone.get_item_emc(stack:get_name()) or 0
            if individual_emc > 0 and individual_emc <= exchangeclone.get_item_emc(target) then
                total_emc = total_emc + emc
                list[i] = ItemStack("")
            end
        end
    end

    inv:set_list("main", list)

    if not (total_emc and total_emc > 0) then return end

    local target_emc = exchangeclone.get_item_emc(target)
    local stack_max = ItemStack(target):get_stack_max()
    local num_to_add, remainder_emc = math.floor(total_emc/target_emc), total_emc % target_emc
    local num_stacks, remainder = math.floor(num_to_add/stack_max), num_to_add%stack_max

    if num_stacks > 0 then
        for i = 1, num_stacks do
            num_stacks = num_stacks - 1
            local extra = inv:add_item("main", ItemStack(target.." "..stack_max))
            if extra:get_count() > 0 then
                remainder = remainder + extra:get_count()
                break
            end
        end
    end

    if num_stacks > 0 then
        remainder = remainder + num_stacks*stack_max
    else
        remainder = inv:add_item("main", ItemStack(target.." "..remainder)):get_count()
    end
    if remainder > 0 then
        remainder_emc = remainder_emc + remainder*target_emc
    end
    if meta:get_string("exchangeclone_active") ~= "true" then
        exchangeclone.play_sound(player, "exchangeclone_enable")
    end
    meta:set_int("exchangeclone_emc_value", exchangeclone.get_item_emc(itemstack:get_name()) + remainder_emc)
    meta:set_string("description", get_gem_description(itemstack))
    return itemstack
end

local function gem_action(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    local meta = itemstack:get_meta()
    if player:get_player_control().aux1 then
        local current_target = math.max(meta:get_int("density_target"), 1)
        if player:get_player_control().sneak then
            current_target = math.max(1, current_target - 1)
        else
            current_target = math.min(#exchangeclone.density_targets, current_target + 1)
        end
        minetest.chat_send_player(player:get_player_name(), "Target: "..ItemStack(exchangeclone.density_targets[current_target]):get_short_description())
        meta:set_int("density_target", current_target)
        meta:set_string("description", get_gem_description(itemstack))
        return itemstack
    elseif player:get_player_control().sneak then
        return exchangeclone.toggle_active(itemstack, player, pointed_thing)
    else
        return condense(player, itemstack)
    end
end

local function filter_formspec(player)
    local meta = player:get_meta()
    local current_mode = meta:get_string("exchangeclone_goed_filter_type") or "Blacklist"
    if current_mode == "" then current_mode = "Blacklist" end
    local formspec = table.concat({
        "size[", exchangeclone.width, ",8]",
        "list[detached:", player:get_player_name().."_exchangeclone_goed;main;", exchangeclone.width/2-1.5, ",0;3,3]",
        exchangeclone.mcl and mcl_formspec.get_itemslot_bg(exchangeclone.width/2-1.5, 0,3,3) or "",
        "button[", exchangeclone.width/2-1.5, ",3;3,0.5;filter_type;", current_mode, "]",
        exchangeclone.inventory_formspec(0,4),
        "listring[current_player;main]",
        "listring[detached:", player:get_player_name().."_exchangeclone_goed;main]",
    })
    minetest.show_formspec(player:get_player_name(), "exchangeclone_goed_filter", formspec)
end

minetest.register_on_joinplayer(function(joining_player)
    local inv_name = joining_player:get_player_name().."_exchangeclone_goed"
    local inventory = minetest.get_inventory({type = "detached", name = inv_name})
    if not inventory then
        minetest.create_detached_inventory(inv_name, {
            allow_put = function(inv, listname, index, stack, player)
                if player:get_player_name() ~= joining_player:get_player_name() then return 0 end
                local emc = exchangeclone.get_item_emc(stack)
                if emc <= 0 or not emc then return 0 end
                local stack_copy = ItemStack(stack)
                stack_copy:set_count(1)
                inv:set_stack(listname, index, stack_copy)
                return 0
            end,
            allow_take = function(inv, listname, index, stack, player)
                if player:get_player_name() ~= joining_player:get_player_name() then return 0 end
                inv:set_stack(listname, index, ItemStack(""))
                return 0
            end,
            allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
                if player:get_player_name() ~= joining_player:get_player_name() then return 0 end

                if from_list == to_list then
                    return count
                else
                    inv:set_stack(from_list, from_index, ItemStack(""))
                    return 0
                end
            end,
        })
        inventory = minetest.get_inventory({type = "detached", name = inv_name})
    end
    inventory:set_size("main", 9)
    inventory:set_width("main", 3)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local meta = player:get_meta()
    if formname == "exchangeclone_goed_filter" then
        if player:get_wielded_item():get_name() ~= "exchangeclone:gem_of_eternal_density" then return end
        for field, value in pairs(fields) do
            if field == "filter_type" then
                local current_mode = meta:get_string("exchangeclone_goed_filter_type") or "Blacklist"
                if current_mode == "" then current_mode = "Blacklist" end
                if current_mode == "Blacklist" then current_mode = "Whitelist"
                elseif current_mode == "Whitelist" then current_mode = "All Learned Items"
                else current_mode = "Blacklist" end
                meta:set_string("exchangeclone_goed_filter_type", current_mode)
                filter_formspec(player)
            end
        end
    end
end)

minetest.register_tool("exchangeclone:gem_of_eternal_density", {
    description = "Gem of Eternal Density",
    inventory_image = "exchangeclone_gem_of_eternal_density.png",
    on_secondary_use = gem_action,
    on_place = gem_action,
    on_use = function(itemstack, player, pointed_thing)
        filter_formspec(player)
    end,
    _exchangeclone_passive = {
        hotbar = true,
        active_image = "exchangeclone_gem_of_eternal_density_active.png",
        func = condense
    },
    groups = {disable_repair = 1, exchangeclone_passive = 1},
    _mcl_generate_description = get_gem_description
})

minetest.register_craft({
    output = "exchangeclone:gem_of_eternal_density",
    recipe = {
        {exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.obsidian, exchangeclone.itemstrings.diamond},
        {"exchangeclone:dark_matter", exchangeclone.itemstrings.diamond, "exchangeclone:dark_matter"},
        {exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.obsidian, exchangeclone.itemstrings.diamond}
    }
})