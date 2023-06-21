local shovel_on_place
if exchangeclone.mineclone then
	shovel_on_place = function(itemstack, player, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if player and not player:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
			end
		end

		-- Only make grass path if tool used on side or top of target node
		if pointed_thing.above.y < pointed_thing.under.y then
			return itemstack
		end

		if (minetest.get_item_group(node.name, "path_creation_possible") == 1) then
			local above = table.copy(pointed_thing.under)
			above.y = above.y + 1
			if minetest.get_node(above).name == "air" then
				if minetest.is_protected(pointed_thing.under, player:get_player_name()) then
					minetest.record_protection_violation(pointed_thing.under, player:get_player_name())
					return itemstack
				end
				minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = above}, true)
				minetest.swap_node(pointed_thing.under, {name="mcl_core:grass_path"})
			end
		end
		return itemstack
	end
end

minetest.register_tool("exchangeclone:dark_matter_shovel", {
	description = "Dark Matter Shovel",
	wield_image = "exchangeclone_dark_matter_shovel.png",
	inventory_image = "exchangeclone_dark_matter_shovel.png",
	groups = { tool=1, shovel=1, dig_speed_class=7, enchantability=0 },
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 0,
		groupcaps={
			crumbly = {times={[1]=0.9, [2]=0.45, [3]=0.225}, uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = shovel_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 16, level = 7, uses = 0 }
	},
})

--Crafting recipes

minetest.register_craft({
    output = "exchangeclone:dark_matter_shovel",
    recipe = {
        {"", "exchangeclone:dark_matter", ""},
        {"", exchangeclone.diamond_itemstring, ""},
        {"", exchangeclone.diamond_itemstring, ""}
    }
})