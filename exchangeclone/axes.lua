local S = minetest.get_translator()

exchangeclone.axe_action = {
    start_action = function(player, center, range, itemstack)
        if exchangeclone.check_cooldown(player, "axe") then return end
        local data = {}
        if exchangeclone.mcl then
            data.strip = not player:get_player_control().sneak
        end
        if range > 0 or not data.strip then
            exchangeclone.play_ability_sound(player)
        end
        data.itemstack = itemstack
        data.remove_positions = {}
        return data
    end,
    action = function(player, pos, node, data)
        local node_def = minetest.registered_items[node.name]
        if (node_def.groups.tree or node_def.groups.leaves) then
            if minetest.is_protected(pos, player:get_player_name()) then
                minetest.record_protection_violation(pos, player:get_player_name())
            else
                if data.strip then
                    if node_def._mcl_stripped_variant ~= nil then
                        minetest.swap_node(pos, {name=node_def._mcl_stripped_variant, param2=node.param2})
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
        if range > 0 or not data.strip then
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
    exchangeclone.node_radius_action(player, center, range, exchangeclone.axe_action, itemstack)
    return itemstack
end

minetest.register_tool("exchangeclone:dark_matter_axe", {
	description = S("Dark Matter Axe"),
	wield_image = "exchangeclone_dark_matter_axe.png",
	inventory_image = "exchangeclone_dark_matter_axe.png",
	groups = { tool=1, axe=1, dig_speed_class=5, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=6,
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
		axey = { speed = 16, level = 5, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:red_matter_axe", {
	description = S("Red Matter Axe"),
	wield_image = "exchangeclone_red_matter_axe.png",
	inventory_image = "exchangeclone_red_matter_axe.png",
	groups = { tool=1, axe=1, dig_speed_class=6, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.4,
		max_drop_level=7,
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
		axey = { speed = 20, level = 6, uses = 0 }
	},
})

minetest.register_craft({
    output = "exchangeclone:dark_matter_axe",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {"exchangeclone:dark_matter", exchangeclone.itemstrings.diamond},
        {"", exchangeclone.itemstrings.diamond}
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