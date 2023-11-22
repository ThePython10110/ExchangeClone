local S = minetest.get_translator()

-- Everything with the exchangeclone_ore group is also included (see pickaxes.lua)
-- This is pretty much the one thing I can't really figure out how to automate.
local ores = {
	["default:copper_lump"] = true,
	["default:gold_lump"] = true,
	["default:iron_lump"] = true,
	["default:tin_lump"] = true,

	["mcl_copper:raw_copper"] = true,
	["mcl_raw_ores:raw_gold"] = true,
	["mcl_raw_ores:raw_iron"] = true,

	["moreores:mithril_lump"] = true,
	["moreores:silver_lump"] = true,
	["moreores:tin_lump"] = true, -- tin is built into MTG but it's in the moreores code

	["technic:chromium_lump"] = true,
	["technic:lead_lump"] = true,
	["technic:uranium_lump"] = true,
	["technic:zinc_lump"] = true,
}

local furnace_itemstring = "default:furnace"
if exchangeclone.mcl then
	furnace_itemstring = "mcl_furnaces:furnace"
end

local function get_level(level)
    if exchangeclone.mcl then
        return nil
    else
        return level
    end
end

local function is_ore(itemstring)
	if ores[itemstring] then return true end
	local exchangeclone_ore = minetest.get_item_group(itemstring, "exchangeclone_ore")
	if exchangeclone_ore and exchangeclone_ore ~= 0 then return true end
	return false
end

local LIGHT_ACTIVE_FURNACE = 13

-- Modified from MineClone's blast furnaces.

--
-- Formspecs
--

local base_formspec =
-- Craft guide button temporarily removed due to Minetest bug.
-- TODO: Add it back when the Minetest bug is fixed.
--"image_button[8,0;1,1;craftguide_book.png;craftguide;]"..
--"tooltip[craftguide;"..minetest.formspec_escape("Recipe book").."]"..
	"size[10,8.75]"..
	"label[0,4;"..S("Inventory").."]"..
	exchangeclone.inventory_formspec(0,4.5)..
	"list[context;src;2.9,0.5;1,1]"..
	"list[context;fuel;2.9,2.5;1,1;]"..
	"list[context;dst;5.75,1.5;1,1;]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	"listring[context;fuel]"..
	"listring[current_player;main]"

if exchangeclone.mcl then
	base_formspec = base_formspec..
		mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
		mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
		mcl_formspec.get_itemslot_bg(2.9,0.5,1,1)..
		mcl_formspec.get_itemslot_bg(2.9,2.5,1,1)..
		mcl_formspec.get_itemslot_bg(5.75,1.5,1,1)
end

local function inactive_formspec(matter_type)
	local num_columns = (matter_type == "Dark" and 2) or 3
	local result = base_formspec..
	"list[context;src;0,0.5;"..tostring(num_columns)..",3;1]"..
	"list[context;dst;7,0.5;"..tostring(num_columns)..",3;1]"..
	"label[2.9,0;"..S("@1 Matter Furnace", S(matter_type)).."]"..
	"image[2.9,1.5;1,1;default_furnace_fire_bg.png]"..
	"image[4.1,1.5;1.5,1;gui_furnace_arrow_bg.png^[transformR270]"
	if exchangeclone.mcl then
		result = result..
			mcl_formspec.get_itemslot_bg(0,0.5,num_columns,3)..
			mcl_formspec.get_itemslot_bg(7,0.5,num_columns,3)
	end
	return result
end

