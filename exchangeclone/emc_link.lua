local S = minetest.get_translator()

local formspec = table.concat({
    "size[",(exchangeclone.mcl and 9 or 8),",9]",
    "label[1,2;",S("Input"),"]",
    "list[context;input;2,2;1,1;]",
    "label[4,1;",S("Target"),"]",
    "list[context;target;3,1;1,1;]",
    "label[4,2;",S("Star"),"]",
    "list[context;star;3,2;1,1;]",
    "label[4,3;",S("Output"),"]",
    "list[context;output;3,3;1,1;]",
    exchangeclone.inventory_formspec(0,5),
    "listring[current_player;main]",
    "listring[context;input]",
    "listring[current_player;main]",
    "listring[context;star]",
    "listring[current_player;main]",
    "listring[context;target]",
    "listring[current_player;main]",
    "listring[context;output]",
})
if exchangeclone.mcl then
    formspec = formspec..
    mcl_formspec.get_itemslot_bg(3,1,1,3)..
    mcl_formspec.get_itemslot_bg(2,2,1,1)
end

local function link_action(pos)
    minetest.log("woo")
    local player
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local limit
    local using_star
    local input_stack = inv:get_stack("input", 1)
    local stored_emc
    local target = inv:get_stack("target", 1):get_name()
    local output_stack = inv:get_stack("output", 1)
    local in_indiv_emc = exchangeclone.get_item_emc(input_stack:peek_item(1)) or 0
    local target_emc = exchangeclone.get_item_emc(target)
    local stack_max = ItemStack(target):get_stack_max()

    local star_stack = inv:get_stack("star", 1)
    if minetest.get_item_group(star_stack:get_name(), "klein_star") > 0 then
        using_star = true
        limit = exchangeclone.get_star_max(star_stack)
        stored_emc = exchangeclone.get_star_itemstack_emc(star_stack)
        minetest.log("oh no")
    else
        using_star = false
        limit = exchangeclone.limit
        player = minetest.get_player_by_name(meta:get_string("exchangeclone_placer"))
        if not (player and player ~= "") then minetest.log(dump(meta:get_string("exchangeclone_placer"))) return end
        stored_emc = exchangeclone.get_player_emc(player)
    end
    -- Construct
    minetest.log(dump({target, output_stack:get_name()}))
    if target ~= "" and (output_stack:is_empty() or exchangeclone.handle_alias(output_stack) == target) then
        local out_count = math.min(stack_max - output_stack:get_count(), math.floor(stored_emc/target_emc))
        if out_count > 0 then
            inv:add_item("output", ItemStack(target.." "..out_count))
            if using_star then
                exchangeclone.add_star_emc(inv, "star", 1, star_stack, -out_count*target_emc)
            else
                exchangeclone.add_player_emc(player, -out_count*target_emc)
            end
        end
    end

    -- Deconstruct
    if not input_stack:is_empty() and stored_emc < limit then
        local max_count = math.min(math.floor((limit - stored_emc)/in_indiv_emc), input_stack:get_count())
        if max_count > 0 then
            inv:remove_item("input", ItemStack(input_stack:get_name().." "..max_count))
            if using_star then
                exchangeclone.add_star_emc(inv, "star", 1, max_count*in_indiv_emc)
            else
                exchangeclone.add_player_emc(player, max_count*in_indiv_emc)
            end
        end
    end

    local timer = minetest.get_node_timer(pos)
    if inv:get_stack("input", 1):is_empty() and inv:get_stack("target", 1):is_empty() then
        timer:stop()
    else
        if not timer:is_started() then
            timer:start(1)
        end
    end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if player and player.get_player_name and minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    if listname == "star" then
        if minetest.get_item_group(stack:get_name(), "klein_star") > 0 then
            return stack:get_count()
        end
    elseif listname == "input" then
        local emc = exchangeclone.get_item_emc(stack)
        if emc and emc > 0 then
            return stack:get_count()
        end
    elseif listname == "target" then
        local single_item = stack:peek_item(1)
        local emc = exchangeclone.get_item_emc(single_item)
        if emc and emc > 0 then
            minetest.get_meta(pos):get_inventory():set_stack("target", 1, ItemStack(exchangeclone.handle_alias(single_item)))
            link_action(pos)
        end
    end
    return 0
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack(from_list, from_index)
    return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    if listname == "target" then
        minetest.get_meta(pos):get_inventory():set_stack("target", 1, ItemStack(""))
        link_action(pos)
        return 0
    else
        return stack:get_count()
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
        inv:set_size("target", 1)
        meta:set_string("infotext", "EMC Link")
        meta:set_string("formspec", formspec)
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
    on_metadata_inventory_put = link_action,
    on_metadata_inventory_move = link_action,
    on_metadata_inventory_take = link_action,
    on_timer = link_action,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	_mcl_blast_resistance = 10,
	_mcl_hardness = 8,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})