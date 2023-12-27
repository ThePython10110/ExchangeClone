local S = minetest.get_translator()

local formspec =
    "size["..(exchangeclone.mcl and 9 or 8)..",9]"..
    "label[2,1;"..S("Orb").."]"..
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
    local using_orb = true
    local player
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if inv:get_stack("fuel", 1):get_name() ~= "exchangeclone:exchange_orb" then
        using_orb = false
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
        -- make sure orb/player has enough energy
        local current_energy
        if using_orb then
            current_energy = exchangeclone.get_orb_energy(inv, "fuel", 1)
        else
            current_energy = exchangeclone.get_player_energy(player)
        end
        local energy_value = exchangeclone.get_item_energy(src_stack:get_name())
        if energy_value and energy_value > 0 then
            local max_amount = math.min(src_stack:get_stack_max(), math.floor(current_energy/energy_value))
            local added_amount = max_amount - inv:add_item("dst", ItemStack(result.." "..max_amount)):get_count()
            local result_energy = math.min(current_energy, current_energy - (energy_value * added_amount)) -- not sure if "math.min()" is necessary
            if using_orb then
                exchangeclone.set_orb_energy(inv, "fuel", 1, result_energy)
            else
                exchangeclone.set_player_energy(player, result_energy)
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
        if stack:get_name() == "exchangeclone:exchange_orb" then
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

local pipeworks_connect = exchangeclone.pipeworks and "^pipeworks_tube_connection_metallic.png" or ""

minetest.register_node("exchangeclone:constructor", {
    description = S("Constructor"),
    tiles = {
        "exchangeclone_constructor_up.png"..pipeworks_connect,
        "exchangeclone_constructor_down.png"..pipeworks_connect,
        "exchangeclone_constructor_right.png"..pipeworks_connect,
        "exchangeclone_constructor_right.png"..pipeworks_connect,
        "exchangeclone_constructor_right.png"..pipeworks_connect,
        "exchangeclone_constructor_right.png"..pipeworks_connect,
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
	_mcl_hoppers_on_try_push = exchangeclone.mcl2_hoppers_on_try_push(nil, function(stack) return stack:get_name() == "exchangeclone:exchange_orb" end),
	_mcl_hoppers_on_after_push = function(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	_on_hopper_in = exchangeclone.mcla_on_hopper_in(
        nil,
        function(stack) return stack:get_name() == "exchangeclone:exchange_orb" end
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
                    if stack:get_name() == "exchangeclone:exchange_orb" then
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
        {"exchangeclone:exchange_orb"},
        {recipe_ingredient},
        {"exchangeclone:exchange_orb"}
    }
})