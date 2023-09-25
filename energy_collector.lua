local function get_energy_collector_formspec()
    local formspec
    if not exchangeclone.mineclone then
        formspec = {
            "size[8,9]",
            "label[3,2;Orb]",
            "list[context;main;4,2;1,1;]",
            "list[current_player;main;0,5;8,4;]",
            "listring[current_player;main]",
            "listring[context;main]"
        }
    else
        formspec = {
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
    end
    return table.concat(formspec, "")
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

    -- get node above
    pos.y = pos.y + 1

    if meta:get_bool("connected_to_furnace") then
        -- do nothing, energy is being used for the furnace.
        return
    end


    local using_orb = true
    if inv:is_empty("main") then
        -- stop timer
        using_orb = false
    end

    if minetest.get_artificial_light(pos) >= 14 then
        local amount = meta:get_int("collector_amount")
        if using_orb then
            local dest_orb = inv:get_stack("main", 1)
            local stored = exchangeclone.get_orb_energy(inv, "main", 1)
            if stored + amount < exchangeclone.energy_max then
                stored = stored + amount`
                exchangeclone.set_orb_energy(inv, "main", 1, stored)
            end
        else
            local placer = meta:get_string("collector_placer")
            if placer and placer ~= "" then
                player = minetest.get_player_by_name(placer)
                if player then
                    local player_energy = exchangeclone.get_player_energy(player)
                    exchangeclone.set_player_energy(player_energy + amount)
                end
            end
        end
    end
    return true
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 1)
    meta:set_string("formspec", get_energy_collector_formspec())
    on_timer(pos, 1, 4)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
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

local function on_dig_node(pos, oldnode, oldmetadata, player)
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

function exchangeclone.register_energy_collector(itemstring, name, amount, modifier)
    minetest.register_node(itemstring, {
        description = "Energy Collector",
        tiles = {
            "exchangeclone_energy_collector_up.png"..modifier,
            "exchangeclone_energy_collector_down.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier
        },
        groups = {cracky = 2, container = 2, pickaxey = 2},
        _mcl_hardness = 3,
        _mcl_blast_resistance = 6,
        sounds = exchangeclone.sound_mod.node_sound_metal_defaults(),
        is_ground_content = false,
        can_dig = can_dig,
        on_timer = function(pos, elapsed) on_timer(pos, elapsed, amount) end,
        on_construct = on_construct,
        after_dig_node = on_dig_node,
        on_metadata_inventory_move = function(pos)
            minetest.get_node_timer(pos):start(1)
        end,
        on_metadata_inventory_put = function(pos)
            minetest.get_node_timer(pos):start(1)
        end,
        on_metadata_inventory_take = function(pos)
            minetest.get_node_timer(pos):start(1)
        end,
        after_place_node = function(pos, player, itemstack, pointed_thing)
            local player_name = player:get_player_name()
            meta:set_int("collector_amount", amount)
            meta:set_string("collector_placer", player_name)
            meta:set_string("infotext", name.."\nOwned by"..player_name)
        end
        on_blast = on_blast,
        allow_metadata_inventory_put = allow_metadata_inventory_put,
        allow_metadata_inventory_move = allow_metadata_inventory_move,
        allow_metadata_inventory_take = allow_metadata_inventory_take,
    })
end

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
        after_place_node = function(pos, player)
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
