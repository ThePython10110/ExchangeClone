exchangeclone.pickaxe_group = exchangeclone.mcl and "pickaxey" or "cracky"

exchangeclone.shovel_group = exchangeclone.mcl and "shovely" or "crumbly"

exchangeclone.multidig_data = {tools = {}, players = {}}

function exchangeclone.register_multidig_tool(itemstring, nodes)
    exchangeclone.multidig_data.tools[itemstring] = nodes
end

function exchangeclone.multidig(pos, node, player, mode, nodes)
    if not player then return end
    local player_rotation = exchangeclone.get_face_direction(player)

    if mode == "3x3" then
        local dir1
        local dir2
        local unused_dir -- this variable is necessary because vectors get mad when it doesn't exist

        if player_rotation.y ~= 0 then
            dir1 = "x"
            dir2 = "z"
            unused_dir = "y"
        elseif player_rotation.x ~= 0 then
            dir1 = "y"
            dir2 = "z"
            unused_dir = "x"
        elseif player_rotation.z ~= 0 then
            dir1 = "x"
            dir2 = "y"
            unused_dir = "z"
        end

---@diagnostic disable-next-line: missing-fields
        local pos1 = vector.add(pos, {[dir1] = -1, [dir2] = -1, [unused_dir] = 0})
---@diagnostic disable-next-line: missing-fields
        local pos2 = vector.add(pos, {[dir1] = 1, [dir2] = 1, [unused_dir] = 0})
        local found_nodes = core.find_nodes_in_area(pos1, pos2, nodes)
        for _, node_pos in pairs(found_nodes) do
            core.node_dig(node_pos, core.get_node(node_pos), player)
        end
    elseif mode == "3x1_long" then
        local dir
        if player_rotation.y ~= 0 then
            dir = "y"
        elseif player_rotation.z ~= 0 then
            dir = "z"
        else
            dir = "x"
        end
        local added_vector = vector.zero()
        added_vector[dir] = player_rotation[dir]*2
        local pos2 = vector.add(pos, added_vector)
        local found_nodes = core.find_nodes_in_area(pos, pos2, nodes)
        for _, node_pos in pairs(found_nodes) do
            core.node_dig(node_pos, core.get_node(node_pos), player)
        end
    elseif mode == "3x1_tall" or mode == "3x1_wide" then
        local dir
        if mode == "3x1_tall" then
            if player_rotation.y ~= 0 then
                if player_rotation.x ~= 0 then
                    dir = "x"
                else
                    dir = "z"
                end
            else
                dir = "y"
            end
        else
            if player_rotation.x ~= 0 then
                dir = "z"
            else
                dir = "x"
            end
        end
        local vector1, vector2 = vector.zero(), vector.zero()
        vector1[dir] = -1
        vector2[dir] = 1
        local pos1 = vector.add(pos, vector1)
        local pos2 = vector.add(pos, vector2)
        local found_nodes = core.find_nodes_in_area(pos1, pos2, nodes)
        for _, node_pos in pairs(found_nodes) do
            core.node_dig(node_pos, core.get_node(node_pos), player)
        end
    end
end

core.register_on_dignode(function(pos, node, player)
    if not player then return end
    local player_name = player:get_player_name()
    if exchangeclone.multidig_data.players[player_name] then return end

    local wielded_item = player:get_wielded_item()
    local nodes = exchangeclone.multidig_data.tools[wielded_item:get_name()]
    if nodes then
        exchangeclone.multidig_data.players[player_name] = true
        local mode = wielded_item:get_meta():get_string("exchangeclone_multidig_mode")
        exchangeclone.multidig(pos, node, player, mode, nodes)
        exchangeclone.multidig_data.players[player_name] = nil
    end
end)

core.register_on_joinplayer(function(player)
    exchangeclone.multidig_data.players[player:get_player_name()] = nil
end)

exchangeclone.tool_levels = {
    count = {dark_matter = 3, red_matter = 4, red_multi = 5, phil = 5},
    efficiency = {
        dark_matter = {nil, 3, 5},
        red_matter = {nil, 3.5, 5, 7},
        red_multi = {nil, 3.5, 5, 7, 7.5}
    },
    range = {
        hammer = { -- hammer
            type = "front",
            ranges = {
                -- horizontal, vertical, depth (relative to look direction)
                -- horizontal/vertical are radii (1,1 = 3x3, 2,2 = 5,5)
                -- depth does NOT include starting position (1,1,1 mines 3x3x2 area)
                nil,
                {1,1,1},
                {2,2,2},
                {3,3,3},
                {4,4,4}
            }
        },
        flat = {
            type = "radius", -- shovel (dirt/sand), hoe
            ranges = {
                nil,
                vector.new(1,0,1),
                vector.new(2,0,2),
                vector.new(3,0,3),
                vector.new(4,0,4),
            }
        },
        basic_radius = { -- Philosopher's Stone
            type = "radius",
            ranges = {
                nil,
                vector.new(1,1,1),
                vector.new(2,2,2),
                vector.new(3,3,3),
                vector.new(4,4,4),
            }
        },
        large_radius = { -- shears, axe
            type = "radius",
            ranges = {
                nil,
                vector.new(4,4,4),
                vector.new(9,9,9),
                vector.new(14,14,14),
                vector.new(19,19,19),
            }
        },
    }
}

