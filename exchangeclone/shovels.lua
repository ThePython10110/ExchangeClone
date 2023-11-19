exchangeclone.shovel_action = {
    start_action = function(player, center, range, itemstack)
        if exchangeclone.check_cooldown(player, "shovel") then return end
        local data = {}
        if exchangeclone.mcl then
            data.path = not player:get_player_control().sneak
        end
        if range > 0 or not data.path then
            exchangeclone.play_ability_sound(player)
        end
        data.itemstack = itemstack
        return data
    end,
    action = function(player, pos, node, data)
        if ((minetest.get_item_group(node.name, "crumbly") > 0) or (minetest.get_item_group(node.name, "shovely") > 0)) then
            if minetest.is_protected(pos, player:get_player_name()) then
                minetest.record_protection_violation(pos, player:get_player_name())
            else
                if data.path then
                    -- TODO: Fix potential "shovel_on_place" functions that aren't paths in Mineclonia
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
                    minetest.set_node(pos, {name = "air"})
                end
            end
        end
        return data
    end,
    end_action = function(player, center, range, data)
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
            return exchangeclone.range_update(itemstack, player, 3)
        else
            return exchangeclone.range_update(itemstack, player, 4)
        end
    end

    local range = itemstack:get_meta():get_int("exchangeclone_item_range")

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
	groups = { tool=1, shovel=1, dig_speed_class=6, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
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
		shovely = { speed = 16, level = 7, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:red_matter_shovel", {
	description = "Red Matter Shovel",
	wield_image = "exchangeclone_red_matter_shovel.png",
	inventory_image = "exchangeclone_red_matter_shovel.png",
	groups = { tool=1, shovel=1, dig_speed_class=7, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
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
		shovely = { speed = 19, level = 8, uses = 0 }
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