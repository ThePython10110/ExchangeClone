function get_energy_collector_formspec()
    if not exchangeclone.mineclone then
        local formspec = {
            "size[8,9]",
            "label[3,2;Orb]",
            "list[context;dst;4,2;1,1;]",
            "list[current_player;main;0,5;8,4;]",
            "listring[current_player;main]",
            "listring[context;dst]"
        }
        return table.concat(formspec, "")
    else
        local formspec = {
            "size[8,9]",
            "label[3,2;Orb]",
            "list[context;dist;4,2;1,1;]",
            mcl_formspec.get_itemslot_bg(4,2,1,1),
            "list[current_player;main;0,5;9,3;9]",
            mcl_formspec.get_itemslot_bg(0,5,9,3),
            "list[current_player;main;0,6;9,1;]",
            mcl_formspec.get_itemslot_bg(0,6,9,1),
            "listring[current_player;main]",
            "listring[context;dst]"
        }
    end
end

local function can_dig(pos, player)
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    return inv:is_empty("dst")
end

local function on_timer(pos, elapsed)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    -- get block above
    pos.y = pos.y + 1

    if inv:is_empty("dst") then
        -- stop timer
        minetest.get_node_timer(pos):stop()
        return false
    end

    if minetest.get_natural_light(pos) == 15 then
        local dest_orb = inv:get_stack("dst", 1)
        local stored = dest_orb:get_meta():get_int("stored_charge") or 0
        stored = stored + 1
        dest_orb:get_meta():set_int("stored_charge", stored)
        inv:set_stack("dst", 1, dest_orb)
    end
    return true
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("dst", 1)
    meta:set_string("formspec", get_energy_collector_formspec())
    meta:set_string("infotext", "Energy Collector")
    on_timer(pos, 0)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "dst" then
        if stack:get_name() == "exchangeclone:exchange_orb" then
            return stack:get_count()
        else
            return 0
        end
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

local function on_blast(pos)
    local drops = {}
    default.get_inventory_drops(pos, "dst", drops)
    drops[#drops+1] = "exchangeclone:energy_collector"
    minetest.remove_node(pos)
    return drops
end

minetest.register_node("exchangeclone:energy_collector", {
    description = "Energy Collector",
    tiles = {
        "ee_energy_collector_up.png",
        "ee_energy_collector_down.png",
        "ee_energy_collector_right.png",
        "ee_energy_collector_right.png",
        "ee_energy_collector_right.png",
        "ee_energy_collector_right.png"
    },
    groups = {cracky = 2},
    is_ground_content = false,
    can_dig = can_dig,
    on_timer = on_timer,
    on_construct = on_construct,
    on_metadata_inventory_move = function(pos)
        minetest.get_node_timer(pos):start(COLLECTOR_INTERVAL)
    end,
    on_metadata_inventory_put = function(pos)
        minetest.get_node_timer(pos):start(COLLECTOR_INTERVAL)
    end,
    on_metadata_inventory_take = function(pos)
        minetest.get_node_timer(pos):start(COLLECTOR_INTERVAL)
    end,
    on_blast = on_blast,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})

local recipe_item_1 = "default:steel_block"
local recipe_item_2 = "default:obsidian_glass"
local recipe_item_3 = "default:chest"

if exchangeclone.mineclone then
    recipe_item_1 = "mcl_core:ironblock"
    recipe_item_2 = "mcl_core:glass"
    recipe_item_3 = "mcl_chests:chest"
end

minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:energy_collector",
    recipe = {
        {recipe_item_2, recipe_item_2, recipe_item_2},
        {"exchangeclone:exchange_orb", recipe_item_3, "exchangeclone:exchange_orb"},
        {recipe_item_1, recipe_item_1, recipe_item_1}
    }
})