local function active_formspec(fuel_percent, item_percent, matter_type)
	local num_columns = (matter_type == "Dark" and 2) or 3
	local result =  base_formspec..
	"image[2.9,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
		(100-fuel_percent)..":default_furnace_fire_fg.png]"..
	"list[context;src;0,0.5;"..tostring(num_columns)..",3;1]"..
	"list[context;dst;7,0.5;"..tostring(num_columns)..",3;1]"..
	"label[2.9,0;"..S("@1 Matter Furnace", S(matter_type)).."]"..
	"image[4.1,1.5;1.5,1;gui_furnace_arrow_bg.png^[lowpart:"..
		(item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"
	if exchangeclone.mcl then
		result = result..
			mcl_formspec.get_itemslot_bg(0,0.5,num_columns,3)..
			mcl_formspec.get_itemslot_bg(7,0.5,num_columns,3)
	end
	return result
end

local receive_fields = function(pos, formname, fields, sender)
	if fields.craftguide and exchangeclone.mcl then
		mcl_craftguide.show(sender:get_player_name())
	end
end

--[[local function give_xp(pos, player)
	local meta = minetest.get_meta(pos)
	local dir = vector.divide(minetest.facedir_to_dir(minetest.get_node(pos).param2),-1.95)
	local xp = meta:get_int("xp")
	if xp > 0 then
		if player then
			mcl_experience.add_xp(player, xp)
		else
			mcl_experience.throw_xp(vector.add(pos, dir), xp)
		end
		meta:set_int("xp", 0)
	end
end]]

--
-- Node callback functions that are the same for active and inactive furnace
--

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if player and player.get_player_name then
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		end
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		-- Test stack with size 1 because we burn one fuel at a time
		local teststack = ItemStack(stack)
		teststack:set_count(1)
		local output, decremented_input = minetest.get_craft_result({method="fuel", width=1, items={teststack}})
		if output.time ~= 0 then
			-- Only allow to place 1 item if fuel get replaced by recipe.
			-- This is the case for lava buckets.
			local replace_item = decremented_input.items[1]
			if replace_item:is_empty() then
				-- For most fuels, just allow to place everything
				return stack:get_count()
			else
				if inv:get_stack(listname, index):get_count() == 0 then
					return 1
				else
					return 0
				end
			end
		else
			return 0
		end
	elseif listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	end
	return stack:get_count()
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	-- Award smelting achievements
	if exchangeclone.mcl and listname == "dst" then
		if stack:get_name() == "mcl_core:iron_ingot" then
			awards.unlock(player:get_player_name(), "mcl:acquireIron")
		end
		--give_xp(pos, player)
	end
end

local function spawn_flames(pos, param2)
	if not exchangeclone.mcl then return end
	local minrelpos, maxrelpos
	local dir = minetest.facedir_to_dir(param2)
	if dir.x > 0 then
		minrelpos = { x = -0.6, y = -0.05, z = -0.25 }
		maxrelpos = { x = -0.55, y = -0.45, z = 0.25 }
	elseif dir.x < 0 then
		minrelpos = { x = 0.55, y = -0.05, z = -0.25 }
		maxrelpos = { x = 0.6, y = -0.45, z = 0.25 }
	elseif dir.z > 0 then
		minrelpos = { x = -0.25, y = -0.05, z = -0.6 }
		maxrelpos = { x = 0.25, y = -0.45, z = -0.55 }
	elseif dir.z < 0 then
		minrelpos = { x = -0.25, y = -0.05, z = 0.55 }
		maxrelpos = { x = 0.25, y = -0.45, z = 0.6 }
	else
		return
	end
	mcl_particles.add_node_particlespawner(pos, {
		amount = 4,
		time = 0,
		minpos = vector.add(pos, minrelpos),
		maxpos = vector.add(pos, maxrelpos),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.4,
		maxsize = 0.8,
		texture = "mcl_particles_flame.png",
		glow = LIGHT_ACTIVE_FURNACE,
	}, "low")
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
	if name == "exchangeclone:dark_matter_furnace_active" or name == "exchangeclone:red_matter_furnace_active" then
		spawn_flames(pos, node.param2)
	elseif exchangeclone.mcl then
		mcl_particles.delete_node_particlespawners(pos)
	end
end

local function furnace_reset_delta_time(pos)
	local meta = minetest.get_meta(pos)
	local time_speed = tonumber(minetest.settings:get("time_speed") or 72)
	if (time_speed < 0.1) then
		return
	end
	local time_multiplier = 86400 / time_speed
	local current_game_time = .0 + ((minetest.get_day_count() + minetest.get_timeofday()) * time_multiplier)

	-- TODO: Change meta:get/set_string() to get/set_float() for "last_gametime".
	-- In Windows *_float() works OK but under Linux it returns rounded unusable values like 449540.000000000
	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 or math.abs(last_game_time - current_game_time) <= 1.5 then
		return
	end

	meta:set_string("last_gametime", tostring(current_game_time))
end

local function furnace_get_delta_time(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local time_speed = tonumber(minetest.settings:get("time_speed") or 72)
	local current_game_time
	if (time_speed < 0.1) then
		return meta, elapsed
	else
		local time_multiplier = 86400 / time_speed
		current_game_time = .0 + ((minetest.get_day_count() + minetest.get_timeofday()) * time_multiplier)
	end

	local last_game_time = meta:get_string("last_gametime")
	if last_game_time then
		last_game_time = tonumber(last_game_time)
	end
	if not last_game_time or last_game_time < 1 then
		last_game_time = current_game_time - 0.1
	elseif last_game_time == current_game_time then
		current_game_time = current_game_time + 1.0
	end

	local elapsed_game_time = .0 + current_game_time - last_game_time

	meta:set_string("last_gametime", tostring(current_game_time))

	return meta, elapsed_game_time
end

local function check_srclist(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:get_stack("src", 1):is_empty() then
		return "not empty"
	end
	local size = inv:get_size("src")
	for i=2,size do
		local stack = inv:get_stack("src", i)
		if not stack:is_empty() then
			inv:set_stack("src", 1, stack)
			inv:set_stack("src", i, ItemStack(""))
			return true
		end
	end
end

local function furnace_node_timer(pos, elapsed)
	--
	-- Inizialize metadata
	--
	local meta, elapsed_game_time = furnace_get_delta_time(pos, elapsed)

	local fuel_time = meta:get_float("fuel_time") or 0
	local src_time = meta:get_float("src_time") or 0
	local src_item = meta:get_string("src_item") or ""
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()
	local srclist, fuellist

	local cookable, cooked
	local active = true
	local fuel

	local using_collector = meta:get_int("using_collector") > 0

	local matter_type = "Dark"
	local speed = 22 -- /10 to get items/second
	if minetest.get_node(pos).name:find("red_matter") then
		matter_type = "Red"
		speed = 66
	end

	srclist = inv:get_list("src")
	fuellist = inv:get_list("fuel")

	-- Check if src item has been changed
	if srclist[1]:get_name() ~= src_item then
		-- Reset cooking progress in this case
		src_time = 0
		src_item = srclist[1]:get_name()
	end

	local update = true
	while elapsed_game_time > 0.00001 and update do
		--
		-- Cooking
		--

		-- Run the furnace <speed> times faster than a normal furnace.
		local el = elapsed_game_time * speed

		-- Check if we have cookable content: cookable
		local aftercooked
		cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = {srclist[1]}})
		cookable = cooked.item ~= ItemStack("") --minetest.get_item_group(inv:get_stack("src", 1):get_name(), "furnace_smeltable") == 1
		if cookable then
			-- Successful cooking requires space in dst slot and time
			if not inv:room_for_item("dst", cooked.item) then
				cookable = false
			end
		end

		if cookable then -- fuel lasts long enough, adjust el to cooking duration
			el = math.min(el, cooked.time - src_time)
		end

		-- Check if we have enough fuel to burn
		active = (fuel_time < fuel_totaltime) or (using_collector and cooked.item ~= ItemStack(""))
		if cookable and not active then
			-- We need to get new fuel
			local afterfuel
			fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

			if fuel.time == 0 then
				-- No valid fuel in fuel list -- stop
				fuel_totaltime = 0
				src_time = 0
				update = false
			else
				-- Take fuel from fuel list
				inv:set_stack("fuel", 1, afterfuel.items[1])
				fuel_time = 0
				fuel_totaltime = fuel.time*5.5 -- 5.5x more fuel efficient for DM/RM furnaces
				el = math.min(el, fuel_totaltime)
				active = true
				fuellist = inv:get_list("fuel")
			end
		elseif active then
			if using_collector then
				el = 10
			else
				-- The furnace is currently active and has enough fuel
				el = math.min(el, fuel_totaltime - fuel_time)
				fuel_time = fuel_time + el
			end
		end

		-- If there is a cookable item then check if it is ready yet
		if cookable and active then
			src_time = src_time + el
			-- Place result in dst list if done
			if src_time >= cooked.time then
				local count = cooked.item:get_count()
				if is_ore(srclist[1]:get_name()) and (count * 2 <= cooked.item:get_stack_max()) then
					if matter_type == "Red" or (matter_type == "Dark" and math.random(1,2) == 1) then
						cooked.item:set_count(count*2)
					end
				end
				inv:add_item("dst", cooked.item)
				inv:set_stack("src", 1, aftercooked.items[1])
				srclist = inv:get_list("src")
				src_time = 0

				--meta:set_int("xp", meta:get_int("xp") + 1)		-- ToDo give each recipe an idividial XP count
			end
		end
		elapsed_game_time = elapsed_game_time - el
	end

	if fuel and fuel_totaltime > fuel.time * 5.5 then
		fuel_totaltime = fuel.time * 5.5
	end
	if srclist and srclist[1]:is_empty() then
		active = check_srclist(pos)
		if srclist and srclist[1]:is_empty() then
			src_time = 0
		end
	end

	--
	-- Update formspec and node
	--
	local formspec = inactive_formspec(matter_type)
	local item_percent = 0
	if cookable then
		item_percent = math.floor(src_time / cooked.time * 100)
	end

	local result = false

	if active then
		local fuel_percent = 0
		if fuel_totaltime > 0 then
			fuel_percent = math.floor(fuel_time / fuel_totaltime * 100)
		end
		formspec = active_formspec(fuel_percent, item_percent, matter_type)
		swap_node(pos, "exchangeclone:"..matter_type:lower().."_matter_furnace_active")
		-- make sure timer restarts automatically
		result = true
	else
		swap_node(pos, "exchangeclone:"..matter_type:lower().."_matter_furnace")
		-- stop timer on the inactive furnace
		minetest.get_node_timer(pos):stop()
	end

	--
	-- Set meta values
	--
	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_float("src_time", src_time)
	if srclist then
		 meta:set_string("src_item", src_item)
	else
		 meta:set_string("src_item", "")
	end
	meta:set_string("formspec", formspec)

	return result
end

local on_rotate, after_rotate_active
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
	after_rotate_active = function(pos)
		local node = minetest.get_node(pos)
		if exchangeclone.mcl then
			mcl_particles.delete_node_particlespawners(pos)
		end
		if node.name == "exchangeclone:dark_matter_furnace" or node.name == "exchangeclone:red_matter_furnace" then
			return
		end
		spawn_flames(pos, node.param2)
		if exchangeclone.pipeworks then
			pipeworks.on_rotate(pos)
		end
	end
end

local inactive_def = {
	description = S("Dark Matter Furnace"),
	tiles = {
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_furnace.png",
	},
	paramtype2 = "4dir",
	groups = {pickaxey=5, cracky = 3, container=4, material_stone=1, level = get_level(4), exchangeclone_furnace = 1, tubedevice = 1, tubedevice_receiver = 1},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),

	on_timer = furnace_node_timer,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			if listname == "src" or listname == "dst" then
				for i = 1,7 do
					local stack = inv:get_stack(listname, i)
					if not stack:is_empty() then
						local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
						minetest.add_item(p, stack)
					end
				end
			else
				local stack = inv:get_stack(listname, 1)
				if not stack:is_empty() then
					local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
					minetest.add_item(p, stack)
				end
			end
		end
		meta:from_table(meta2)
		if exchangeclone.pipeworks then
			pipeworks.after_dig(pos)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec("Dark"))
		local inv = meta:get_inventory()
		inv:set_size("src", 7)
		inv:set_size("fuel", 1)
		inv:set_size("dst", 7)
	end,
	on_destruct = function(pos)
		if exchangeclone.mcl then
			mcl_particles.delete_node_particlespawners(pos)
		--give_xp(pos)
		end
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		check_srclist(pos)
	end,
	on_metadata_inventory_put = function(pos)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		check_srclist(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		minetest.get_node_timer(pos):start(0.45)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		check_srclist(pos)
		-- start timer function, it will helpful if player clears dst slot
		minetest.get_node_timer(pos):start(0.45)

		on_metadata_inventory_take(pos, listname, index, stack, player)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_receive_fields = receive_fields,
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 75,
	on_rotate = on_rotate,
	after_place_node = exchangeclone.pipeworks and pipeworks.after_place
}

