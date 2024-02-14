local S = minetest.get_translator()

local formspec =
    "size["..(exchangeclone.mcl and 9 or 8)..",9]"..
    "label[2,1;"..S("Star").."]"..
    "list[context;fuel;2,2;1,1;]"..
    "label[3,1;"..S("Source").."]"..
    "list[context;src;3,2;1,1;]"..
    "label[5,1;"..S("Output").."]"..
    "list[context;dst;5,2;1,1;]"..
    exchangeclone.inventory_formspec(0,5)..
    "listring[current_player;main]"..
    "listring[context;src]"..
    "listring[current_player;main]"..
    "listring[context;fuel]"..
    "listring[current_player;main]"..
    "listring[context;dst]"
if exchangeclone.mcl then
    formspec = formspec..
        mcl_formspec.get_itemslot_bg(2,2,1,1)..
        mcl_formspec.get_itemslot_bg(3,2,1,1)..
        mcl_formspec.get_itemslot_bg(5,2,1,1)
end

minetest.register_alias("exchangeclone:element_constructor", "exchangeclone:constructor")

local function constructor_action(pos)
    local using_star = true
    local player
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if minetest.get_item_group(inv:get_stack("fuel", 1):get_name(), "klein_star") < 1 then
        using_star = false
        player = minetest.get_player_by_name(meta:get_string("exchangeclone_placer"))
        if not (player and player ~= "") then return end
    end
    local src_stack = inv:get_stack("src", 1)
    local dst_stack = inv:get_stack("dst", 1)

    if not inv:is_empty("src") then
        -- make sure the stack at dst is same as the src (including enchantments)
        if not inv:is_empty("dst") then
            if exchangeclone.handle_alias(src_stack) ~= dst_stack:get_name() then
                return
            end
        end
        local result = exchangeclone.handle_alias(src_stack)
        -- make sure star/player has enough EMC
        local current_emc
        if using_star then
            current_emc = exchangeclone.get_star_emc(inv, "fuel", 1)
        else
            current_emc = exchangeclone.get_player_emc(player)
        end
        local emc_value = exchangeclone.get_item_emc(src_stack:get_name())
        if emc_value and emc_value > 0 then
            local max_amount = math.min(src_stack:get_stack_max(), math.floor(current_emc/emc_value))
            local added_amount = max_amount - inv:add_item("dst", ItemStack(result.." "..max_amount)):get_count()
            local result_emc = math.min(current_emc, current_emc - (emc_value * added_amount)) -- not sure if "math.min()" is necessary
            if using_star then
                exchangeclone.set_star_emc(inv, "fuel", 1, result_emc)
            else
                exchangeclone.set_player_emc(player, result_emc)
            end
        end
    end

    local timer = minetest.get_node_timer(pos)
    if inv:get_stack("src", 1):is_empty() then
        timer:stop()
    else
        if not timer:is_started() then
            timer:start(1) -- keep trying to construct if there are items in the src stack
        end
    end
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    meta:set_string("formspec", formspec)
    meta:set_string("infotext", S("Constructor"))
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if player and player.get_player_name and minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    if listname == "fuel" then
        if minetest.get_item_group(stack:get_name(), "klein_star") > 0 then
            return stack:get_count()
        else
            return 0
        end
    elseif listname == "src" then
        return stack:get_count()

    elseif listname == "dst" then
        return 0
    end
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
    return stack:get_count()
end

minetest.register_node("exchangeclone:constructor", {
    description = S("Constructor"),
    tiles = {
        "exchangeclone_constructor_up.png",
        "exchangeclone_constructor_down.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
    },
    groups = {cracky = 2, container = exchangeclone.mcl2 and 2 or 4, pickaxey = 2, tubedevice = 1, tubedevice_receiver = 1},
    _mcl_hardness = 3,
	_mcl_blast_resistance = 6,
    sounds = exchangeclone.sound_mod.node_sound_metal_defaults(),
    is_ground_content = false,
    can_dig = exchangeclone.can_dig,
    after_dig_node = exchangeclone.drop_after_dig({"src", "fuel", "dst"}),
    after_place_node = function(pos, player, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        meta:set_string("exchangeclone_placer", player:get_player_name())
        if exchangeclone.pipeworks then
            pipeworks.after_place(pos, player, itemstack, pointed_thing)
        end
    end,
    on_construct = on_construct,
    on_metadata_inventory_move = constructor_action,
    on_metadata_inventory_put = constructor_action,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        constructor_action(pos)
    end,
    on_blast = exchangeclone.on_blast({"src", "fuel", "dst"}),
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
    on_timer = constructor_action,
	_mcl_hoppers_on_try_pull = exchangeclone.mcl2_hoppers_on_try_pull(),
	_mcl_hoppers_on_try_push = exchangeclone.mcl2_hoppers_on_try_push(nil, function(stack) return minetest.get_item_group(stack:get_name(), "klein_star") > 0 end),
	_mcl_hoppers_on_after_push = function(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	_on_hopper_in = exchangeclone.mcla_on_hopper_in(
        nil,
        function(stack) return minetest.get_item_group(stack:get_name(), "klein_star") > 0 end
    ),
})

if exchangeclone.pipeworks then
    local function get_list(direction)
        return (direction.y == 0 and "src") or "fuel"
    end
    minetest.override_item("exchangeclone:constructor", {
        tube = {
            input_inventory = "dst",
            connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1},
            insert_object = function(pos, node, stack, direction)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                local result = inv:add_item(get_list(direction), stack)
                if result then
                    constructor_action(pos)
                end
                return result
            end,
            can_insert = function(pos, node, stack, direction)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                if get_list(direction) == "fuel" then
                    if minetest.get_item_group(stack:get_name(), "klein_star") > 0 then
                        return inv:room_for_item("fuel", stack)
                    end
                else
                    return inv:room_for_item("src", stack)
                end
            end,
        },
        on_rotate = pipeworks.on_rotate,
    })
end

local recipe_ingredient = "default:pick_diamond"

if exchangeclone.mcl then
    recipe_ingredient = "mcl_tools:pick_diamond"
end
minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:constructor",
    recipe = {
        {"exchangeclone:klein_star_drei"},
        {recipe_ingredient},
        {"exchangeclone:klein_star_drei"}
    }
})