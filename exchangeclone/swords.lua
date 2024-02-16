local aoe_exclude = { --any entity not including "mobs" is automatically added to this list.
	["mobs_mc:spider_eyes"] = true,
	["mobs_mc:wither_skull"] = true,
	["mobs_mc:fireball"] = true,
	["mobs_mc:dragon_fireball"] = true,
	["mobs_mc:blaze_fireball"] = true,
	["mobs_mc:shulkerbullet"] = true,
	["mobs_mc:potion_arrow"] = true,
	["mobs_mc:llamaspit"] = true,
}

local hostile_mobs = { --for Red Matter Sword/Katar
	["mobs_mc:baby_hoglin"] = true,
	["mobs_mc:baby_husk"] = true,
	["mobs_mc:baby_zombie"] = true,
	["mobs_mc:blaze"] = true,
	["mobs_mc:cave_spider"] = true,
	["mobs_mc:creeper"] = true,
	["mobs_mc:creeper_charged"] = true,
	["mobs_mc:enderdragon"] = true,
	["mobs_mc:enderman"] = true,
	["mobs_mc:endermite"] = true,
	["mobs_mc:evoker"] = true,
	["mobs_mc:ghast"] = true,
	["mobs_mc:guardian"] = true,
	["mobs_mc:guardian_elder"] = true,
	["mobs_mc:hoglin"] = true,
	["mobs_mc:husk"] = true,
	["mobs_mc:illusioner"] = true,
	["mobs_mc:killer_bunny"] = true,
	["mobs_mc:magma_cube_big"] = true,
	["mobs_mc:magma_cube_small"] = true,
	["mobs_mc:magma_cube_tiny"] = true,
	["mobs_mc:piglin"] = true,
	["mobs_mc:piglin_brute"] = true,
	["mobs_mc:pillager"] = true,
	["mobs_mc:shulker"] = true,
	["mobs_mc:skeleton"] = true,
	["mobs_mc:silverfish"] = true,
	["mobs_mc:slime_big"] = true,
	["mobs_mc:slime_tiny"] = true,
	["mobs_mc:spider"] = true,
	["mobs_mc:stray"] = true,
	["mobs_mc:vex"] = true,
	["mobs_mc:villager_zombie"] = true,
	["mobs_mc:vindicator"] = true,
	["mobs_mc:witch"] = true,
	["mobs_mc:wither"] = true,
	["mobs_mc:witherskeleton"] = true,
	["mobs_mc:zombified_piglin"] = true,
	["mobs_mc:zoglin"] = true,
	["mobs_mc:zombie"] = true,
}

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_entities) do
		if not name:find("mobs") then
			aoe_exclude[name] = true
		end
	end
end)

