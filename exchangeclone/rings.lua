minetest.register_tool("exchangeclone:zero_ring", {
    description = "Zero Ring",
    inventory_image = "exchangeclone_zero_ring.png",
    _exchangeclone_passive = {
        func = function() end,
        active_image = "exchangeclone_zero_ring_active.png",
    }
})

local set_fire

if exchangeclone.mcl then
    set_fire = function(player, pos)
		-- Check protection
		local protname = player:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
		end
        local above = vector.offset(pos, 0,1,0)
        local pointed_thing = {type="node",under=pos,above=above}
        local nodedef = minetest.registered_nodes[minetest.get_node(pos).name]
        if nodedef and nodedef._on_ignite then
            local overwrite = nodedef._on_ignite(player, pointed_thing)
            if not overwrite then
                mcl_fire.set_fire(pointed_thing, player, false)
            end
        else
            mcl_fire.set_fire(pointed_thing, player, false)
        end
    end
elseif exchangeclone.exile then
    --FIXME: implement set_fire
else
    assert(exchangeclone.mtg)
    set_fire = function(player, pos)
		local protname = player:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
		end
        local nodedef = minetest.registered_nodes[minetest.get_node(pos).name]
        local above = vector.offset(pos, 0,1,0)
        if nodedef.on_ignite then
            nodedef.on_ignite(pos, player)
        else
            minetest.set_node(above, {name = "fire:basic_flame"})
        end
    end
end

minetest.register_tool("exchangeclone:ring_of_ignition", {
    description = "Ring of Ignition",
    inventory_image = "exchangeclone_ring_of_ignition.png",
    on_secondary_use = exchangeclone.toggle_active,
    on_place = exchangeclone.toggle_active,
    _exchangeclone_passive = {
        func = function(player)
            local player_pos = player:get_pos()
            local offset = vector.new(5,1,5)
            local start, _end = player_pos + offset, player_pos - offset
            minetest.log(dump({start = start, _end = _end}))
             -- conveniently, MTG and MCL agree on the flammable group
            local nodes = minetest.find_nodes_in_area(start, _end, "group:flammable")
            for _, pos in pairs(nodes) do
                local above_pos = vector.offset(pos,0,1,0)
                if minetest.get_node(above_pos).name == "air" then
                    if math.random() < 0.2 then
                        set_fire(player, pos)
                    end
                end
            end
        end,
        active_image = "exchangeclone_ring_of_ignition_active.png",
    }
})