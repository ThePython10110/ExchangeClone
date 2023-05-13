local function get_energy_collector_formspec()
    if not exchangeclone.mineclone then
        local formspec = {
            "size[8,9]",
            "label[3,2;Orb]",
            "list[context;main;4,2;1,1;]",
            "list[current_player;main;0,5;8,4;]",
            "listring[current_player;main]",
            "listring[context;main]"
        }
        return table.concat(formspec, "")
    else
        local formspec = {
            "size[9,10]",
            "label[3,2;Orb]",
            "list[context;main;4,2;1,1;]",
            mcl_formspec.get_itemslot_bg(4,2,1,1),
            "list[current_player;main;0,5;9,3;9]",
            mcl_formspec.get_itemslot_bg(0,5,9,3),
            "list[current_player;main;0,8.5;9,1;]",
            mcl_formspec.get_itemslot_bg(0,8.5,9,1),
            "listring[current_player;main]",
            "listring[context;main]"
        }
        return table.concat(formspec, "")
    end
end

local function can_dig(pos, player)
    if exchangeclone.mineclone then return true end
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    return inv:is_empty("main")
end

local function on_timer(pos, elapsed)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    -- get block above
    pos.y = pos.y + 1

    if inv:is_empty("main") then
        -- stop timer
        minetest.get_node_timer(pos):stop()
        return false
    end

    if minetest.get_natural_light(pos) == 15 then
        local dest_orb = inv:get_stack("main", 1)
        local stored = dest_orb:get_meta():get_float("stored_charge") or 0
        stored = stored + 1
        dest_orb:get_meta():set_float("stored_charge", stored)
        dest_orb:get_meta():set_string("description", "Exchange Orb\nCurrent Charge: "..tostring(stored))
        inv:set_stack("main", 1, dest_orb)
    end
    return true
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 1)
    meta:set_string("formspec", get_energy_collector_formspec())
    meta:set_string("infotext", "Energy Collector")
    on_timer(pos, 0)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        minetest.log("blocked put")
        return 0
    end
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "main" then
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
        minetest.log("blocked take")
        return 0
    end
    return stack:get_count()
end

local function on_blast(pos)
    local drops = {}
    exchangeclone.get_inventory_drops(pos, "main", drops)
    drops[#drops+1] = "exchangeclone:energy_collector"
    minetest.remove_node(pos)
    
    return drops
end


local function on_dig_node(pos, oldnode, oldmetadata, digger)
    if exchangeclone.mineclone then
        local meta = minetest.get_meta(pos)
        local meta2 = meta:to_table()
        meta:from_table(oldmetadata)
        local inv = meta:get_inventory()
        for _, listname in ipairs({"main"}) do
            local stack = inv:get_stack(listname, 1)
            if not stack:is_empty() then
                local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                minetest.add_item(p, stack)
            end
        end
        meta:from_table(meta2)
    end
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
    groups = {cracky = 2, container = 2},
    is_ground_content = false,
    can_dig = can_dig,
    on_timer = on_timer,
    on_construct = on_construct,
    on_dig_node = on_dig_node,
    on_metadata_inventory_move = function(pos)
        minetest.get_node_timer(pos):start(exchangeclone.collector_interval)
    end,
    on_metadata_inventory_put = function(pos)
        minetest.get_node_timer(pos):start(exchangeclone.collector_interval)
    end,
    on_metadata_inventory_take = function(pos)
        minetest.get_node_timer(pos):start(exchangeclone.collector_interval)
    end,
    on_blast = on_blast,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})

--[[if minetest.get_modpath("pipeworks") then
    minetest.override_item("exchangeclone:energy_collector", {
        tube = {
            input_inventory = "main",
            connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1},
            insert_object = function(pos, node, stack, direction)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                return inv:add_item("main", stack)
            end,
            can_insert = function(pos, node, stack, direction)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                if stack:get_name() == "exchangeclone:exchange_orb" then
                    minetest.log(inv:room_for_item("main", stack))
                    return inv:room_for_item("main", stack)
                else
                    minetest.log("failed")
                end
            end,
        },
        after_place_node = function(pos, placer)
            pipeworks.after_place(pos)
        end,
        after_dig_node = pipeworks.after_dig,
        on_rotate = pipeworks.on_rotate,
    })
end]]

local recipe_item_1 = "default:steelblock"
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
