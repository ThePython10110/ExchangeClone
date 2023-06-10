local wield_scale
if exchangeclone.mineclone then
    local wield_scale = mcl_vars.tool_wield_scale
else
    local wield_scale = {x=1,y=1,z=1}
end

local shovel_on_place
local axe_on_place
if exchangeclone.mineclone then
	shovel_on_place = function(itemstack, placer, pointed_thing)
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
				minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = above}, true)
				minetest.swap_node(pointed_thing.under, {name="mcl_core:grass_path"})
			end
		end
		return itemstack
	end
	
	axe_on_place = function(itemstack, placer, pointed_thing)
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
		end
		return itemstack
	end
end

local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if minetest.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
			return true
		end
	elseif minetest.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
			return true
		end
	end
	return false
end

local hoe_on_place = function(itemstack, user, pointed_thing)
	if minetest.get_modpath("farming") and farming then
		return farming.hoe_on_use(itemstack, user, pointed_thing)
	elseif not mineclone then
		return
	end
	-- Call on_rightclick if the pointed node defines it
	local node = minetest.get_node(pointed_thing.under)
	if user and not user:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
		end
	end

	if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
		return itemstack
	end

	if create_soil(pointed_thing.under, user:get_inventory()) then
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
	on_place = shovel_on_place,
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
	on_place = axe_on_place,
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		axey = { speed = 16, level = 7, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:dark_matter_hoe", {
	description = "Dark Matter Hoe",
	wield_scale = wield_scale,
	on_place = hoe_on_place,
	groups = { tool=1, hoe=1, enchantability=0 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 7, },
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 12, level = 7, uses = 0 }
	},
})

--Crafting recipes

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

minetest.register_craft({
    output = "exchangeclone:axe_dark_matter",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", ""},
        {"exchangeclone:dark_matter", diamond_itemstring, ""},
        {"", diamond_itemstring, ""}
    }
})

minetest.register_craft({
    output = "exchangeclone:dark_matter_hoe",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", ""},
        {"", diamond_itemstring, ""},
        {"", diamond_itemstring, ""}
    }
})