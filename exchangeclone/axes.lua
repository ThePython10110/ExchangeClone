local S = minetest.get_translator()

function exchangeclone.axe_action(itemstack, player, center)
    if exchangeclone.check_cooldown(player, "axe") then return end
    local strip
    local start_node = minetest.get_node(center)
	local charge = math.max(itemstack:get_meta():get_int("exchangeclone_tool_charge"), 1)
    local start_def = minetest.registered_items[start_node.name]
    local stripped_variant = start_def._mcl_stripped_variant
    if exchangeclone.mcl then
        if charge == 1 then
            strip = true
        else
            strip = not player:get_player_control().sneak
        end
        if strip and not stripped_variant then return end
    end
    minetest.log("strip = "..dump(strip))
    local nodes
    local groups_to_search = strip and {start_node.name} or {"group:tree", "group:leaves"}
    local range_type = strip and "basic_radius" or "large_radius"
    if charge > 1 then
        local vector1, vector2 = exchangeclone.process_range(player, range_type, charge)
        local pos1, pos2 = vector.add(center, vector1), vector.add(center, vector2)
        exchangeclone.play_sound(player, strip and "exchangeclone_charge_up" or "exchangeclone_destruct")
        nodes = minetest.find_nodes_in_area(pos1, pos2, groups_to_search)
    else
        nodes = {center}
    end
    for _, pos in pairs(nodes) do
        local node = minetest.get_node(pos)
        if minetest.is_protected(pos, player:get_player_name()) then
            minetest.record_protection_violation(pos, player:get_player_name())
        else
            if strip then
                if node.param2 == start_node.param2 then
                    local on_axe_place = minetest.registered_items[node.name]._on_axe_place
                    if on_axe_place then
                        on_axe_place(itemstack, player, {type="node",under=pos})
                    end
                    minetest.swap_node(pos, {name=stripped_variant, param2=node.param2})
                end
            else
                -- specify the tool so the katar doesn't shear all the leaves
                local drops = minetest.get_node_drops(node.name, "exchangeclone:red_matter_axe")
                exchangeclone.drop_items_on_player(pos, drops, player)
            end
        end
    end
    if not strip then
        exchangeclone.remove_nodes(nodes)
    end
    if charge > 1 or not strip then
        exchangeclone.start_cooldown(player, "axe", charge/3)
    end
end

local function axe_on_place(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
        return exchangeclone.charge_update(itemstack, player)
    end

    if pointed_thing.type == "node" then
        if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "tree") > 0 then
            exchangeclone.axe_action(itemstack, player, pointed_thing.under)
        end
    end

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
		full_punch_interval = 1,
		max_drop_level=6,
		damage_groups = {fleshy=9},
		punch_attack_uses = 0,
		groupcaps={
			choppy = {times = exchangeclone.get_mtg_times(14, nil, "choppy"), uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = axe_on_place,
	on_secondary_use = axe_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 14, level = 5, uses = 0 }
	},
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.set_charge_type("exchangeclone:dark_matter_axe", "dark_matter")

minetest.register_tool("exchangeclone:red_matter_axe", {
	description = S("Red Matter Axe"),
	wield_image = "exchangeclone_red_matter_axe.png",
	inventory_image = "exchangeclone_red_matter_axe.png",
	groups = { tool=1, axe=1, dig_speed_class=6, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 1,
		max_drop_level=7,
		damage_groups = {fleshy=10},
		punch_attack_uses = 0,
		groupcaps={
			choppy = {times = exchangeclone.get_mtg_times(16, nil, "choppy"), uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = axe_on_place,
	on_secondary_use = axe_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 16, level = 6, uses = 0 }
	},
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.set_charge_type("exchangeclone:red_matter_axe", "red_matter")

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