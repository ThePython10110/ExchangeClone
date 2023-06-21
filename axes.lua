local axe_break_cube = function(player, center, distance, strip)
    exchangeclone.play_ability_sound(player)
    local player_pos = player:get_pos()
    local player_energy = exchangeclone.get_player_energy(player)
    local energy_cost = 0
    local pos = center
    pos.x = exchangeclone.round(pos.x)
    pos.y = math.floor(pos.y) --make sure y is node BELOW player's feet
    pos.z = exchangeclone.round(pos.z)

    for x = pos.x-distance, pos.x+distance do
        if energy_cost + 8 > player_energy then
            break
        end
    for y = pos.y-distance, pos.y+distance do
        if energy_cost + 8 > player_energy then
            break
        end
    for z = pos.z-distance, pos.z+distance do
        if energy_cost + 8 > player_energy then
            break
        end
        local new_pos = {x=x,y=y,z=z}
        local node = minetest.get_node(new_pos) or {name="air"}
        local node_def = minetest.registered_items[node.name]
        if (node_def.groups.tree or node_def.groups.leaves) then
            if minetest.is_protected(new_pos, player:get_player_name()) then
                minetest.record_protection_violation(new_pos, player:get_player_name())
            else
                energy_cost = energy_cost + 8
                if strip then
                    if node_def._mcl_stripped_variant ~= nil then
                        minetest.swap_node(new_pos, {name=node_def._mcl_stripped_variant, param2=node.param2})
                    end
                else
                    local drops = minetest.get_node_drops(node.name, "exchangeclone:red_matter_axe")
                    exchangeclone.drop_items_on_player(new_pos, drops, player)
                    minetest.set_node(new_pos, {name = "air"})
                end
            end
        end
    end
    end
    end
    exchangeclone.set_player_energy(player, player_energy - energy_cost)
end

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

    if pointed_thing.type == "node" then
        local node = minetest.get_node(pointed_thing.under)
        local node_def = minetest.registered_nodes[node.name]

        if range == 0 then
            if node_def._mcl_stripped_variant ~= nil then
                minetest.swap_node(pointed_thing.under, {name=node_def._mcl_stripped_variant, param2=node.param2})
                return itemstack
            end
        end
    end

    local center = player:get_pos()
    if pointed_thing.type == "node" then
        center = pointed_thing.under
    end
    if player:get_player_control().sneak and exchangeclone.mineclone then
        axe_break_cube(player, center, range, true) -- strip when holding shift
    else
        axe_break_cube(player, center, range)
    end
    return itemstack
end

minetest.register_tool("exchangeclone:dark_matter_axe", {
	description = "Dark Matter Axe",
	wield_image = "exchangeclone_dark_matter_axe.png",
	inventory_image = "exchangeclone_dark_matter_axe.png",
	groups = { tool=1, axe=1, dig_speed_class=7, enchantability=0 },
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
	groups = { tool=1, axe=1, dig_speed_class=8, enchantability=0 },
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
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", ""},
        {"exchangeclone:dark_matter", exchangeclone.diamond_itemstring, ""},
        {"", exchangeclone.diamond_itemstring, ""}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_axe",
    recipe = {
        {"exchangeclone:red_matter", "exchangeclone:red_matter", ""},
        {"exchangeclone:red_matter", "exchangeclone:dark_matter_axe", ""},
        {"", "exchangeclone:dark_matter", ""}
    }
})