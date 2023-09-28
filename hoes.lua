local function create_soil(itemstack, player, pointed_thing)
	if not pointed_thing.under then return end
	if not pointed_thing.under.x then return end
	local pos = pointed_thing.under
	local name = minetest.get_node(pos).name
	local above_name = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name

	if minetest.is_protected(pointed_thing.under, player:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.under, player:get_player_name())
		return itemstack
	end
	if minetest.get_item_group(name, "cultivatable") == 2 then
		if above_name == "air" then
			name = "mcl_farming:soil"
			minetest.set_node(pos, {name=name})
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
		end
	elseif minetest.get_item_group(name, "cultivatable") == 1 then
		if above_name == "air" then
			name = "mcl_core:dirt"
			minetest.set_node(pos, {name=name})
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
		end
	end
	return itemstack
end

local hoe_function

if exchangeclone.mcl then
	hoe_function = create_soil
else
	hoe_function = farming.hoe_on_use -- assuming farming exists
end

exchangeclone.hoe_action = {
	start_action = function(player, center, range, itemstack)
		if exchangeclone.check_cooldown(player, "hoe") then return end
		local data = {}
		if range > 0 then
			exchangeclone.play_ability_sound(player)
		end
		data.player_energy = exchangeclone.get_player_energy(player)
		data.energy_cost = 0
		data.itemstack = itemstack
		return data
	end,
	action = function(player, pos, node, data)
		local new_pointed_thing = {type = "node", under = pos, above = {x=pos.x,y=pos.y+1,z=pos.z}}
		data.energy_cost = data.energy_cost + 4
		hoe_function(data.itemstack, player, new_pointed_thing)
		return data
	end,
	end_action = function(player, center, range, data)
		if range > 0 then
			exchangeclone.set_player_energy(player, data.player_energy - data.energy_cost)
			exchangeclone.start_cooldown(player, "hoe", range/4)
		end
	end
}

local hoe_on_place = function(itemstack, player, pointed_thing)
	
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

	if player:get_player_control().sneak then
		local current_name = itemstack:get_name()
		if string.sub(current_name, -4, -1) == "_3x3" then
			itemstack:set_name(string.sub(current_name, 1, -5))
			minetest.chat_send_player(player:get_player_name(), "Single node mode")
		else
			itemstack:set_name(current_name.."_3x3")
			minetest.chat_send_player(player:get_player_name(), "3x3 mode")
		end
		return itemstack
	end

	local range = itemstack:get_meta():get_int("exchangeclone_item_range")
	local center = player:get_pos()
	if pointed_thing.type == "node" then
		center = pointed_thing.under
	end
	exchangeclone.node_radius_action(player, center, range, exchangeclone.hoe_action, itemstack)
end

if exchangeclone.mcl then
	mcl_autogroup.register_diggroup("exchangeclone_dirt")
end
for name, def in pairs(minetest.registered_nodes) do
	local is_dirt = minetest.get_item_group(name, "cultivatable") + minetest.get_item_group(name, "soil")
	if is_dirt > 0 then
		if not name:find("sand") then
			local item_groups = table.copy(def.groups)
			item_groups.exchangeclone_dirt = 1
			minetest.override_item(name, {groups = item_groups})
		end
	end
end

local hoe_def = {
	description = "Dark Matter Hoe",
	wield_image = "exchangeclone_dark_matter_hoe.png",
	inventory_image = "exchangeclone_dark_matter_hoe.png",
	wield_scale = exchangeclone.wield_scale,
	on_place = hoe_on_place,
	on_secondary_use = hoe_on_place,
	groups = { tool=1, hoe=1, enchantability=0, dark_matter_hoe = 1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 7, },
		groupcaps={
			exchangeclone_dirt = {times={[1]=0.25, [2]=0.25, [3]=0.25}, uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 12, level = 7, uses = 0 },
		hoey = { speed = 12, level = 7, uses = 0 }
	},
}

minetest.register_tool("exchangeclone:dark_matter_hoe", table.copy(hoe_def))

local hoe_3x3_def = table.copy(hoe_def)
hoe_3x3_def.groups.not_in_creative_inventory = 1
hoe_3x3_def.tool_capabilities.groupcaps.exchangeclone_dirt.times = {[1]=0.4, [2]=0.4, [3]=0.4}
hoe_3x3_def._mcl_diggroups.exchangeclone_dirt = { speed = 8, level = 7, uses = 0 }

minetest.register_tool("exchangeclone:dark_matter_hoe_3x3", table.copy(hoe_3x3_def))

hoe_def.description = "Red Matter Hoe"
hoe_def.wield_image = "exchangeclone_red_matter_hoe.png"
hoe_def.inventory_image = "exchangeclone_red_matter_hoe.png"
hoe_def.groups = { tool=1, hoe=1, enchantability=0, red_matter_hoe = 1 }
hoe_def.tool_capabilities = {
	full_punch_interval = 0.25,
	damage_groups = { fleshy = 8, },
	groupcaps={
		exchangeclone_dirt = {times={[1]=0.15, [2]=0.15, [3]=0.15}, uses=0, maxlevel=4},
	},
}
hoe_def._mcl_diggroups = {
	exchangeclone_dirt = { speed = 13, level = 8, uses = 0 },
	hoey = { speed = 13, level = 8, uses = 0 }
}

minetest.register_tool("exchangeclone:red_matter_hoe", table.copy(hoe_def))

hoe_3x3_def = table.copy(hoe_def)
hoe_3x3_def.groups.not_in_creative_inventory = 1
hoe_3x3_def.tool_capabilities.groupcaps.exchangeclone_dirt.times = {[1]=0.25, [2]=0.25, [3]=0.25}
hoe_3x3_def._mcl_diggroups.exchangeclone_dirt = { speed = 9, level = 8, uses = 0 }

minetest.register_tool("exchangeclone:red_matter_hoe_3x3", table.copy(hoe_3x3_def))

minetest.register_craft({
    output = "exchangeclone:dark_matter_hoe",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {"", exchangeclone.diamond_itemstring},
        {"", exchangeclone.diamond_itemstring}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_hoe",
    recipe = {
        {"exchangeclone:red_matter", "exchangeclone:red_matter"},
        {"", "group:dark_matter_hoe"},
        {"", "exchangeclone:dark_matter"}
    }
})