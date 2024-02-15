exchangeclone.density_targets = {
    exchangeclone.itemstrings.iron,
    exchangeclone.itemstrings.gold,
    exchangeclone.itemstrings.diamond,
    "exchangeclone:dark_matter",
    "exchangeclone:red_matter",
}

local function gem_action(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    local meta = itemstack:get_meta()
    if player:get_player_controls().aux1 then
        local current_target = meta:get_int("density_target") or 1
        if player:get_player_controls().sneak then
            current_target = math.max(1, current_target - 1)
        else
            current_target = math.min(#exchangeclone.density_targets, current_target + 1)
        end
        minetest.chat_send_player(player:get_name(), "Target: "..ItemStack(exchangeclone.density_targets[current_target]):get_short_description())
        meta:set_int("density_target", current_target)
        return itemstack
    end

    local inv = player:get_inventory()
    local list = inv:get_list("main")
    -- Don't include hotbar
    local min = exchangeclone.mcl and 10 or 9
    if player:get_wield_index() >= min then return end

    local total_emc = meta:get_int("density_stored") or 0
    for i = min, #list do
        local stack = list[i]
        local emc = exchangeclone.get_item_emc(stack) or 0
        if emc > 0 then
            total_emc = total_emc + emc
            list[i] = ItemStack("")
        end
    end

    if not (total_emc and emc > 0) then return end

    local target = exchangeclone.density_targets[meta:get_int("density_target") or 1]
    local target_emc = exchangeclone.get_item_emc(target)

    local stack_max = ItemStack(target):get_stack_max()
    local num_to_add = math.floor(total_emc/target_emc)
    local num_stacks, remainder = math.floor(num_to_add/stack_max), num_to_add%stack_max

    for i = 0, num_stacks do
        local extra = inv:add_item("main", ItemStack(target.." "..stack_max))
        if extra:get_count() > 0 then
            break
        else
    end

end