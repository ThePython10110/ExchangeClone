local stone_group = "cracky"
if exchangeclone.mineclone then
	stone_group = "pickaxey"
end

local players_digging = {}

local hammer_break_cube = function(player, center, distance)
    players_digging[player:get_player_name()] = true -- to prevent doing 3x3 as well as AOE
    exchangeclone.play_ability_sound(player)
    local player_pos = player:get_pos()
    local player_energy = exchangeclone.get_player_energy(player)
    local energy_cost = 0
    local pos = center
    pos.x = exchangeclone.round(pos.x)
    pos.y = math.floor(pos.y) --make sure y is node BELOW player's feet
    pos.z = exchangeclone.round(pos.z)

    for x = pos.x-distance, pos.x+distance do
        if energy_cost + 8 > player_energy then
            break
        end
    for y = pos.y-distance, pos.y+distance do
        if energy_cost + 8 > player_energy then
            break
        end
    for z = pos.z-distance, pos.z+distance do
        if energy_cost + 8 > player_energy then
            break
        end
        local new_pos = {x=x,y=y,z=z}
        local node = minetest.get_node(new_pos) or {name="air"}
	    if minetest.get_item_group(node.name, stone_group) ~= 0 then
            if minetest.is_protected(new_pos, player:get_player_name()) then
                minetest.record_protection_violation(new_pos, player:get_player_name())
            else
                energy_cost = energy_cost + 8
                local drops = minetest.get_node_drops(node.name, "exchangeclone:red_matter_hammer")
                exchangeclone.drop_items_on_player(new_pos, drops, player)
                minetest.set_node(new_pos, {name = "air"})
            end
        end
    end
    end
    end
    exchangeclone.set_player_energy(player, player_energy - energy_cost)
    players_digging[player:get_player_name()] = nil
end

local function hammer_on_place(itemstack, player, pointed_thing)
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
    local center = player:get_pos()
    if pointed_thing.type == "node" then
        center = pointed_thing.under
    end
    hammer_break_cube(player, center, range)
end

minetest.register_tool("exchangeclone:dark_matter_hammer", {
	description = "Dark Matter Hammer",
	wield_image = "exchangeclone_dark_matter_hammer.png",
	inventory_image = "exchangeclone_dark_matter_hammer.png",
	groups = { tool=1, hammer=1, dig_speed_class=7, enchantability=0, dark_matter_hammer = 1 },
	wield_scale = exchangeclone.wield_scale,
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
    on_place = hammer_on_place,
    on_secondary_use = hammer_on_place,
})

minetest.register_tool("exchangeclone:dark_matter_hammer_3x3", {
	description = "Dark Matter Hammer",
	wield_image = "exchangeclone_dark_matter_hammer.png",
	inventory_image = "exchangeclone_dark_matter_hammer.png",
	groups = { tool=1, hammer=1, dig_speed_class=7, enchantability=0, dark_matter_hammer = 1, not_in_creative_inventory = 1 },
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1.8, [2]=0.9, [3]=0.5}, uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 12, level = 7, uses = 0 }
	},
    on_place = hammer_on_place,
    on_secondary_use = hammer_on_place,
})

minetest.register_tool("exchangeclone:red_matter_hammer", {
	description = "Red Matter Hammer",
	wield_image = "exchangeclone_red_matter_hammer.png",
	inventory_image = "exchangeclone_red_matter_hammer.png",
	groups = { tool=1, hammer=1, dig_speed_class=7, enchantability=0, red_matter_hammer = 1 },
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.3,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1, [2]=0.5, [3]=0.2}, uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 19, level = 8, uses = 0 }
	},
    on_place = hammer_on_place,
    on_secondary_use = hammer_on_place,
})

minetest.register_tool("exchangeclone:red_matter_hammer_3x3", {
	description = "Red Matter Hammer",
	wield_image = "exchangeclone_red_matter_hammer.png",
	inventory_image = "exchangeclone_red_matter_hammer.png",
	groups = { tool=1, hammer=1, dig_speed_class=7, enchantability=0, red_matter_hammer = 1, not_in_creative_inventory = 1 },
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.3,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1.25, [2]=0.6, [3]=0.3}, uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 14, level = 8, uses = 0 }
	},
    on_place = hammer_on_place,
    on_secondary_use = hammer_on_place,
})

-- adapted from https://github.com/cultom/hammermod/blob/master/init.lua

local function dig_if_stone(pos, player)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, stone_group) ~= 0 then
		minetest.node_dig(pos, minetest.get_node(pos), player)
	end
end

minetest.register_on_dignode(
  function(pos, oldnode, player)
    if player == nil or (player:get_wielded_item():get_name() ~= "exchangeclone:dark_matter_hammer_3x3"
		and player:get_wielded_item():get_name() ~= "exchangeclone:red_matter_hammer_3x3") then
      return
    end
    
    local playerName = player:get_player_name()
    if(playerName == ""  or players_digging[playerName]) then
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
	dig_if_stone(pos, player)
	pos[dir2] = pos[dir2] - 1 --6
	dig_if_stone(pos, player)
	pos[dir1] = pos[dir1] + 1 --4
	dig_if_stone(pos, player)
	pos[dir1] = pos[dir1] + 1 --1
	dig_if_stone(pos, player)
	pos[dir2] = pos[dir2] + 1 --2
	dig_if_stone(pos, player)
	pos[dir2] = pos[dir2] + 1 --3
	dig_if_stone(pos, player)
	pos[dir1] = pos[dir1] - 1 --5
	dig_if_stone(pos, player)
	pos[dir1] = pos[dir1] - 1 --8
	dig_if_stone(pos, player)

    players_digging[playerName] = nil
  end
)

-- end copied code

minetest.register_craft({
    output = "exchangeclone:dark_matter_hammer",
    recipe = {
        {"exchangeclone:dark_matter", exchangeclone.diamond_itemstring, "exchangeclone:dark_matter"},
        {"", exchangeclone.diamond_itemstring, ""},
        {"", exchangeclone.diamond_itemstring, ""}
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