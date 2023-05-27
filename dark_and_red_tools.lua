local wield_scale
if exchangeclone.mineclone then
    local wield_scale = mcl_vars.tool_wield_scale
else
    local wield_scale = {x=1,y=1,z=1}
end

local make_grass_path
local make_stripped_trunk
if exchangeclone.mineclone then
	make_grass_path = function(itemstack, placer, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
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
				if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
					minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
					return itemstack
				end

				if not minetest.is_creative_enabled(placer:get_player_name()) then
					-- Add wear (as if digging a shovely node)
					local toolname = itemstack:get_name()
					local wear = mcl_autogroup.get_wear(toolname, "shovely")
					if wear then
						itemstack:add_wear(wear)
					end
				end
				minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = above}, true)
				minetest.swap_node(pointed_thing.under, {name="mcl_core:grass_path"})
			end
		end
		return itemstack
	end
	
	make_stripped_trunk = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return end

		local node = minetest.get_node(pointed_thing.under)
		local node_name = minetest.get_node(pointed_thing.under).name

		local noddef = minetest.registered_nodes[node_name]

		if not noddef then
			minetest.log("warning", "Trying to right click with an axe the unregistered node: " .. tostring(node_name))
			return
		end

		if not placer:get_player_control().sneak and noddef.on_rightclick then
			return minetest.item_place(itemstack, placer, pointed_thing)
		end
		if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
			return itemstack
		end

		if noddef._mcl_stripped_variant == nil then
			return itemstack
		else
			minetest.swap_node(pointed_thing.under, {name=noddef._mcl_stripped_variant, param2=node.param2})
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				-- Add wear (as if digging a axey node)
				local toolname = itemstack:get_name()
				local wear = mcl_autogroup.get_wear(toolname, "axey")
				if wear then
					itemstack:add_wear(wear)
				end
			end
		end
		return itemstack
	end
end

local carve_pumpkin
if minetest.get_modpath("mcl_farming") then
	carve_pumpkin = function(itemstack, placer, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		-- Only carve pumpkin if used on side
		if pointed_thing.above.y ~= pointed_thing.under.y then
			return
		end
		if node.name == "mcl_farming:pumpkin" then
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				-- Add wear (as if digging a shearsy node)
				local toolname = itemstack:get_name()
				local wear = mcl_autogroup.get_wear(toolname, "shearsy")
				if wear then
					itemstack:add_wear(wear)
				end

			end
			minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pointed_thing.above}, true)
			local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
			local param2 = minetest.dir_to_facedir(dir)
			minetest.set_node(pointed_thing.under, {name="mcl_farming:pumpkin_face", param2 = param2})
			minetest.add_item(pointed_thing.above, "mcl_farming:pumpkin_seeds 4")
		end
		return itemstack
	end
end

minetest.register_tool("exchangeclone:pick_dark_matter", {
	description = "Dark Matter Pickaxe\nImage coming soon.",
	groups = { tool=1, pickaxe=1, dig_speed_class=7, enchantability=0 },
	wield_scale = wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1.5, [2]=0.75, [3]=0.325}, uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 16, level = 7, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:shovel_dark_matter", {
	description = "Dark Matter Shovel\nImage coming soon.",
	groups = { tool=1, shovel=1, dig_speed_class=7, enchantability=0 },
	wield_scale = wield_scale,
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
	on_place = make_grass_path,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shovely = { speed = 16, level = 7, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:axe_dark_matter", {
	description = "Dark Matter Axe\nImage coming soon.",
	groups = { tool=1, axe=1, dig_speed_class=7, enchantability=0 },
	wield_scale = wield_scale,
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
	on_place = make_stripped_trunk,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 16, level = 7, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:sword_dark_matter", {
	description = "Dark Matter Sword\nImage coming soon.",
	groups = { tool=1, sword=1, dig_speed_class=7, enchantability=0 },
	wield_scale = wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.25,
		max_drop_level=5,
		damage_groups = {fleshy=14},
		punch_attack_uses = 0,
		groupcaps={
			snappy = {times={[1]=0.95, [2]=0.45, [3]=0.15}, uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 16, level = 7, uses = 0 }
	},
})

local diamond_itemstring = "default:diamond"
if exchangeclone.mineclone then
    diamond_itemstring = "mcl_core:diamond"
end

minetest.register_craft({
    output = "exchangeclone:shovel_dark_matter",
    recipe = {
        {"", "exchangeclone:dark_matter", ""},
        {"", diamond_itemstring, ""},
        {"", diamond_itemstring, ""}
    }
})

minetest.register_craft({
    output = "exchangeclone:pick_dark_matter",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {"", diamond_itemstring, ""},
        {"", diamond_itemstring, ""}
    }
})