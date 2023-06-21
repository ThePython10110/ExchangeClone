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

if exchangeclone.mineclone then
	hoe_function = create_soil
else
	hoe_function = farming.hoe_on_use -- assuming farming exists
end

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
			minetest.chat_send_player(player:get_player_name(), "Single block mode")
		else
			itemstack:set_name(current_name.."_3x3")
			minetest.chat_send_player(player:get_player_name(), "3x3 mode")
		end
		return itemstack
	end
	local range = itemstack:get_meta():get_int("exchangeclone_item_range")
	if range == 0 and pointed_thing.type == "node" and pointed_thing.under and pointed_thing.under.x then
		--minetest.log(dump(pointed_thing))
		hoe_function(itemstack, player, pointed_thing)
		return itemstack
	end
    exchangeclone.play_ability_sound(player)
	local start_pos = player:get_pos()
	local player_energy = exchangeclone.get_player_energy(player)
	local energy_cost = 0
	if pointed_thing.type == "node" and pointed_thing.under and pointed_thing.under.x then
		start_pos = pointed_thing.under
	end
	--minetest.log(dump(start_pos))
    start_pos.x = exchangeclone.round(start_pos.x)
    start_pos.y = math.floor(start_pos.y) --make sure y is node BELOW player's feet
    start_pos.z = exchangeclone.round(start_pos.z)

	for x = start_pos.x - range, start_pos.x + range do
        if energy_cost + 2 > player_energy then
            break
        end
	for y = start_pos.y - range, start_pos.y + range do
        if energy_cost + 2 > player_energy then
            break
        end
	for z = start_pos.z - range, start_pos.z + range do
        if energy_cost + 2 > player_energy then
            break
        end
		local new_pos = {x=x,y=y,z=z}
		local new_pointed_thing = {type = "node", under = new_pos, above = {x=x,y=x+1,z=z}}
		energy_cost = energy_cost + 2
		hoe_function(itemstack, player, new_pointed_thing)
	end
	end
	end
	exchangeclone.set_player_energy(player, player_energy - energy_cost)
	return itemstack
end

if exchangeclone.mineclone then
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

minetest.register_tool("exchangeclone:dark_matter_hoe", {
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
})

minetest.register_tool("exchangeclone:dark_matter_hoe_3x3", {
	description = "Dark Matter Hoe",
	wield_image = "exchangeclone_dark_matter_hoe.png",
	inventory_image = "exchangeclone_dark_matter_hoe.png",
	wield_scale = exchangeclone.wield_scale,
	on_place = hoe_on_place,
	on_secondary_use = hoe_on_place,
	groups = { tool=1, hoe=1, enchantability=0, dark_matter_hoe = 1, not_in_creative_inventory = 1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 7, },
		groupcaps={
			exchangeclone_dirt = {times={[1]=0.4, [2]=0.4, [3]=0.4}, uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 8, level = 7, uses = 0 },
		hoey = { speed = 8, level = 7, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:red_matter_hoe", {
	description = "Red Matter Hoe",
	wield_image = "exchangeclone_red_matter_hoe.png",
	inventory_image = "exchangeclone_red_matter_hoe.png",
	wield_scale = exchangeclone.wield_scale,
	on_place = hoe_on_place,
	on_secondary_use = hoe_on_place,
	groups = { tool=1, hoe=1, enchantability=0, red_matter_hoe = 1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 8, },
		groupcaps={
			exchangeclone_dirt = {times={[1]=0.15, [2]=0.15, [3]=0.15}, uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 13, level = 8, uses = 0 },
		hoey = { speed = 13, level = 8, uses = 0 }
	},
})

minetest.register_tool("exchangeclone:red_matter_hoe_3x3", {
	description = "Red Matter Hoe",
	wield_image = "exchangeclone_red_matter_hoe.png",
	inventory_image = "exchangeclone_red_matter_hoe.png",
	wield_scale = exchangeclone.wield_scale,
	on_place = hoe_on_place,
	on_secondary_use = hoe_on_place,
	groups = { tool=1, hoe=1, enchantability=0, red_matter_hoe = 1, not_in_creative_inventory = 1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 8, },
		groupcaps={
			exchangeclone_dirt = {times={[1]=0.25, [2]=0.25, [3]=0.25}, uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
        exchangeclone_dirt = { speed = 9, level = 8, uses = 0 },
		hoey = { speed = 9, level = 8, uses = 0 }
	},
})

-- adapted from https://github.com/cultom/hammermod/blob/master/init.lua
local players_digging = {}

local function dig_if_dirt(pos, player)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "exchangeclone_dirt") ~= 0 then
		minetest.node_dig(pos, minetest.get_node(pos), player)
	end
end

minetest.register_on_dignode(
  function(pos, oldnode, player)
    if player == nil or (player:get_wielded_item():get_name() ~= "exchangeclone:dark_matter_hoe_3x3"
		and player:get_wielded_item():get_name() ~= "exchangeclone:red_matter_hoe_3x3") then
      return
    end
    
    local playerName = player:get_player_name()
    if (playerName == ""  or players_digging[playerName]) then
      return
    end
    players_digging[playerName] = true
    
	local player_rotation = exchangeclone.get_face_direction(player)

	local dir1
	local dir2

	if player_rotation.y ~= 0 then
		dir1 = "x"
		dir2 = "z"
	elseif player_rotation.x ~= 0 then
		dir1 = "y"
		dir2 = "z"
	elseif player_rotation.z ~= 0 then
		dir1 = "x"
		dir2 = "y"
	end

    --[[
        123
        4 5
        678
    ]]

	pos[dir1] = pos[dir1] - 1 --7
	dig_if_dirt(pos, player)
	pos[dir2] = pos[dir2] - 1 --6
	dig_if_dirt(pos, player)
	pos[dir1] = pos[dir1] + 1 --4
	dig_if_dirt(pos, player)
	pos[dir1] = pos[dir1] + 1 --1
	dig_if_dirt(pos, player)
	pos[dir2] = pos[dir2] + 1 --2
	dig_if_dirt(pos, player)
	pos[dir2] = pos[dir2] + 1 --3
	dig_if_dirt(pos, player)
	pos[dir1] = pos[dir1] - 1 --5
	dig_if_dirt(pos, player)
	pos[dir1] = pos[dir1] - 1 --8
	dig_if_dirt(pos, player)

    players_digging[playerName] = nil
  end
)

-- end copied code

minetest.register_craft({
    output = "exchangeclone:dark_matter_hoe",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", ""},
        {"", exchangeclone.diamond_itemstring, ""},
        {"", exchangeclone.diamond_itemstring, ""}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_hoe",
    recipe = {
        {"exchangeclone:red_matter", "exchangeclone:red_matter", ""},
        {"", "group:dark_matter_hoe", ""},
        {"", "exchangeclone:dark_matter", ""}
    }
})