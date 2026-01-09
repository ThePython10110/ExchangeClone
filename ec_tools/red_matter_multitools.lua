local S = core.get_translator()

--------------------------------------RED KATAR--------------------------------------

local katar_on_use = function(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
		return exchangeclone.charge_update(itemstack, player)
    end

	if pointed_thing.type == "object" then
		local name = pointed_thing.ref:get_entity_name()
		if name == "mobs_mc:sheep" or name == "mobs_mc:mooshroom" then
			return -- Don't do AOE when pointed at sheep/mooshroom, shear instead.
		end
	end

	if pointed_thing.type == "node" then
		local node = core.get_node(pointed_thing.under)
		local on_shears_place = core.registered_items[node.name]._on_shears_place
		if on_shears_place then
			return on_shears_place(itemstack, player, pointed_thing)
		end
		if node.name == "mcl_farming:pumpkin" and (pointed_thing.above.y ~= pointed_thing.under.y) then
			core.sound_play({name="default_grass_footstep", gain=1}, {pos = pointed_thing.above}, true)
			local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
			local param2 = core.dir_to_facedir(dir)
			core.set_node(pointed_thing.under, {name="mcl_farming:pumpkin_face", param2 = param2})
			core.add_item(pointed_thing.above, "mcl_farming:pumpkin_seeds 4")
		elseif core.get_item_group(node.name, "exchangeclone_dirt") > 0 then
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
			else
				exchangeclone.hoe_action(itemstack, player, pointed_thing.under)
			end
		elseif (core.get_item_group(node.name, "tree") > 0)
		or (core.get_item_group(node.name, "bamboo_block") > 0) then
			exchangeclone.axe_action(itemstack, player, pointed_thing.under)
		elseif exchangeclone.mcl2 and core.registered_items[node.name]._mcl_stripped_variant then
			exchangeclone.axe_action(itemstack, player, pointed_thing.under, true)
		elseif exchangeclone.mcla and core.registered_items[node.name]._on_axe_place then
			exchangeclone.axe_action(itemstack, player, pointed_thing.under, true)
		elseif exchangeclone.mcl
		and (core.get_item_group(node.name, "shearsy") > 0
		or core.get_item_group(node.name, "shearsy_cobweb") > 0) then
			exchangeclone.shear_action(itemstack, player, pointed_thing.under)
		end
	else
		local damage_all = itemstack:get_meta():get_int("exchangeclone_damage_all")
		if damage_all ~= 0 then damage_all = 1 end
		if player:get_player_control().sneak then
			if damage_all == 0 then
				damage_all = 1
				core.chat_send_player(player:get_player_name(), "Damage all mobs")
			else
				damage_all = 0
				core.chat_send_player(player:get_player_name(), "Damage hostile mobs")
			end
			itemstack:get_meta():set_int("exchangeclone_damage_all", damage_all)
			return itemstack
		end

		local aoe_function = exchangeclone.aoe_attack({damage = 1000, knockback = 20, radius = 10, damage_all = damage_all, cooldown = 0.625})
---@diagnostic disable-next-line: need-check-nil
		aoe_function(itemstack, player, pointed_thing)
	end
end

core.register_tool("ec_tools:red_katar", {
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
			exchangeclone_dirt = {times=exchangeclone.get_mtg_times(64, nil, "crumbly"), uses=0, maxlevel=4},
            snappy = {times=exchangeclone.get_mtg_times(64, nil, "snappy"), uses=0, maxlevel=5},
			choppy = {times=exchangeclone.get_mtg_times(64, nil, "choppy"), uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 64, level = 7, uses = 0 },
        shearsy = { speed = 64, level = 3, uses = 0 },
        shearsy_wool = { speed = 64, level = 7, uses = 0 },
        shearsy_cobweb = { speed = 64, level = 7, uses = 0 },
		hoey = { speed = 64, level = 7, uses = 0 },
		swordy = { speed = 64, level = 7, uses = 0 },
		axey = { speed = 64, level = 7, uses = 0 }
	},
})

exchangeclone.register_multidig_tool("ec_tools:red_katar", {"group:exchangeclone_dirt"})
exchangeclone.set_charge_type("ec_tools:red_katar", "red_multi")

core.register_craft({
	output = "ec_tools:red_katar",
	type = "shapeless",
	recipe = {
		"ec_tools:red_matter_sword",
		"ec_tools:red_matter_axe",
		"group:red_matter_hoe",
		exchangeclone.mcl and "ec_tools:red_matter_shears" or "ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter"
	}
})

--------------------------------------RED MORNINGSTAR--------------------------------------

--	If pointed_thing has on_rightclick
--		Run on_rightclick function
--	Elseif player holding aux1
-- 		Range update
-- 	Elseif pointed at node:
--		If node is an ore:
--			Vein mine
--		Elseif node is dirt and MCL:
--			Shovel action (since paths exist, there has to be a way to do it without sneaking)
--		Elseif node is shovely and player is sneaking
--			Shovel action
--		Elseif node is pickaxey:
--			Hammer action
--	Elseif player is sneaking
--		Update the mode

