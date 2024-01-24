local S = minetest.get_translator()

--------------------------------------RED KATAR--------------------------------------

local katar_on_use = function(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
		return exchangeclone.charge_update(itemstack, player, 5)
    end

	if pointed_thing.type == "object" then
		local name = pointed_thing.ref:get_entity_name()
		if name == "mobs_mc:sheep" or name == "mobs_mc:mooshroom" then
			return -- Don't do AOE when pointed at sheep/mooshroom, shear instead.
		end
	end
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		local range = itemstack:get_meta():get_int("exchangeclone_tool_charge")
		local center = player:get_pos()
		if pointed_thing.type == "node" then
			center = pointed_thing.under
		end
		if minetest.get_item_group(node.name, "exchangeclone_dirt") > 0 then
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
			else
				exchangeclone.node_radius_action(player, center, range, exchangeclone.hoe_action, itemstack)
			end
		elseif minetest.get_item_group(node.name, "tree") > 0 then
			exchangeclone.node_radius_action(player, center, range, exchangeclone.axe_action, itemstack)
		elseif minetest.get_item_group(node.name, "shearsy") > 0 or minetest.get_item_group(node.name, "shearsy_cobweb") > 0 then
			exchangeclone.node_radius_action(player, center, range, exchangeclone.shear_action, itemstack)
		end
	else
		local damage_all = itemstack:get_meta():get_int("exchangeclone_damage_all")
		if damage_all ~= 0 then damage_all = 1 end
		if player:get_player_control().sneak then
			if damage_all == 0 then
				damage_all = 1
				minetest.chat_send_player(player:get_player_name(), "Damage all mobs")
			else
				damage_all = 0
				minetest.chat_send_player(player:get_player_name(), "Damage hostile mobs")
			end
			itemstack:get_meta():set_int("exchangeclone_damage_all", damage_all)
			return itemstack
		end

		local aoe_function = exchangeclone.aoe_attack({damage = 1000, knockback = 20, radius = 10, damage_all = damage_all, cooldown = 0.7})
		aoe_function(itemstack, player, pointed_thing)
	end
end

local katar_def = {
    description = S("Red Katar").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_red_katar.png",
	inventory_image = "exchangeclone_red_katar.png",
    on_secondary_use = katar_on_use,
    on_place = katar_on_use,
	groups = { tool=1, red_katar = 1, sword = 1, axe=1, hoe = 1, shears = 1, dig_speed_class=7, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		full_punch_interval = 0.3,
		max_drop_level=8,
		damage_groups = {fleshy=28},
		punch_attack_uses = 0,
		groupcaps={
			exchangeclone_dirt = {times={[1]=0.15, [2]=0.15, [3]=0.15}, uses=0, maxlevel=4},
            snappy = {times={[1]=0.5, [2]=0.3, [3]=0.15}, uses=0, maxlevel=5},
			choppy = {times={[1]=0.5, [2]=0.3, [3]=0.15}, uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 10, level = 8, uses = 0 },
        shearsy = { speed = 10, level = 3, uses = 0 },
        shearsy_wool = { speed = 16, level = 3, uses = 0 },
        shearsy_cobweb = { speed = 36, level = 3, uses = 0 },
		hoey = { speed = 9, level = 8, uses = 0 },
		swordy = { speed = 20, level = 8, uses = 0 },
		axey = { speed = 20, level = 8, uses = 0 }
	},
}

minetest.register_tool("exchangeclone:red_katar", table.copy(katar_def))

katar_def.description = S("Red Katar").."\n"..S("3x3 mode")
katar_def.groups.not_in_creative_inventory = 1
katar_def._mcl_diggroups.exchangeclone_dirt = {speed = 8, level = 8, uses = 0}
katar_def.tool_capabilities.groupcaps.exchangeclone_dirt = {times={[1]=0.25,[2]=0.25,[3]=0.25}}

minetest.register_tool("exchangeclone:red_katar_3x3", table.copy(katar_def))

exchangeclone.register_alias("exchangeclone:red_katar", "exchangeclone:red_katar_3x3")

minetest.register_craft({
	output = "exchangeclone:red_katar",
	type = "shapeless",
	recipe = {
		"exchangeclone:red_matter_sword",
		"exchangeclone:red_matter_axe",
		"group:red_matter_hoe",
		(exchangeclone.mcl and "exchangeclone:red_matter_shears") or "exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter"
	}
})

--------------------------------------RED MORNINGSTAR--------------------------------------
exchangeclone.morningstar_action = {
    start_action = function(player, center, range, itemstack)
        if exchangeclone.check_cooldown(player, "shovel") then return end
        if exchangeclone.check_cooldown(player, "hammer") then return end
        local data = {}
		data.itemstack = itemstack
		exchangeclone.play_ability_sound(player)
        data.remove_positions = {}
        return data
    end,
    action = function(player, pos, node, data)
        if ((minetest.get_item_group(node.name, "crumbly") > 0) or (minetest.get_item_group(node.name, "shovely") > 0))
		or ((minetest.get_item_group(node.name, "cracky") > 0) or (minetest.get_item_group(node.name, "pickaxey") > 0)) then
            if minetest.is_protected(pos, player:get_player_name()) then
                minetest.record_protection_violation(pos, player:get_player_name())
            else
				local drops = minetest.get_node_drops(node.name, data.itemstack)
				exchangeclone.drop_items_on_player(pos, drops, player)
				table.insert(data.remove_positions, pos)
            end
        end
        return data
    end,
    end_action = function(player, center, range, data)
        exchangeclone.remove_nodes(data.remove_positions)
		exchangeclone.start_cooldown(player, "shovel", range/4) -- Longish cooldown
		exchangeclone.start_cooldown(player, "hammer", range/2)
    end
}

local torch_itemstring = "default:torch"
if exchangeclone.mcl then
    torch_itemstring = "mcl_torches:torch"
end

local torch_on_place = minetest.registered_items[torch_itemstring].on_place

local function morningstar_on_use(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
		return exchangeclone.charge_update(itemstack, player, 5)
    end

	local range = itemstack:get_meta():get_int("exchangeclone_tool_charge")
	local center = player:get_pos()

	if pointed_thing.type == "node" then
		center = pointed_thing.under
		if player:get_player_control().sneak then
			exchangeclone.node_radius_action(player, center, range, exchangeclone.morningstar_action, itemstack)
			return
		elseif (minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "exchangeclone_ore") > 0) then
			if exchangeclone.check_cooldown(player, "pickaxe") then return itemstack end
			exchangeclone.play_ability_sound(player)
			exchangeclone.multidig[player:get_player_name()] = true
			exchangeclone.mine_vein(player, pointed_thing.under)
			exchangeclone.multidig[player:get_player_name()] = nil
			exchangeclone.start_cooldown(player, "pickaxe", 0.3)
			return
		else
			local player_energy = exchangeclone.get_player_energy(player)
			torch_on_place(ItemStack(torch_itemstring), player, pointed_thing)
			exchangeclone.set_player_energy(player, player_energy - math.max(exchangeclone.get_item_energy(torch_itemstring) or 0, 8))
			-- If the torch could not be placed, it still costs energy... not sure how to fix that
			exchangeclone.start_cooldown(player, "pickaxe", 0.3)
			return
		end
	elseif player:get_player_control().sneak then
		local current_name = itemstack:get_name()
		local meta = itemstack:get_meta()
		local current_mode = itemstack:get_meta():get_string("exchangeclone_pick_mode")
		if current_mode == "" or not current_mode then current_mode = "1x1" end
		if current_mode == "1x1" then
			itemstack:set_name(current_name.."_3x3") -- set to 3x3 pick
			meta:set_string("exchangeclone_pick_mode", "3x3")
			minetest.chat_send_player(player:get_player_name(), S("3x3 mode"))
		elseif current_mode == "3x3" then
			itemstack:set_name(string.sub(current_name, 1, -5).."_3x1") -- set to 3x1 pick
			meta:set_string("exchangeclone_pick_mode", "tall")
			minetest.chat_send_player(player:get_player_name(), S("3x1 tall mode"))
		elseif current_mode == "tall" then
			meta:set_string("exchangeclone_pick_mode", "wide")
			minetest.chat_send_player(player:get_player_name(), S("3x1 wide mode"))
		elseif current_mode == "wide" then
			meta:set_string("exchangeclone_pick_mode", "long")
			minetest.chat_send_player(player:get_player_name(), S("3x1 long mode"))
		elseif current_mode == "long" then
			itemstack:set_name(string.sub(current_name, 1, -5)) -- set to 1x1 pick
			meta:set_string("exchangeclone_pick_mode", "1x1")
			minetest.chat_send_player(player:get_player_name(), S("Single node mode"))
		end
		return itemstack
	else
		exchangeclone.node_radius_action(player, center, range, exchangeclone.morningstar_action, itemstack)
	end
end

local morningstar_def = {
	 description = S("Red Morningstar").."\n"..S("Single node mode"),
	 wield_image = "exchangeclone_red_morningstar.png",
	 inventory_image = "exchangeclone_red_morningstar.png",
	 on_secondary_use = morningstar_on_use,
	 exchangeclone_pick_mode = "1x1",
	 on_place = morningstar_on_use,
	 groups = { tool=1, red_morningstar = 1, shovel = 1, hammer=1, pickaxe = 1, dig_speed_class=7, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	 wield_scale = exchangeclone.wield_scale,
	 tool_capabilities = {
		 full_punch_interval = 0.3,
		 max_drop_level=8,
		 damage_groups = {fleshy=25},
		 punch_attack_uses = 0,
		 groupcaps={
			 cracky = {times={[1]=0.2, [2]=0.1, [3]=0.05}, uses=0, maxlevel=5},
			 crumbly = {times={[1]=0.2, [2]=0.1, [3]=0.05}, uses=0, maxlevel=5},
			 choppy = {times={[1]=0.2, [2]=0.1, [3]=0.05}, uses=0, maxlevel=5},
		 },
	 },
	 sound = { breaks = "default_tool_breaks" },
	 _mcl_toollike_wield = true,
	 _mcl_diggroups = {
		pickaxey = {speed = 80, level = 7, uses = 0},
		shovely = {speed = 22, level = 7, uses = 0},
		axey = { speed = 22, level = 7, uses = 0 }
	 },
}

minetest.register_tool("exchangeclone:red_morningstar", table.copy(morningstar_def))

for k, v in pairs({cracky = "pickaxey", crumbly = "shovely"}) do
	morningstar_def.tool_capabilities.groupcaps[k].times = {[1]=0.7,[2]=0.5,[3]=0.25}
	morningstar_def._mcl_diggroups[v].speed = 70
end
morningstar_def.description = S("Red Morningstar").."\n"..S("3x3 mode")
morningstar_def.groups.not_in_creative_inventory = 1
morningstar_def.exchangeclone_pick_mode = "3x3"

minetest.register_tool("exchangeclone:red_morningstar_3x3", table.copy(morningstar_def))

exchangeclone.register_alias("exchangeclone:red_morningstar", "exchangeclone:red_morningstar_3x3")

for k, v in pairs({cracky = "pickaxey", crumbly = "shovely"}) do
	morningstar_def.tool_capabilities.groupcaps[k].times = {[1]=0.6,[2]=0.4,[3]=0.20}
	morningstar_def._mcl_diggroups[v].speed = 80
end
morningstar_def.exchangeclone_pick_mode = "tall"

morningstar_def.description = S("Red Morningstar").."\n"..S("3x1 mode")

minetest.register_tool("exchangeclone:red_morningstar_3x1", table.copy(morningstar_def))

exchangeclone.register_alias("exchangeclone:red_morningstar", "exchangeclone:red_morningstar_3x1")

minetest.register_craft({
	output = "exchangeclone:red_morningstar",
	type = "shapeless",
	recipe = {
		"group:red_matter_hammer",
		"exchangeclone:red_matter_shovel",
		"group:red_matter_pickaxe",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter",
		"exchangeclone:red_matter"
	}
})