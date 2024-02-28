-- I want to make this without a formspec.

local function on_rightclick(pos, node, player, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    -- Would be sneak but that would require me to override the player's hand...
    if player:get_player_control().aux1 then
        local contained = inv:get_stack("star", 1)
        if minetest.get_item_group(itemstack:get_name(), "klein_star") > 0 then
            inv:set_stack("star", 1, itemstack)
            return contained
        elseif itemstack:is_empty() then
            inv:set_stack("star", 1, ItemStack(""))
            return contained
        end
    elseif not itemstack:is_empty() then
        local dealiased = exchangeclone.handle_alias(itemstack)
        local emc = exchangeclone.get_item_emc(dealiased)
        if emc and emc > 0 then
            minetest.chat_send_player(player:get_player_name(), "Target Item: "..ItemStack(dealiased):get_short_description())
            meta:set_string("target_item", dealiased)
        end
    end
end

local function link_action(pos)
    local using_star = true
    local player
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if minetest.get_item_group(inv:get_stack("star", 1):get_name(), "klein_star") < 1 then
        using_star = false
        player = minetest.get_player_by_name(meta:get_string("exchangeclone_placer"))
        if not (player and player ~= "") then return end
    end
    local target_item = meta:get_string("target_item")
    if target_item and target_item ~= "" and minetest.registered_items[target_item] then
        local input_stack = inv:get_stack("input", 1)
        local output_stack = inv:get_stack("output", 1)
        -- make sure the target matches the output (including enchantments)
        if not inv:is_empty("output") then
            if exchangeclone.handle_alias(target_item) ~= output_stack:get_name() then
                return
            end
        end
        local result = exchangeclone.handle_alias(target_item)
        -- make sure star/player has enough EMC
        local current_emc
        if using_star then
            current_emc = exchangeclone.get_star_emc(inv, "star", 1)
        else
            current_emc = exchangeclone.get_player_emc(player)
        end
        local emc_value = exchangeclone.get_item_emc(input_stack:get_name())
        if emc_value and emc_value > 0 then
            local max_amount = math.min(input_stack:get_stack_max(), math.floor(current_emc/emc_value))
            local added_amount = max_amount - inv:add_item("output", ItemStack(result.." "..max_amount)):get_count()
            local result_emc = math.min(current_emc, current_emc - (emc_value * added_amount)) -- not sure if "math.min()" is necessary
            if using_star then
                exchangeclone.set_star_emc(inv, "star", 1, result_emc)
            else
                exchangeclone.set_player_emc(player, result_emc)
            end
        end
    end

    local timer = minetest.get_node_timer(pos)
    if not (target_item and target_item ~= "" and minetest.registered_items[target_item]) then
        timer:stop()
    else
        if not timer:is_started() then
            timer:start(1)
        end
    end
end

minetest.register_node("exchangeclone:emc_link", {
    description = "EMC Link\nAllows automation with personal EMC",
    tiles = {"exchangeclone_emc_link.png"},
	groups = {pickaxey=4, material_stone=1, cracky = 2, building_block = 1, level = exchangeclone.mtg and 2 or 0},
    on_rightclick = on_rightclick,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("star", 1)
        inv:set_size("input", 1)
        inv:set_size("output", 1)
        meta:set_string("infotext", "EMC Link")
    end,
    can_dig = exchangeclone.can_dig,
    after_dig_node = exchangeclone.drop_after_dig({"input", "star", "output"}),
    on_blast = exchangeclone.on_blast({"input", "star", "output"}),
    after_place_node = function(pos, player, itemstack, pointed_thing)
        local player_name = player:get_player_name()
        local meta = minetest.get_meta(pos)
        meta:set_string("exchangeclone_placer", player_name)
        meta:set_string("infotext", "EMC Link".."\n".."Owned by "..player_name)
        if exchangeclone.pipeworks then
            pipeworks.after_place(pos, player, itemstack, pointed_thing)
        end
    end,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	_mcl_blast_resistance = 10,
	_mcl_hardness = 8,
})