local active_def = {
	description = S("Active Dark Matter Furnace"),
	tiles = {
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_block.png",
		"exchangeclone_dark_matter_furnace.png",
	},
	paramtype2 = "4dir",
	parammatter_type = "light",
	light_source = LIGHT_ACTIVE_FURNACE,
	drop = "exchangeclone:dark_matter_furnace",
	groups = {pickaxey=5, not_in_creative_inventory = 1, container = 4, material_stone=1, cracky = 3, level = get_level(4), exchangeclone_furnace = 1, tubedevice = 1, tubedevice_receiver = 1},
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	on_timer = furnace_node_timer,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			if listname == "src" or listname == "dst" then
				for i = 1,7 do
					local stack = inv:get_stack(listname, i)
					if not stack:is_empty() then
						local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
						minetest.add_item(p, stack)
					end
				end
			else
				local stack = inv:get_stack(listname, 1)
				if not stack:is_empty() then
					local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
					minetest.add_item(p, stack)
				end
			end
		end
		meta:from_table(meta2)
		if exchangeclone.pipeworks then
			pipeworks.after_dig(pos)
		end
	end,

	on_construct = function(pos)
		local node = minetest.get_node(pos)
		spawn_flames(pos, node.param2)
	end,
	on_destruct = function(pos)
		if exchangeclone.mcl then
			mcl_particles.delete_node_particlespawners(pos)
			--give_xp(pos)
		end
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_take = on_metadata_inventory_take,
	on_receive_fields = receive_fields,
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 75,
	on_rotate = on_rotate,
	after_rotate = after_rotate_active,
	after_place_node = exchangeclone.pipeworks and pipeworks.after_place
}