function exchangeclone.aoe_attack(info)
	if not info then return end
	local damage = info.damage or 12 -- 12 = DM sword AOE
	local knockback = info.knockback
	local radius = info.radius
	local damage_all = info.damage_all --damage all mobs/players or just hostile ones
	local cooldown = info.cooldown or 0.7
	if not (damage and radius and knockback) then return end
	if damage_all == nil then damage_all = 1 end

	return function(itemstack, player, pointed_thing) --modified from MineClone's TNT; I would simply use the explosion function but it would hurt the player.
		-- Use pointed node's on_rightclick function first, if present
		local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
        if click_test ~= false then
            return click_test
        end

		if exchangeclone.check_cooldown(player, "sword") then return end

		exchangeclone.play_sound(player, "exchangeclone_charge_up")

		local pos = player:get_pos()

		-- Entities in radius of explosion
		local objs = minetest.get_objects_inside_radius(pos, radius)

		-- Trace rays for entity damage
		for _, obj in pairs(objs) do
			local ent = obj:get_luaentity()

			-- Ignore items to lower lag
			if (obj:is_player()
			or (ent and not aoe_exclude[ent.name]
			and not (damage_all == 0 and not hostile_mobs[ent.name]))) --ignore hostile mobs if necessary
			and obj:get_hp() > 0 and obj ~= player then

				local opos = obj:get_pos()
				local distance = math.max(1, vector.distance(pos, opos))

				-- Punch entity with damage depending on explosion exposure and
				-- distance to explosion
				local punch_vec = vector.subtract(opos, pos)
				local punch_dir = vector.normalize(punch_vec)
				punch_dir = {x=punch_dir.x, y=punch_dir.y+0.3, z=punch_dir.z} -- knockback should be more upward

				local sleep_formspec_doesnt_close_mt53 = false
				if obj:is_player() then
					local name = obj:get_player_name()
					if mcl_beds then
						local meta = obj:get_meta()
						if meta:get_string("mcl_beds:sleeping") == "true" then
							minetest.close_formspec(name, "") -- ABSOLUTELY NECESSARY FOR MT5.3 -- TODO: REMOVE THIS IN THE FUTURE
							sleep_formspec_doesnt_close_mt53 = true
						end
					end
				end

				if sleep_formspec_doesnt_close_mt53 then
					minetest.after(0.3,
						function() -- 0.2 is minimum delay for closing old formspec and open died formspec -- TODO: REMOVE THIS IN THE FUTURE
							if not obj:is_player() then
								return
							end
							if exchangeclone.mcl then
								mcl_util.deal_damage(obj, damage, { type = "hit", direct = player})
							else
								obj:set_hp(obj:get_hp() - damage)
							end
							obj:add_velocity(vector.multiply(punch_dir, knockback/distance))
						end)
				else
					if exchangeclone.mcl then
						mcl_util.deal_damage(obj, damage, { type = "hit", direct = player})
					else
						obj:set_hp(obj:get_hp() - damage)
					end
					obj:add_velocity(vector.multiply(punch_dir, knockback/distance))
				end
			end
		end
		exchangeclone.start_cooldown(player, "sword", cooldown)
	end
end

local red_matter_sword_action = function(itemstack, player, pointed_thing)
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

	local aoe_function = exchangeclone.aoe_attack({damage = 16, knockback = 20, radius = 7.5, damage_all = damage_all, cooldown = 0.7})
	aoe_function(itemstack, player, pointed_thing)
end

minetest.register_tool("exchangeclone:dark_matter_sword", {
	description = "Dark Matter Sword",
	wield_image = "exchangeclone_dark_matter_sword.png",
	inventory_image = "exchangeclone_dark_matter_sword.png",
	groups = { tool=1, sword=1, dig_speed_class=5, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		full_punch_interval = 1/1.6,
		max_drop_level=6,
		damage_groups = {fleshy=13},
		punch_attack_uses = 0,
		groupcaps={
			snappy = {times = exchangeclone.get_mtg_times(14, nil, "snappy"), uses=0, maxlevel=4},
		},
	},
	on_secondary_use = exchangeclone.aoe_attack({damage = 12, knockback = 12, radius = 5, cooldown = 0.7}),
	on_place = exchangeclone.aoe_attack({damage = 12, knockback = 12, radius = 5, cooldown = 0.7}),
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 14, level = 5, uses = 0 }
	},
	wear_represents = "exchangeclone_charge_level"
})

minetest.register_tool("exchangeclone:red_matter_sword", {
	description = "Red Matter Sword",
	wield_image = "exchangeclone_red_matter_sword.png",
	inventory_image = "exchangeclone_red_matter_sword.png",
	groups = { tool=1, sword=1, dig_speed_class=6, enchantability=0, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 1/1.6,
		max_drop_level=7,
		damage_groups = {fleshy=17},
		punch_attack_uses = 0,
		groupcaps={
			snappy = {times = exchangeclone.get_mtg_times(16, nil, "snappy"), uses=0, maxlevel=5},
		},
	},
	on_secondary_use = red_matter_sword_action,
	on_place = red_matter_sword_action,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 16, level = 6, uses = 0 }
	},
	wear_represents = "exchangeclone_charge_level"
})

minetest.register_craft({
    output = "exchangeclone:dark_matter_sword",
    recipe = {
        {"exchangeclone:dark_matter"},
        {"exchangeclone:dark_matter"},
        {exchangeclone.itemstrings.diamond}
    }
})

minetest.register_craft({
	output = "exchangeclone:red_matter_sword",
	recipe = {
		{"exchangeclone:red_matter"},
		{"exchangeclone:red_matter"},
		{"exchangeclone:dark_matter_sword"},
	}
})