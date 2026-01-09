function exchangeclone.shovel_action(itemstack, player, center)
	if not (itemstack and player and center) then return end
	if exchangeclone.check_cooldown(player, "shovel") then return end
	local charge = math.max(itemstack:get_meta():get_int("exchangeclone_tool_charge"), 1)
    local start_node = core.get_node(center)
    local action
    if exchangeclone.mcl then
        if core.registered_items[start_node.name]._on_shovel_place
        or core.get_item_group(start_node.name, "path_creation_possible") == 1 then
            if core.get_node(vector.offset(center,0,1,0)).name == "air" then
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
        local vector1, vector2 = exchangeclone.process_range(player, range_type, charge) --[[@as vector.Vector]]
        local pos1, pos2 = vector.add(center, vector1), vector.add(center, vector2)
        if action == "path" or action == "unpath" then
            exchangeclone.play_sound(player, "exchangeclone_charge_up")
        else
            exchangeclone.play_sound(player, "exchangeclone_destruct")
        end
        nodes = core.find_nodes_in_area(pos1, pos2, groups_to_search)
    else
        if action == "path" or action == "unpath" then
            nodes = {center}
        else
            return
        end
    end
	for _, pos in pairs(nodes) do
        local node = core.get_node(pos)
		if core.is_protected(pos, player:get_player_name()) then
			core.record_protection_violation(pos, player:get_player_name())
		else
            if action == "path" then
                if exchangeclone.mcla then
                    local on_shovel_place = core.registered_items[node.name]._on_shovel_place
                    if on_shovel_place then
                        on_shovel_place(itemstack, player, {type="node",under=pos,above=vector.offset(pos,0,1,0)})
                    end
                else -- in MCL2, it only searches for pathable nodes
                    if core.get_node(vector.offset(pos,0,1,0)).name == "air" then
                        core.sound_play({name="default_grass_footstep", gain=1}, {pos = pos}, true)
                        core.swap_node(pos, {name="mcl_core:grass_path"})
                    end
                end
            elseif action == "unpath" then
                core.sound_play({name="default_grass_footstep", gain=1}, {pos = pos}, true)
                core.swap_node(pos, {name="mcl_core:dirt"})
            else
                local drops = core.get_node_drops(core.get_node(pos).name, itemstack)
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

core.register_tool("ec_tools:dark_matter_shovel", {
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
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.set_charge_type("ec_tools:dark_matter_shovel", "dark_matter")

core.register_tool("ec_tools:red_matter_shovel", {
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
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.set_charge_type("ec_tools:red_matter_shovel", "red_matter")

--Crafting recipes

core.register_craft({
    output = "ec_tools:dark_matter_shovel",
    recipe = {
        {"ec_matter:dark_matter"},
        {exchangeclone.itemstrings.diamond},
        {exchangeclone.itemstrings.diamond}
    }
})

core.register_craft({
    output = "ec_tools:red_matter_shovel",
    recipe = {
        {"ec_matter:red_matter"},
        {"ec_tools:dark_matter_shovel"},
        {"ec_matter:dark_matter"}
    }
})

core.register_alias("exchangeclone:dark_matter_shovel", "ec_tools:dark_matter_shovel")
core.register_alias("exchangeclone:red_matter_shovel", "ec_tools:red_matter_shovel")