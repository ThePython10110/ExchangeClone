local S = core.get_translator()

local function create_soil(itemstack, player, pointed_thing)
	local pos = pointed_thing.under
	local name = core.get_node(pos).name
	local above_name = core.get_node(vector.offset(pos,0,1,0)).name

	if core.is_protected(pointed_thing.under, player:get_player_name()) then
		core.record_protection_violation(pointed_thing.under, player:get_player_name())
		return itemstack
	end
	if core.get_item_group(name, "cultivatable") == 2 then
		if above_name == "air" then
			core.set_node(pos, {name="mcl_farming:soil"})
			core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
		end
	elseif core.get_item_group(name, "cultivatable") == 1 then
		if above_name == "air" then
			core.set_node(pos, {name="mcl_core:dirt"})
			core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
		end
	end
	return itemstack
end

local hoe_function

if exchangeclone.mcl then
	hoe_function = create_soil
else
	if farming then
		hoe_function = farming.hoe_on_use
	else
		hoe_function = function(...) end
	end
end

function exchangeclone.hoe_action(itemstack, player, center)
	if not (itemstack and player and center) then return end
	if exchangeclone.check_cooldown(player, "hoe") then return end
	local charge = math.max(itemstack:get_meta():get_int("exchangeclone_tool_charge"), 1)
	local nodes
	if charge > 1 then
		local vector1, vector2 = exchangeclone.process_range(player, "flat", charge)
		if not (vector1 and vector2) then return end
		local pos1, pos2 = vector.add(center, vector1), vector.add(center, vector2)
		nodes = core.find_nodes_in_area(pos1, pos2, {"group:exchangeclone_dirt"})
		exchangeclone.play_sound(player, "exchangeclone_charge_up")
	else
		nodes = {center}
	end

	for _, pos in pairs(nodes) do
		if core.is_protected(pos, player:get_player_name()) then
			core.record_protection_violation(pos, player:get_player_name())
		else
			local new_pointed_thing = {type = "node", under = pos, above = vector.offset(pos,0,1,0)}
			hoe_function(itemstack, player, new_pointed_thing, 0)
		end
	end

	if charge > 1 then
		exchangeclone.start_cooldown(player, "hoe", charge/4)
	end
end

local hoe_on_place = function(itemstack, player, pointed_thing)
	local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
	if click_test ~= false then
		return click_test
	end

	if player:get_player_control().aux1 then
		return exchangeclone.charge_update(itemstack, player)
	end

	if player:get_player_control().sneak then
		local meta = itemstack:get_meta()
		local current_mode = meta:get_string("exchangeclone_multidig_mode")
		if current_mode == "3x3" then
			meta:set_string("exchangeclone_multidig_mode", "1x1")
			core.chat_send_player(player:get_player_name(), S("Single node mode"))
		else
			meta:set_string("exchangeclone_multidig_mode", "3x3")
			core.chat_send_player(player:get_player_name(), S("3x3 mode"))
		end
		return itemstack
	end
	if pointed_thing.type == "node" then
		local node_name = core.get_node(pointed_thing.under).name
		local def = core.registered_nodes[node_name]
		if core.get_item_group(node_name, "cultivatable") > 0
		or (core.get_item_group(node_name, "soil") > 0 and
		(def.soil and def.soil.wet and def.soil.dry)) then
			exchangeclone.hoe_action(itemstack, player, pointed_thing.under)
		end
	end
end

if exchangeclone.mcl then
	mcl_autogroup.register_diggroup("exchangeclone_dirt")
end
for name, def in pairs(core.registered_nodes) do
	local is_dirt = core.get_item_group(name, "cultivatable") + core.get_item_group(name, "soil")
	if is_dirt > 0 then
		if not name:find("sand") then
			local item_groups = table.copy(def.groups)
			item_groups.exchangeclone_dirt = 1
			core.override_item(name, {groups = item_groups})
		end
	end
end

core.register_tool("ec_tools:dark_matter_hoe", {
	description = S("Dark Matter Hammer").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_dark_matter_hoe.png",
	inventory_image = "exchangeclone_dark_matter_hoe.png",
	wield_scale = exchangeclone.wield_scale,
	on_place = hoe_on_place,
	on_secondary_use = hoe_on_place,
	groups = { tool=1, hoe=1, enchantability=0, dark_matter_hoe = 1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1, },
		groupcaps={
			exchangeclone_dirt = {times=exchangeclone.get_mtg_times(14, nil, "crumbly"), uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 14, level = 5, uses = 0 },
		hoey = { speed = 14, level = 5, uses = 0 }
	},
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.register_multidig_tool("ec_tools:dark_matter_hoe", {"group:exchangeclone_dirt"})
exchangeclone.set_charge_type("ec_tools:dark_matter_hoe", "dark_matter")

core.register_tool("ec_tools:red_matter_hoe", {
	description = S("Red Matter Hammer").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_red_matter_hoe.png",
	inventory_image = "exchangeclone_red_matter_hoe.png",
	wield_scale = exchangeclone.wield_scale,
	on_place = hoe_on_place,
	on_secondary_use = hoe_on_place,
	groups = { tool=1, hoe=1, enchantability=0, red_matter_hoe = 1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1, },
		groupcaps={
			exchangeclone_dirt = {times=exchangeclone.get_mtg_times(16, nil, "crumbly"), uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 16, level = 6, uses = 0 },
		hoey = { speed = 16, level = 6, uses = 0 }
	},
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.register_multidig_tool("ec_tools:red_matter_hoe", {"group:exchangeclone_dirt"})
core.register_alias("ec_tools:red_matter_hoe_3x3", "ec_tools:red_matter_hoe")
exchangeclone.set_charge_type("ec_tools:red_matter_hoe", "red_matter")

core.register_craft({
    output = "ec_tools:dark_matter_hoe",
    recipe = {
        {"ec_matter:dark_matter", "ec_matter:dark_matter"},
        {"", exchangeclone.itemstrings.diamond},
        {"", exchangeclone.itemstrings.diamond}
    }
})

core.register_craft({
    output = "ec_tools:red_matter_hoe",
    recipe = {
        {"ec_matter:red_matter", "ec_matter:red_matter"},
        {"", "group:dark_matter_hoe"},
        {"", "ec_matter:dark_matter"}
    }
})

core.register_alias("exchangeclone:dark_matter_hoe", "ec_tools:dark_matter_hoe")
core.register_alias("exchangeclone:red_matter_hoe", "ec_tools:red_matter_hoe")
core.register_alias("exchangeclone:red_matter_hoe_3x3", "ec_tools:red_matter_hoe")