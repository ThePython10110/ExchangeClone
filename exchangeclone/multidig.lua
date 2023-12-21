exchangeclone.multidig = {}

local stone_group = exchangeclone.mcl and "pickaxey" or "cracky"

local dirt_group = exchangeclone.mcl and "shovely" or "crumbly"

local function dig_if_group(pos, player, groups)
	local node = minetest.get_node(pos)
	for _, group in pairs(groups) do
		if minetest.get_item_group(node.name, group) > 0 then
			minetest.node_dig(pos, minetest.get_node(pos), player)
		end
	end
end

local special_dig = {
	["exchangeclone:dark_matter_pickaxe_3x1"] = {groups={stone_group}, mode="3x1"},
	["exchangeclone:red_matter_pickaxe_3x1"] = {groups={stone_group}, mode="3x1"},
	["exchangeclone:dark_matter_hammer_3x3"] = {groups={stone_group}, mode="3x3"},
	["exchangeclone:red_matter_hammer_3x3"] = {groups={stone_group}, mode="3x3"},
	["exchangeclone:dark_matter_hoe_3x3"] = {groups={"exchangeclone_dirt"}, mode="3x3"},
	["exchangeclone:red_matter_hoe_3x3"] = {groups={"exchangeclone_dirt"}, mode="3x3"},
	["exchangeclone:red_katar_3x3"] = {groups={"exchangeclone_dirt"}, mode="3x3"},
	["exchangeclone:red_morningstar_3x1"] = {groups={stone_group, dirt_group},mode="3x1"},
	["exchangeclone:red_morningstar_3x3"] = {groups={stone_group, dirt_group},mode="3x3"},
}

minetest.register_on_dignode(
  function(pos, oldnode, player)
    if not player then return end
	local itemname = player:get_wielded_item():get_name()
	local dig_data = special_dig[itemname]
	if not dig_data then return end

    local playername = player:get_player_name()
    if(playername == ""  or exchangeclone.multidig[playername]) then
      return
    end
    exchangeclone.multidig[playername] = true

    local player_rotation = exchangeclone.get_face_direction(player)

	if dig_data.mode == "3x3" then
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
		dig_if_group(pos, player, dig_data.groups)
		pos[dir2] = pos[dir2] - 1 --6
		dig_if_group(pos, player, dig_data.groups)
		pos[dir1] = pos[dir1] + 1 --4
		dig_if_group(pos, player, dig_data.groups)
		pos[dir1] = pos[dir1] + 1 --1
		dig_if_group(pos, player, dig_data.groups)
		pos[dir2] = pos[dir2] + 1 --2
		dig_if_group(pos, player, dig_data.groups)
		pos[dir2] = pos[dir2] + 1 --3
		dig_if_group(pos, player, dig_data.groups)
		pos[dir1] = pos[dir1] - 1 --5
		dig_if_group(pos, player, dig_data.groups)
		pos[dir1] = pos[dir1] - 1 --8
		dig_if_group(pos, player, dig_data.groups)
	elseif dig_data.mode == "3x1" then
		

		local current_mode = player:get_wielded_item():get_meta():get_string("exchangeclone_pick_mode")
		if current_mode == "" or not current_mode then current_mode = "tall" end
	
		local new_pos = table.copy(pos)
	
		if current_mode == "long" then
			if player_rotation.y ~= 0 then
				new_pos.y = new_pos.y + player_rotation.y
				dig_if_group(new_pos, player, dig_data.groups)
				new_pos.y = new_pos.y + player_rotation.y
				dig_if_group(new_pos, player, dig_data.groups)
			elseif player_rotation.z ~= 0 then
				new_pos.z = new_pos.z + player_rotation.z
				dig_if_group(new_pos, player, dig_data.groups)
				new_pos.z = new_pos.z + player_rotation.z
				dig_if_group(new_pos, player, dig_data.groups)
			else
				new_pos.x = new_pos.x + player_rotation.x
				dig_if_group(new_pos, player, dig_data.groups)
				new_pos.x = new_pos.x + player_rotation.x
				dig_if_group(new_pos, player, dig_data.groups)
			end
		elseif current_mode == "tall" then
			if player_rotation.y ~= 0 then
				if player_rotation.x ~= 0 then
					new_pos.x = pos.x - 1
					dig_if_group(new_pos, player, dig_data.groups)
					new_pos.x = pos.x + 1
					dig_if_group(new_pos, player, dig_data.groups)
				else
					new_pos.z = pos.z - 1
					dig_if_group(new_pos, player, dig_data.groups)
					new_pos.z = pos.z + 1
					dig_if_group(new_pos, player, dig_data.groups)
				end
			else
				new_pos.y = pos.y - 1
				dig_if_group(new_pos, player, dig_data.groups)
				new_pos.y = pos.y + 1
				dig_if_group(new_pos, player, dig_data.groups)
			end
		elseif current_mode == "wide" then
			if player_rotation.x ~= 0 then
				new_pos.z = pos.z - 1
				dig_if_group(new_pos, player, dig_data.groups)
				new_pos.z = pos.z + 1
				dig_if_group(new_pos, player, dig_data.groups)
			else
				new_pos.x = pos.x - 1
				dig_if_group(new_pos, player, dig_data.groups)
				new_pos.x = pos.x + 1
				dig_if_group(new_pos, player, dig_data.groups)
			end
		end
	end
		exchangeclone.multidig[playername] = nil
  end
)