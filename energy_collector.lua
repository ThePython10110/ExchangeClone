local function get_energy_collector_formspec()
    local formspec
    if not exchangeclone.mcl then
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

minetest.register_alias("exchangeclone:energy_collector", "exchangeclone:energy_collector_mk1")

-- Register LBM to update deconstructors
minetest.register_lbm({
    name = "exchangeclone:collector_alert",
    nodenames = {"exchangeclone:energy_collector_mk1"},
    run_at_every_load = false,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", "size[3,1]label[0,0;Break and replace.\nNothing will be lost.]")
    end,
})

local check_positions = {
	{x=0,y=0,z=1},
	{x=0,y=0,z=-1},
	{x=0,y=1,z=0},
	{x=0,y=-1,z=0},
	{x=1,y=0, z=0},
	{x=-1,y=0,z=0},
}

local function check_for_furnaces(pos, set_furnace, start)
	local found = false
	for _, check_pos in ipairs(check_positions) do
		local new_pos = vector.add(pos, check_pos)
		local node = minetest.get_node(new_pos)
        local furnace = minetest.get_item_group(node.name, "exchangeclone_furnace")
		if furnace > 0 then
            found = true
            if start then
                local timer = minetest.get_node_timer(new_pos)
                if not timer:is_started() then
                    if furnace == 1 then -- Dark Matter
                        timer:start(0.45)
                    elseif furnace == 2 then -- Red Matter
                        timer:start(0.16)
                    end
                end
            end
			if set_furnace ~= nil then
                local meta = minetest.get_meta(new_pos)
                meta:set_int("using_collector", set_furnace)
			end
		end
	end
	return found
end

local function can_dig(pos, player)
    if exchangeclone.mcl then return true end
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    return inv:is_empty("main")
end

local function on_timer(pos, elapsed)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    -- get node above
    local above = vector.add({x=0,y=1,z=0}, pos)

    local using_orb = true
    if inv:is_empty("main") then
        using_orb = false
    end

    local light = minetest.get_natural_light(above)

    if light and light >= 14 then
        if check_for_furnaces(pos, 1, true) then
            -- do nothing, energy is being used for the furnace.
            return true
        end
        local amount = meta:get_int("collector_amount")
        if using_orb then
            local stored = exchangeclone.get_orb_energy(inv, "main", 1)
            if stored + amount <= exchangeclone.orb_max then
                stored = stored + amount
            else
                stored = math.max(stored, exchangeclone.orb_max)
            end
            exchangeclone.set_orb_energy(inv, "main", 1, stored)
        else
            local placer = meta:get_string("exchangeclone_placer")
            if placer and placer ~= "" then
                local player = minetest.get_player_by_name(placer)
                if player then
                    local player_energy = exchangeclone.get_player_energy(player)
                    exchangeclone.set_player_energy(player, player_energy + amount)
                end
            end
        end
    else
        check_for_furnaces(pos, 0)
    end
    return true
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 1)
    meta:set_string("formspec", get_energy_collector_formspec())
    minetest.get_node_timer(pos):start(1)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
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
    if exchangeclone.mcl then
        local meta = minetest.get_meta(pos)
        local meta2 = meta:to_table()
        meta:from_table(oldmetadata)
        local inv = meta:get_inventory()
        local stack = inv:get_stack("main", 1)
        if not stack:is_empty() then
            local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
            minetest.add_item(p, stack)
        end
        meta:from_table(meta2)
    end
end

function exchangeclone.register_energy_collector(itemstring, name, amount, modifier, recipe)
    minetest.register_node(itemstring, {
        description = name,
        tiles = {
            "exchangeclone_energy_collector_up.png"..modifier,
            "exchangeclone_energy_collector_down.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier,
            "exchangeclone_energy_collector_right.png"..modifier
        },
        groups = {cracky = 2, container = 2, pickaxey = 2, energy_collector = amount},
        _mcl_hardness = 3,
        _mcl_blast_resistance = 6,
        sounds = exchangeclone.sound_mod.node_sound_metal_defaults(),
        is_ground_content = false,
        can_dig = can_dig,
        on_timer = on_timer,
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
        on_destruct = function(pos, large)
            check_for_furnaces(pos, 0)
        end,
        after_place_node = function(pos, player, itemstack, pointed_thing)
            local player_name = player:get_player_name()
            local meta = minetest.get_meta(pos)
            meta:set_int("collector_amount", amount)
            meta:set_string("exchangeclone_placer", player_name)
            meta:set_string("infotext", name.."\nOwned by"..player_name)
        end,
        on_blast = on_blast,
        allow_metadata_inventory_put = allow_metadata_inventory_put,
        allow_metadata_inventory_move = allow_metadata_inventory_move,
        allow_metadata_inventory_take = allow_metadata_inventory_take,
    })
    minetest.register_craft({
        output = itemstring,
        recipe = recipe
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

local iron = "default:steelblock"
local glass = "default:glass"
local chest = "default:chest"

if exchangeclone.mcl then
    iron = "mcl_core:ironblock"
    glass = "mcl_core:glass"
    chest = "mcl_chests:chest"
end

exchangeclone.register_energy_collector("exchangeclone:energy_collector_mk1", "Energy Collector MK1", 4, "", {
        {glass, glass, glass},
        {"exchangeclone:exchange_orb", chest, "exchangeclone:exchange_orb"},
        {iron, iron, iron}
    }
)

exchangeclone.register_energy_collector("exchangeclone:energy_collector_mk2", "Energy Collector MK2", 12, "^[multiply:#555555", {
        {iron, iron, iron},
        {"exchangeclone:energy_collector_mk1", "exchangeclone:energy_collector_mk1", "exchangeclone:energy_collector_mk1"},
        {iron, iron, iron}
    }
)

exchangeclone.register_energy_collector("exchangeclone:energy_collector_mk3", "Energy Collector MK3", 40, "^[multiply:#770000", {
        {iron, iron, iron},
        {"exchangeclone:energy_collector_mk2", "exchangeclone:energy_collector_mk2", "exchangeclone:energy_collector_mk2"},
        {iron, iron, iron}
    }
)

exchangeclone.register_energy_collector("exchangeclone:energy_collector_mk4", "Energy Collector MK4", 160, "^[multiply:#007700", {
        {iron, iron, iron},
        {"exchangeclone:energy_collector_mk3", "exchangeclone:energy_collector_mk3", "exchangeclone:energy_collector_mk3"},
        {iron, iron, iron}
    }
)

exchangeclone.register_energy_collector("exchangeclone:energy_collector_mk5", "Energy Collector MK5", 640, "^[multiply:#000077", {
        {iron, iron, iron},
        {"exchangeclone:energy_collector_mk4", "exchangeclone:energy_collector_mk4", "exchangeclone:energy_collector_mk4"},
        {iron, iron, iron}
    }
)