exchangeclone.charge_types = {}

function exchangeclone.set_charge_type(itemstring, type)
    exchangeclone.charge_types[itemstring] = type
end

function exchangeclone.add_range_setting(name, data)
    if not (name and data.type and data.ranges) then return end
    exchangeclone.tool_levels.range[name] = data
end

-- A table of estimated hardness values for MTG
-- Calculated by finding MTG nodes with the right group, then looking up the Minecraft hardness for them
local hacky_workaround = {
    snappy = {1.5, 0.8, 0.2},
    cracky = {5, 3, 2},
    choppy = {5, 3, 2},
    crumbly = {2, 0.6, 0.5}
}

function exchangeclone.get_mtg_times(speed, efficiency, group)
    if efficiency then speed = speed + efficiency*efficiency + 1 end
    local times = {}
    for i, hardness in ipairs(hacky_workaround[group]) do
        times[i] = math.ceil(30/(speed/hardness))/20
    end
    return times
end

-- Given an item and effiency level, return the groupcaps of the item with that efficiency level.
function exchangeclone.get_groupcaps(item, efficiency)
    item = ItemStack(item)
    if exchangeclone.mcl then
        local groupcaps = mcl_autogroup.get_groupcaps(item:get_name(), efficiency)
        return groupcaps
    else -- This only works if the tool is the same speed for every group.
        local groupcaps = table.copy(core.registered_items[item:get_name()].tool_capabilities.groupcaps)
        local next, mcl_diggroups = pairs(item:get_definition()._mcl_diggroups)
        local _, mcl_group_def = next(mcl_diggroups)
        local speed = mcl_group_def.speed

        if not groupcaps then return end
        for group, _ in pairs(groupcaps) do
            local test_group = group
            if test_group == "exchangeclone_dirt" then test_group = "crumbly" end
            groupcaps[group].times = exchangeclone.get_mtg_times(speed, efficiency, test_group)
        end
        return groupcaps
    end
end

function exchangeclone.update_tool_capabilities(itemstack)
    itemstack = ItemStack(itemstack) -- don't affect original
    local charge_type = exchangeclone.charge_types[itemstack:get_name()]
    if not exchangeclone.tool_levels.efficiency[charge_type] then return itemstack end
    local meta = itemstack:get_meta()
    local charge_level = math.max(1, meta:get_int("exchangeclone_tool_charge"))
    local efficiency = exchangeclone.tool_levels.efficiency[charge_type][charge_level]
    local tool_capabilities = table.copy(core.registered_items[itemstack:get_name()].tool_capabilities)
    tool_capabilities.groupcaps = exchangeclone.get_groupcaps(itemstack, efficiency)
    meta:set_tool_capabilities(tool_capabilities)
    return itemstack
end

exchangeclone.neighbors = {
    {x=0, y=-1, z=0},
    {x=0, y=1, z=0},
    {x=-1, y=0, z=0},
    {x=1, y=0, z=0},
    {x=0, y=0, z=-1},
    {x=0, y=0, z=1},
}

---Check for nearby nodes that should fall
---@param pos vector.Vector
function exchangeclone.check_nearby_falling(pos)
	for i = 1, 6 do
        local new_pos = vector.add(pos, exchangeclone.neighbors[i])
        if exchangeclone.mcl then
            local node = core.get_node(new_pos)
            if node.name == "mcl_core:vine" then
                mcl_core.check_vines_supported(new_pos, node)
            end
        end
	end
    core.check_for_falling(pos)
end

---Remove nodes with callbacks
---@param positions vector.Vector[]
function exchangeclone.remove_nodes(positions)
    core.bulk_set_node(positions, {name = "air"})
    for _, pos in pairs(positions) do
        if pos then
            exchangeclone.check_nearby_falling(pos)
        end
    end
end

function exchangeclone.drop_after_dig(lists)
    return function(pos, oldnode, oldmetadata, player)
        if exchangeclone.mcl then
            local meta = core.get_meta(pos)
            local meta2 = meta:to_table() --[[@as core.MetaDataTable]]
            meta:from_table(oldmetadata)
            local inv = meta:get_inventory()
            for _, listname in pairs(lists) do
                for i = 1, inv:get_size(listname) do
                    local stack = inv:get_stack(listname, i)
                    if not stack:is_empty() then
                        local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                        core.add_item(p, stack)
                    end
                end
            end
            meta:from_table(meta2)
        end
        if exchangeclone.pipeworks then
            pipeworks.after_dig(pos)
        end
    end
end