if exchangeclone.pipeworks then
	local function get_list(direction)
		return (direction.y == 0 and "src") or "fuel"
	end
	for _, table in pairs({inactive_def, active_def}) do
		table.tube = {
			input_inventory = "dst",
			connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1},
			insert_object = function(pos, node, stack, direction)
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local result = inv:add_item(get_list(direction), stack)
				if result then
					local func = minetest.registered_items[node.name].on_metadata_inventory_put
					if func then func(pos) end
				end
				return result
			end,
			can_insert = function(pos, node, stack, direction)
				if allow_metadata_inventory_put(pos, get_list(direction), 1, stack) > 0 then
					return true
				end
			end
		}
	end
end

minetest.register_node("exchangeclone:dark_matter_furnace", table.copy(inactive_def))
minetest.register_node("exchangeclone:red_matter_furnace", table.copy(inactive_def))
minetest.register_node("exchangeclone:dark_matter_furnace_active", table.copy(active_def))
minetest.register_node("exchangeclone:red_matter_furnace_active", table.copy(active_def))

minetest.override_item("exchangeclone:red_matter_furnace", {
	description = S("Red Matter Furnace"),
	tiles = {
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_furnace.png",
	},
	groups = {pickaxey=5, cracky = 3, container=4, deco_block=1, material_stone=1, level = get_level(5), exchangeclone_furnace = 2, tubedevice = 1, tubedevice_receiver = 1},
	_mcl_hardness = 100,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		check_srclist(pos)
		minetest.get_node_timer(pos):start(0.16)
	end,
	on_metadata_inventory_put = function(pos)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		check_srclist(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		minetest.get_node_timer(pos):start(0.16)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		-- Reset accumulated game time when player works with furnace:
		furnace_reset_delta_time(pos)
		check_srclist(pos)
		-- start timer function, it will helpful if player clears dst slot
		minetest.get_node_timer(pos):start(0.16)

		on_metadata_inventory_take(pos, listname, index, stack, player)
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec("Red"))
		local inv = meta:get_inventory()
		inv:set_size("src", 10)
		inv:set_size("fuel", 1)
		inv:set_size("dst", 10)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			if listname == "src" or listname == "dst" then
				for i = 1,10 do
					local stack = inv:get_stack(listname, i)
					if not stack:is_empty() then
						local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
						minetest.add_item(p, stack)
					end
				end
			else
				local stack = inv:get_stack(listname, 1)
				if not stack:is_empty() then
					local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
					minetest.add_item(p, stack)
				end
			end
		end
		meta:from_table(meta2)
		if exchangeclone.pipeworks then
			pipeworks.after_dig(pos)
		end
	end,

})

