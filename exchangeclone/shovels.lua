function exchangeclone.shovel_action(itemstack, player, center)
	if not (itemstack and player and center) then return end
	if exchangeclone.check_cooldown(player, "shovel") then return end
	local charge = itemstack:get_meta():get_int("exchangeclone_tool_charge") or 0
    local start_node = minetest.get_node(center)
    local action
    if exchangeclone.mcl then
        if minetest.registered_items[start_node.name]._on_shovel_place
        or minetest.get_item_group(start_node.name, "path_creation_possible") == 1 then
            if minetest.get_node(vector.offset(center,0,1,0)).name == "air" then
                action = "path"
            end
        end
    end
    if action ~= "path" then
        if exchangeclone.mcl2 and start_node.name == "mcl_core:grass_path" then
            action = "unpath"
        elseif minetest.get_item_group(start_node.name, "exchangeclone_dirt") or start_node.name:find("sand") then
            action = "crumbly_flat"
        elseif minetest.get_item_group(start_node.name, exchangeclone.mcl and "shovely" or "crumbly") then
            action = "crumbly"
        end
    end
    
    local groups_to_search, range_type
    if action == "path" then
        groups_to_search = exchangeclone.mcl2 and {"group:path_creation_possible"} or {"group:exchangeclone_dirt"}
        range_type = "flat"
    elseif action == "unpath" then
        groups_to_search = {"mcl_core:grass_path"}
        range_type = "flat"
    elseif action == "crumbly_flat" then
        groups_to_search = {"group:"..(exchangeclone.mcl and "shoveley" or "crumbly")}
        range_type = "flat"
    else
        groups_to_search = {start_node.name}
        range_type = "large_radius"
    end
	local vector1, vector2 = exchangeclone.process_range(player, range_type, charge)
    if not (vector1 and vector2) then vector1, vector2 = vector.zero(), vector.zero() end
    
	local pos1, pos2 = vector.add(center, vector1), vector.add(center, vector2)
	exchangeclone.play_ability_sound(player)
	local nodes = minetest.find_nodes_in_area(pos1, pos2, groups_to_search)
	for _, pos in pairs(nodes) do
        local node = minetest.get_node(pos)
		if minetest.is_protected(pos, player:get_player_name()) then
			minetest.record_protection_violation(pos, player:get_player_name())
		else
            if action == "path" then
                if exchangeclone.mcla then
                    if minetest.registered_items[node.name]._on_shovel_place then
                        minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pos}, true)
                        minetest.swap_node(pos, {name="mcl_core:grass_path"})
                    end
                else
                    minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pos}, true)
                    minetest.swap_node(pos, {name="mcl_core:grass_path"})
                end
            end
			local drops = minetest.get_node_drops(minetest.get_node(pos).name, itemstack)
			exchangeclone.drop_items_on_player(pos, drops, player)
		end
	end

	exchangeclone.remove_nodes(nodes)
	exchangeclone.start_cooldown(player, "shovel", charge/2)
end
    action = function(player, pos, node, data)
        if ((minetest.get_item_group(node.name, "crumbly") > 0) or (minetest.get_item_group(node.name, "shovely") > 0)) then
            if minetest.is_protected(pos, player:get_player_name()) then
                minetest.record_protection_violation(pos, player:get_player_name())
            else
                if data.path then
                    -- TODO: Fix potential "shovel_on_place" functions that aren't paths in Mineclonia (same with axes)
                    if minetest.registered_items[node.name]._on_shovel_place or
                    minetest.get_item_group(node.name, "path_creation_possible") == 1 then
                        if minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name == "air" then
                            minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pos}, true)
                            minetest.swap_node(pos, {name="mcl_core:grass_path"})
                        end
                    end
                else
                    local drops = minetest.get_node_drops(node.name, data.itemstack)
                    exchangeclone.drop_items_on_player(pos, drops, player)
                    table.insert(data.remove_positions, pos)
                end
            end
        end
        return data
    end,
    end_action = function(player, center, range, data)
        exchangeclone.remove_nodes(data.remove_positions)
        if range > 0 or not data.path then
            exchangeclone.start_cooldown(player, "shovel", range/4) -- Longish cooldown
        end
    end
}


local function shovel_on_place(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
        if itemstack:get_name():find("dark") then
            return exchangeclone.charge_update(itemstack, player, 3)
        else
            return exchangeclone.charge_update(itemstack, player, 4)
        end
    end

    local range = itemstack:get_meta():get_int("exchangeclone_tool_charge")

    local center = player:get_pos()
    if pointed_thing.type == "node" then
        center = pointed_thing.under
    end

   exchangeclone.node_radius_action(player, center, range, exchangeclone.shovel_action, itemstack)

    return itemstack
end

minetest.register_tool("exchangeclone:dark_matter_shovel", {
	description = "Dark Matter Shovel",
	wield_image = "exchangeclone_dark_matter_shovel.png",
	inventory_image = "exchangeclone_dark_matter_shovel.png",
	groups = { tool=1, shovel=1, dig_speed_class=5, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=6,
		damage_groups = {fleshy=7},
		punch_attack_uses = 0,
		groupcaps={
			crumbly = {times={[1]=0.9, [2]=0.45, [3]=0.225}, uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = shovel_on_place,
	on_secondary_use = shovel_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 16, level = 5, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:red_matter_shovel", {
	description = "Red Matter Shovel",
	wield_image = "exchangeclone_red_matter_shovel.png",
	inventory_image = "exchangeclone_red_matter_shovel.png",
	groups = { tool=1, shovel=1, dig_speed_class=6, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=7,
		damage_groups = {fleshy=9},
		punch_attack_uses = 0,
		groupcaps={
			crumbly = {times={[1]=0.6, [2]=0.25, [3]=0.1}, uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = shovel_on_place,
	on_secondary_use = shovel_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 19, level = 6, uses = 0 }
	},
})

--Crafting recipes

minetest.register_craft({
    output = "exchangeclone:dark_matter_shovel",
    recipe = {
        {"exchangeclone:dark_matter"},
        {exchangeclone.itemstrings.diamond},
        {exchangeclone.itemstrings.diamond}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_shovel",
    recipe = {
        {"exchangeclone:red_matter"},
        {"exchangeclone:dark_matter_shovel"},
        {"exchangeclone:dark_matter"}
    }
})