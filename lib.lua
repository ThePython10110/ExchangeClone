function exchangeclone.get_inventory_drops(pos, inventory, drops) --removes default dependency
	local inv = minetest.get_meta(pos):get_inventory()
	local n = #drops
	for i = 1, inv:get_size(inventory) do
		local stack = inv:get_stack(inventory, i)
		if stack:get_count() > 0 then
			drops[n+1] = stack:to_table()
			n = n + 1
		end
	end
end

function exchangeclone.get_item_energy(name)
    return minetest.registered_items[name].energy_value
end

function exchangeclone.round(num)
    if num % 1 < 0.5 then
        return math.floor(num)
    else
        return math.ceil(num)
    end
end

function exchangeclone.get_orb_energy(inventory, listname, index)
    if not inventory then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    if not itemstack then return 0 end
    if not itemstack:get_name() then return 0 end
    return itemstack:get_meta():get_float("stored_energy")
end

function exchangeclone.set_orb_energy(inventory, listname, index, amount)
    if (not inventory) or (not amount) or (amount < 0) then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    if not itemstack then return end
    if not itemstack:get_name() then return end
    itemstack:get_meta():set_float("stored_energy", amount)
    itemstack:get_meta():set_string("description", "Exchange Orb\nCurrent Charge: "..amount)
    inventory:set_stack(listname, index, itemstack)
end

function exchangeclone.get_player_energy(player)
    return exchangeclone.get_orb_energy(player:get_inventory(), "exchangeclone_pesa", 1)
end

function exchangeclone.set_player_energy(player, amount)
    exchangeclone.set_orb_energy(player:get_inventory(), "exchangeclone_pesa", 1, amount)
end