minetest.override_item("exchangeclone:red_matter_furnace_active", {
	description = S("Active Red Matter Furnace"),
	tiles = {
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_block.png",
		"exchangeclone_red_matter_furnace.png",
	},
	drop = "exchangeclone:red_matter_furnace",
	groups = {pickaxey=5, not_in_creative_inventory = 1, cracky = 3, container=4, deco_block=1, material_stone=1, level = get_level(5), exchangeclone_furnace = 2, tubedevice = 1, tubedevice_receiver = 1},
	_mcl_hardness = 100,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec("Red"))
		local inv = meta:get_inventory()
		inv:set_size("src", 10)
		inv:set_size("fuel", 1)
		inv:set_size("dst", 10)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"src", "dst", "fuel"}) do
			if listname == "src" or listname == "dst" then
				for i = 1,10 do
					local stack = inv:get_stack(listname, i)
					if not stack:is_empty() then
						local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
						minetest.add_item(p, stack)
					end
				end
			else
				local stack = inv:get_stack(listname, 1)
				if not stack:is_empty() then
					local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
					minetest.add_item(p, stack)
				end
			end
		end
		meta:from_table(meta2)
		if exchangeclone.pipeworks then
			pipeworks.after_dig(pos)
		end
	end,
})

minetest.register_craft({
	output = "exchangeclone:dark_matter_furnace",
	recipe = {
		{ "exchangeclone:dark_matter_block", "exchangeclone:dark_matter_block", "exchangeclone:dark_matter_block" },
		{ "exchangeclone:dark_matter_block", furnace_itemstring, "exchangeclone:dark_matter_block" },
		{ "exchangeclone:dark_matter_block", "exchangeclone:dark_matter_block", "exchangeclone:dark_matter_block" },
	}
})

minetest.register_craft({
	output = "exchangeclone:red_matter_furnace",
	recipe = {
		{ "", "exchangeclone:red_matter_block", "" },
		{ "exchangeclone:red_matter_block", "exchangeclone:dark_matter_furnace", "exchangeclone:red_matter_block" },
	}
})

minetest.register_lbm({
	label = "Active furnace flame particles",
	name = "exchangeclone:furnace_flames",
	nodenames = {"exchangeclone:dark_matter_furnace_active","exchangeclone:red_matter_furnace_active"},
	run_at_every_load = true,
	action = function(pos, node)
		spawn_flames(pos, node.param2)
	end,
})

