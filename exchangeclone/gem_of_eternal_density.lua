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
    return "Gem of Eternal Density\n"..target_message.."\nEMC value: "..exchangeclone.format_number(emc).."\nStored EMC: "..exchangeclone.format_number(stored)
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
    end

    local inv = player:get_inventory()
    local list = inv:get_list("main")
    -- Don't include hotbar
    local min = exchangeclone.mcl and 10 or 9
    if player:get_wield_index() >= min then return end

    local total_emc = exchangeclone.get_item_emc(itemstack) - exchangeclone.get_item_emc(itemstack:get_name())

    local target = exchangeclone.density_targets[math.max(meta:get_int("density_target"),  1)]

    for i = min, #list do
        local stack = list[i]
        if stack:get_name() ~= target then
            local emc = exchangeclone.get_item_emc(stack) or 0
            if emc > 0 then
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
    exchangeclone.play_sound(player, "exchangeclone_enable")
    meta:set_int("exchangeclone_emc_value", exchangeclone.get_item_emc(itemstack:get_name()) + remainder_emc)
    meta:set_string("description", get_gem_description(itemstack))
    return itemstack
end

minetest.register_tool("exchangeclone:gem_of_eternal_density", {
    description = "Gem of Eternal Density",
    inventory_image = "exchangeclone_gem_of_eternal_density.png",
    on_secondary_use = gem_action,
    on_place = gem_action
})

minetest.register_craft({
    output = "exchangeclone:gem_of_eternal_density",
    recipe = {
        {exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.obsidian, exchangeclone.itemstrings.diamond},
        {"exchangeclone:dark_matter", exchangeclone.itemstrings.diamond, "exchangeclone:dark_matter"},
        {exchangeclone.itemstrings.diamond, exchangeclone.itemstrings.obsidian, exchangeclone.itemstrings.diamond}
    }
})