function exchangeclone.get_group_items(groups, allow_duplicates, include_no_group)
	if type(groups) ~= "table" then
		return nil
	end

	allow_duplicates = allow_duplicates or false
    include_no_group = include_no_group or false

	local g_cnt = #groups

	local result = {}
	for i = 1, g_cnt do
		result[groups[i]] = {}
	end
    if include_no_group then
        result["NO_GROUP"] = {}
    end
    local in_group = false

	for name, def in pairs(minetest.registered_items) do
        in_group = false
		for i = 1, g_cnt do
			local grp = groups[i]
			if def.groups[grp] ~= nil then
				result[grp][#result[grp]+1] = name
                in_group = true
				if allow_duplicates == false then
					break
				end
			end
		end
        if include_no_group and in_group == false then
            result["NO_GROUP"][#result["NO_GROUP"]+1] = name
        end
	end

	return result
end

function exchangeclone.play_ability_sound(player, base_pitch)
    if not player then return end
    if not base_pitch then base_pitch = 1 end
    local new_pitch = base_pitch + (math.random(-100, 100) / 500)
    minetest.sound_play("exchangeclone_ability", {pitch = new_pitch, pos = player:get_pos(), max_hear_distance = 20, })
end

function exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if pointed_thing.type ~= "node" then return false end
    if player:get_player_control().sneak then return false end
    local node = minetest.get_node(pointed_thing.under)
    if player and not player:get_player_control().sneak then
        if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
            return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
        end
    end
    return false
end

function exchangeclone.range_update(itemstack, player, max)
    if not max then max = 4 end
    local range = tonumber(itemstack:get_meta():get_int("exchangeclone_item_range"))
    if player:get_player_control().sneak then
        if range == 0 then
            range = max
        else
            range = range - 1
        end
    else
        if range == max then
            range = 0
        else
            range = range + 1
        end
    end
    minetest.chat_send_player(player:get_player_name(), "Current Range: "..range)
    itemstack:get_meta():set_int("exchangeclone_item_range", range)
    return itemstack
end


exchangeclone.wield_scale = {x=1,y=1,z=1}
if exchangeclone.mineclone then
    exchangeclone.wield_scale = mcl_vars.tool_wield_scale
end

exchangeclone.diamond_itemstring = "default:diamond"
if exchangeclone.mineclone then
    exchangeclone.diamond_itemstring = "mcl_core:diamond"
end

local doTileDrops = minetest.settings:get_bool("mcl_doTileDrops", true)

function exchangeclone.drop_items_on_player(pos, drops, player) --copied from MineClone's code
    if not exchangeclone.mineclone then
        return minetest.handle_node_drops(pos, drops, player)
    end
	-- NOTE: This function override allows player to be nil.
	-- This means there is no player. This is a special case which allows this function to be called
	-- by hand. Creative Mode is intentionally ignored in this case.
	if player and player:is_player() and minetest.is_creative_enabled(player:get_player_name()) then
		local inv = player:get_inventory()
		if inv then
			for _, item in ipairs(drops) do
				if not inv:contains_item("main", item, true) then
					inv:add_item("main", item)
				end
			end
		end
		return
	elseif not doTileDrops then return end

	-- Check if node will yield its useful drop by the player's tool
	local dug_node = minetest.get_node(pos)
	local tooldef
	local tool
	if player then
		tool = player:get_wielded_item()
		tooldef = minetest.registered_items[tool:get_name()]

		if not mcl_autogroup.can_harvest(dug_node.name, tool:get_name(), player) then
			return
		end
	end

	local diggroups = tooldef and tooldef._mcl_diggroups
	local shearsy_level = diggroups and diggroups.shearsy and diggroups.shearsy.level

	--[[ Special node drops when dug by shears by reading _mcl_shears_drop or with a silk touch tool reading _mcl_silk_touch_drop
	from the node definition.
	Definition of _mcl_shears_drop / _mcl_silk_touch_drop:
	* true: Drop itself when dug by shears / silk touch tool
	* table: Drop every itemstring in this table when dug by shears _mcl_silk_touch_drop
	]]

	local enchantments = tool and mcl_enchanting.get_enchantments(tool)

	local silk_touch_drop = false
	local nodedef = minetest.registered_nodes[dug_node.name]
	if not nodedef then return end

	if shearsy_level and shearsy_level > 0 and nodedef._mcl_shears_drop then
		if nodedef._mcl_shears_drop == true then
			drops = { dug_node.name }
		else
			drops = nodedef._mcl_shears_drop
		end
	elseif tool and enchantments.silk_touch and nodedef._mcl_silk_touch_drop then
		silk_touch_drop = true
		if nodedef._mcl_silk_touch_drop == true then
			drops = { dug_node.name }
		else
			drops = nodedef._mcl_silk_touch_drop
		end
	end

	-- if tool and nodedef._mcl_fortune_drop and enchantments.fortune then
	-- 	local fortune_level = enchantments.fortune
	-- 	local fortune_drop = nodedef._mcl_fortune_drop
	-- 	if fortune_drop.discrete_uniform_distribution then
	-- 		local min_count = fortune_drop.min_count
	-- 		local max_count = fortune_drop.max_count + fortune_level * (fortune_drop.factor or 1)
	-- 		local chance = fortune_drop.chance or fortune_drop.get_chance and fortune_drop.get_chance(fortune_level)
	-- 		if not chance or math.random() < chance then
	-- 			drops = discrete_uniform_distribution(fortune_drop.multiply and drops or fortune_drop.items, min_count, max_count,
	-- 				fortune_drop.cap)
	-- 		elseif fortune_drop.override then
	-- 			drops = {}
	-- 		end
	-- 	else
	-- 		-- Fixed Behavior
	-- 		local drop = get_fortune_drops(fortune_drop, fortune_level)
	-- 		drops = get_drops(drop, tool:get_name(), dug_node.param2, nodedef.paramtype2)
	-- 	end
	-- end

	if player and mcl_experience.throw_xp and not silk_touch_drop then
		local experience_amount = minetest.get_item_group(dug_node.name, "xp")
		if experience_amount > 0 then
			mcl_experience.throw_xp(pos, experience_amount)
		end
	end

	for _, item in ipairs(drops) do
		local count
		if type(item) == "string" then
			count = ItemStack(item):get_count()
		else
			count = item:get_count()
		end
		local drop_item = ItemStack(item)
		drop_item:set_count(1)
		for i = 1, count do
			-- Spawn item
			local obj = minetest.add_item(player:get_pos(), drop_item)
			if obj then
				-- set the velocity multiplier to the stored amount or if the game dug this node, apply a bigger velocity
				obj:get_luaentity().age = 0.65
				obj:get_luaentity()._insta_collect = true
			end
		end
	end
end

function exchangeclone.get_face_direction(player)
    local h_look = player:get_look_horizontal()
    local v_look = player:get_look_vertical()

    local result = {x = 0, y = 0, z = 0}

    if h_look <= math.pi / 4 or h_look >= (7*math.pi)/4 then
        result.z = 1
    elseif h_look > math.pi / 4 and h_look <= (3*math.pi)/4 then
        result.x = -1
    elseif h_look > (3*math.pi)/4 and h_look <= (5*math.pi)/4 then
        result.z = -1
    else
        result.x = 1
    end

    if v_look < -1 then
        result.y = 1
    elseif v_look > 1 then
        result.y = -1
    end

	return result
end