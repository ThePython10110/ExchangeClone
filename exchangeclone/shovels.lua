function exchangeclone.shovel_action(itemstack, player, center)
	if not (itemstack and player and center) then return end
	if exchangeclone.check_cooldown(player, "shovel") then return end
	local charge = math.max(itemstack:get_meta():get_int("exchangeclone_tool_charge"), 1)
    local start_node = minetest.get_node(center)
    local action
    if exchangeclone.mcl then
        if minetest.registered_items[start_node.name]._on_shovel_place
        or minetest.get_item_group(start_node.name, "path_creation_possible") == 1 then
            if minetest.get_node(vector.offset(center,0,1,0)).name == "air" then
                if (not player:get_player_control().sneak or charge == 1) then
                    action = "path"
                end
            end
        end
    end
    if action ~= "path" then
        if exchangeclone.mcl2 and start_node.name == "mcl_core:grass_path" and
        (not player:get_player_control().sneak or charge == 1) then
            action = "unpath"
        elseif start_node.name == exchangeclone.itemstrings.gravel or start_node.name == exchangeclone.itemstrings.clay then
            if charge > 1 then
                action = "crumbly"
            else
                return
            end
        elseif charge > 1  then
            action = "crumbly_flat"
        end
    end

    local groups_to_search, range_type
    if action == "path" then
        groups_to_search = exchangeclone.mcl2 and {"group:path_creation_possible"} or {"group:exchangeclone_dirt"}
        range_type = "flat"
    elseif action == "unpath" then
        groups_to_search = {"mcl_core:grass_path"}
        range_type = "flat"
    elseif action == "crumbly" then
        groups_to_search = {start_node.name}
        range_type = "large_radius"
    else
        groups_to_search = {"group:"..(exchangeclone.mcl and "shovely" or "crumbly")}
        range_type = "flat"
    end
    local nodes
    if charge > 1 then
        local vector1, vector2 = exchangeclone.process_range(player, range_type, charge)
        local pos1, pos2 = vector.add(center, vector1), vector.add(center, vector2)
        if action == "path" or action == "unpath" then
            exchangeclone.play_sound(player, "exchangeclone_charge_up")
        else
            exchangeclone.play_sound(player, "exchangeclone_destruct")
        end
        nodes = minetest.find_nodes_in_area(pos1, pos2, groups_to_search)
    else
        if action == "path" or action == "unpath" then
            nodes = {center}
        else
            return
        end
    end
	for _, pos in pairs(nodes) do
        local node = minetest.get_node(pos)
		if minetest.is_protected(pos, player:get_player_name()) then
			minetest.record_protection_violation(pos, player:get_player_name())
		else
            if action == "path" then
                if exchangeclone.mcla then
                    local on_shovel_place = minetest.registered_items[node.name]._on_shovel_place
                    if on_shovel_place then
                        on_shovel_place(itemstack, player, {type="node",under=pos,above=vector.offset(pos,0,1,0)})
                    end
                else -- in MCL2, it only searches for pathable nodes
                    if minetest.get_node(vector.offset(pos,0,1,0)).name == "air" then
                        minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pos}, true)
                        minetest.swap_node(pos, {name="mcl_core:grass_path"})
                    end
                end
            elseif action == "unpath" then
                minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pos}, true)
                minetest.swap_node(pos, {name="mcl_core:dirt"})
            else
                local drops = minetest.get_node_drops(minetest.get_node(pos).name, itemstack)
                exchangeclone.drop_items_on_player(pos, drops, player)
            end
		end
	end

	if action == "crumbly" or action == "crumbly_flat" then
        exchangeclone.remove_nodes(nodes)
    end
    if charge > 1 then
	    exchangeclone.start_cooldown(player, "shovel", charge/2)
    end
end


local function shovel_on_place(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
        return exchangeclone.charge_update(itemstack, player)
    end

    if pointed_thing.type == "node" then
        exchangeclone.shovel_action(itemstack, player, pointed_thing.under)
    end

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
		full_punch_interval = 1,
		max_drop_level=6,
		damage_groups = {fleshy=6},
		punch_attack_uses = 0,
		groupcaps={
			crumbly = {times=exchangeclone.get_mtg_times(14, nil, "crumbly"), uses=0, maxlevel=4},
		},
	},
	on_place = shovel_on_place,
	on_secondary_use = shovel_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 14, level = 5, uses = 0 }
	},
})

exchangeclone.set_charge_type("exchangeclone:dark_matter_shovel", "dark_matter")

minetest.register_tool("exchangeclone:red_matter_shovel", {
	description = "Red Matter Shovel",
	wield_image = "exchangeclone_red_matter_shovel.png",
	inventory_image = "exchangeclone_red_matter_shovel.png",
	groups = { tool=1, shovel=1, dig_speed_class=6, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 1,
		max_drop_level=7,
		damage_groups = {fleshy=7},
		punch_attack_uses = 0,
		groupcaps={
			crumbly = {times=exchangeclone.get_mtg_times(16, nil, "crumbly"), maxlevel=5},
		},
	},
	on_place = shovel_on_place,
	on_secondary_use = shovel_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 16, level = 6, uses = 0 }
	},
})

exchangeclone.set_charge_type("exchangeclone:red_matter_shovel", "red_matter")

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