local S = minetest.get_translator()

function exchangeclone.hammer_action(itemstack, player, center)
	if not (itemstack and player and center) then return end
	if exchangeclone.check_cooldown(player, "hammer") then return end
	local charge = itemstack:get_meta():get_int("exchangeclone_tool_charge") or 0
	local vector1, vector2 = exchangeclone.process_range(player, "hammer", charge)
	if not (vector1 and vector2) then return end

	local pos1, pos2 = vector.add(center, vector1), vector.add(center, vector2)
	exchangeclone.play_ability_sound(player)
	local nodes = minetest.find_nodes_in_area(pos1, pos2, {"group:"..exchangeclone.stone_group})
	for _, pos in pairs(nodes) do
		if minetest.is_protected(pos, player:get_player_name()) then
			minetest.record_protection_violation(pos, player:get_player_name())
		else
			local drops = minetest.get_node_drops(minetest.get_node(pos).name, itemstack:get_name())
			exchangeclone.drop_items_on_player(pos, drops, player)
		end
	end

	exchangeclone.remove_nodes(nodes)
	exchangeclone.start_cooldown(player, "hammer", charge/2)
end

local function hammer_on_place(itemstack, player, pointed_thing)
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
			minetest.chat_send_player(player:get_player_name(), S("Single node mode"))
		else
			meta:set_string("exchangeclone_multidig_mode", "3x3")
			minetest.chat_send_player(player:get_player_name(), S("3x3 mode"))
		end
		return itemstack
	end

    local range = itemstack:get_meta():get_int("exchangeclone_tool_charge")
    local center = player:get_pos()
    if pointed_thing.type == "node" then
        center = pointed_thing.under
    end
    exchangeclone.hammer_action(itemstack, player, center)
end

minetest.register_tool("exchangeclone:dark_matter_hammer", {
	description = S("Dark Matter Hammer").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_dark_matter_hammer.png",
	inventory_image = "exchangeclone_dark_matter_hammer.png",
	groups = { tool=1, hammer=1, dig_speed_class=5, enchantability=0, dark_matter_hammer = 1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 1,
		max_drop_level=6,
		damage_groups = {fleshy=14},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1.5, [2]=0.75, [3]=0.325}, uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 14, level = 5, uses = 0 }
	},
    on_place = hammer_on_place,
    on_secondary_use = hammer_on_place
})

exchangeclone.register_multidig_tool("exchangeclone:dark_matter_hammer", {"group:"..exchangeclone.stone_group})
minetest.register_alias("exchangeclone:dark_matter_hammer_3x3", "exchangeclone:dark_matter_hammer")
exchangeclone.set_charge_type("exchangeclone:dark_matter_hammer", "dark_matter")

minetest.register_tool("exchangeclone:red_matter_hammer", {
	description = S("Red Matter Hammer").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_red_matter_hammer.png",
	inventory_image = "exchangeclone_red_matter_hammer.png",
	groups = { tool=1, hammer=1, dig_speed_class=6, enchantability=0, red_matter_hammer = 1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 1,
		max_drop_level=7,
		damage_groups = {fleshy=15},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1, [2]=0.5, [3]=0.2}, uses=0, maxlevel=5},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 16, level = 6, uses = 0 }
	},
    on_place = hammer_on_place,
    on_secondary_use = hammer_on_place,
})

exchangeclone.register_multidig_tool("exchangeclone:red_matter_hammer", {"group:"..exchangeclone.stone_group})
minetest.register_alias("exchangeclone:red_matter_hammer_3x3", "exchangeclone:red_matter_hammer")
exchangeclone.set_charge_type("exchangeclone:red_matter_hammer", "red_matter")

minetest.register_craft({
    output = "exchangeclone:dark_matter_hammer",
    recipe = {
        {"exchangeclone:dark_matter", exchangeclone.itemstrings.diamond, "exchangeclone:dark_matter"},
        {"", exchangeclone.itemstrings.diamond, ""},
        {"", exchangeclone.itemstrings.diamond, ""}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_hammer",
    recipe = {
        {"exchangeclone:red_matter", "exchangeclone:dark_matter", "exchangeclone:red_matter"},
        {"", "group:dark_matter_hammer", ""},
        {"", "exchangeclone:dark_matter", ""}
    }
})