local function morningstar_on_use(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
		return exchangeclone.charge_update(itemstack, player)
    end

	local sneaking = player:get_player_control().sneak
	if pointed_thing.type == "node" then
		local name = core.get_node(pointed_thing.under).name
		if core.get_item_group(name, "exchangeclone_ore") > 0 then
			if exchangeclone.check_cooldown(player, "pickaxe") then return itemstack end
			exchangeclone.play_sound(player, "exchangeclone_destruct")
			exchangeclone.multidig_data[player:get_player_name()] = true
			exchangeclone.mine_vein(player, pointed_thing.under)
			exchangeclone.multidig_data[player:get_player_name()] = nil
			exchangeclone.start_cooldown(player, "pickaxe", 0.5)
			return
		-- I don't remember why I'm doing the dirt group separetely... but there must be a reason.
		elseif core.get_item_group(name, "exchangeclone_dirt") > 0 and exchangeclone.mcl then
			exchangeclone.shovel_action(itemstack, player, pointed_thing.under)
		elseif core.get_item_group(name, exchangeclone.shovel_group) > 0 then
			exchangeclone.shovel_action(itemstack, player, pointed_thing.under)
		elseif exchangeclone.mcla and core.registered_items[name]._on_shovel_place then
			exchangeclone.shovel_action(itemstack, player, pointed_thing)
		elseif core.get_item_group(name, exchangeclone.pickaxe_group) > 0 and sneaking then
			exchangeclone.hammer_action(itemstack, player, pointed_thing.under)
		else
            local result = exchangeclone.place_torch(player, pointed_thing)
            if result then
                player:_add_emc(result)
                -- If the torch could not be placed, it still costs EMC... not sure how to fix that
            end
			return
		end
	elseif sneaking then
		local meta = itemstack:get_meta()
		local current_mode = itemstack:get_meta():get_string("exchangeclone_multidig_mode")
		if current_mode == "" or not current_mode then current_mode = "1x1" end
		if current_mode == "1x1" then
			meta:set_string("exchangeclone_multidig_mode", "3x3")
			core.chat_send_player(player:get_player_name(), S("3x3 mode"))
		elseif current_mode == "3x3" then
			meta:set_string("exchangeclone_multidig_mode", "3x1_tall")
			core.chat_send_player(player:get_player_name(), S("3x1 tall mode"))
		elseif current_mode == "3x1_tall" then
			meta:set_string("exchangeclone_multidig_mode", "3x1_wide")
			core.chat_send_player(player:get_player_name(), S("3x1 wide mode"))
		elseif current_mode == "3x1_wide" then
			meta:set_string("exchangeclone_multidig_mode", "3x1_long")
			core.chat_send_player(player:get_player_name(), S("3x1 long mode"))
		elseif current_mode == "3x1_long" then
			meta:set_string("exchangeclone_multidig_mode", "1x1")
			core.chat_send_player(player:get_player_name(), S("Single node mode"))
		end
		return itemstack
	end
end

core.register_tool("ec_tools:red_morningstar", {
	 description = S("Red Morningstar").."\n"..S("Single node mode"),
	 wield_image = "exchangeclone_red_morningstar.png",
	 inventory_image = "exchangeclone_red_morningstar.png",
	 on_secondary_use = morningstar_on_use,
	 on_place = morningstar_on_use,
	 groups = { tool=1, red_morningstar = 1, shovel = 1, hammer=1, pickaxe = 1, dig_speed_class=7, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	 wield_scale = exchangeclone.wield_scale,
	 tool_capabilities = {
		 full_punch_interval = 0.3,
		 max_drop_level=8,
		 damage_groups = {fleshy=25},
		 punch_attack_uses = 0,
		 groupcaps={
			 cracky = {times=exchangeclone.get_mtg_times(64, nil, "cracky"), uses=0, maxlevel=5},
			 crumbly = {times=exchangeclone.get_mtg_times(64, nil, "crumbly"), uses=0, maxlevel=5},
			 choppy = {times=exchangeclone.get_mtg_times(64, nil, "choppy"), uses=0, maxlevel=5},
		 },
	 },
	 sound = { breaks = "default_tool_breaks" },
	 _mcl_toollike_wield = true,
	 _mcl_diggroups = {
		pickaxey = {speed = 64, level = 7, uses = 0},
		shovely = {speed = 64, level = 7, uses = 0},
		axey = { speed = 64, level = 7, uses = 0 },
	 },
})

exchangeclone.register_multidig_tool("ec_tools:red_morningstar", {"group:"..exchangeclone.pickaxe_group, "group:"..exchangeclone.shovel_group})
exchangeclone.set_charge_type("ec_tools:red_morningstar", "red_multi")

core.register_craft({
	output = "ec_tools:red_morningstar",
	type = "shapeless",
	recipe = {
		"group:red_matter_hammer",
		"ec_tools:red_matter_shovel",
		"group:red_matter_pickaxe",
		"ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter",
		"ec_matter:red_matter"
	}
})

core.register_alias("exchangeclone:red_katar", "ec_tools:red_katar")
core.register_alias("exchangeclone:red_katar_3x3", "ec_tools:red_katar_3x3")
core.register_alias("exchangeclone:red_morningstar", "ec_tools:red_morningstar")
core.register_alias("exchangeclone:red_morningstar_3x1", "ec_tools:red_morningstar_3x1")
core.register_alias("exchangeclone:red_morningstar_3x3", "ec_tools:red_morningstar_3x3")