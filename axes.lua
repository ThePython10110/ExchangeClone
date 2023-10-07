exchangeclone.axe_action = {
    start_action = function(player, center, range)
        if exchangeclone.check_cooldown(player, "axe") then return end
        local data = {}
        data.player_energy = exchangeclone.get_player_energy(player)
        data.energy_cost = 0
        if exchangeclone.mcl then
            data.strip = not player:get_player_control().sneak
        end
        if range > 0 or not data.strip then
            exchangeclone.play_ability_sound(player)
        end
        return data
    end,
    action = function(player, pos, node, data)
        if data.energy_cost + 8 > data.player_energy then return end
        local node_def = minetest.registered_items[node.name]
        if (node_def.groups.tree or node_def.groups.leaves) then
            if minetest.is_protected(pos, player:get_player_name()) then
                minetest.record_protection_violation(pos, player:get_player_name())
            else
                if data.strip then
                    if node_def._mcl_stripped_variant ~= nil then
                        data.energy_cost = data.energy_cost + 4
                        minetest.swap_node(pos, {name=node_def._mcl_stripped_variant, param2=node.param2})
                    end
                else
                    data.energy_cost = data.energy_cost + 8
                    local drops = minetest.get_node_drops(node.name, "exchangeclone:red_matter_axe")
                    exchangeclone.drop_items_on_player(pos, drops, player)
                    minetest.set_node(pos, {name = "air"})
                end
            end
        end
        return data
    end,
    end_action = function(player, center, range, data)
        if range > 0 or not data.strip then
            exchangeclone.set_player_energy(player, data.player_energy - data.energy_cost)
            exchangeclone.start_cooldown(player, "axe", range/6)
        end
    end
}

local function axe_on_place(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
        if itemstack:get_name():find("dark") then
            return exchangeclone.range_update(itemstack, player, 3)
        else
            return exchangeclone.range_update(itemstack, player, 4)
        end
    end

    local range = itemstack:get_meta():get_int("exchangeclone_item_range")

    local center = player:get_pos()
    if pointed_thing.type == "node" then center = pointed_thing.under end
    exchangeclone.node_radius_action(player, center, range, exchangeclone.axe_action)
    return itemstack
end

minetest.register_tool("exchangeclone:dark_matter_axe", {
	description = "Dark Matter Axe",
	wield_image = "exchangeclone_dark_matter_axe.png",
	inventory_image = "exchangeclone_dark_matter_axe.png",
	groups = { tool=1, axe=1, dig_speed_class=7, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=5,
		damage_groups = {fleshy=16},
		punch_attack_uses = 0,
		groupcaps={
			choppy = {times={[1]=1.5, [2]=0.75, [3]=0.38}, uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = axe_on_place,
	on_secondary_use = axe_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 16, level = 7, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:red_matter_axe", {
	description = "Red Matter Axe",
	wield_image = "exchangeclone_red_matter_axe.png",
	inventory_image = "exchangeclone_red_matter_axe.png",
	groups = { tool=1, axe=1, dig_speed_class=8, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.4,
		max_drop_level=5,
		damage_groups = {fleshy=19},
		punch_attack_uses = 0,
		groupcaps={
			choppy = {times={[1]=1, [2]=0.5, [3]=0.25}, uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = axe_on_place,
	on_secondary_use = axe_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 20, level = 8, uses = 0 }
	},
})

minetest.register_craft({
    output = "exchangeclone:dark_matter_axe",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {"exchangeclone:dark_matter", exchangeclone.diamond_itemstring},
        {"", exchangeclone.diamond_itemstring}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_axe",
    recipe = {
        {"exchangeclone:red_matter", "exchangeclone:red_matter"},
        {"exchangeclone:red_matter", "exchangeclone:dark_matter_axe"},
        {"", "exchangeclone:dark_matter"}
    }
})