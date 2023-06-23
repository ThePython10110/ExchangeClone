local players_digging = {}

local function mine_vein(player, player_energy, start_pos, node_name, pos)
    -- Not very efficient, but it SHOULD work.
    if not player then return 0 end
    if not start_pos then return 0 end
    if not pos then pos = start_pos end
    local node = minetest.get_node(pos)
    if not node_name then node_name = node.name end
    local distance = vector.distance(pos, start_pos)
    if distance > 10 then return 0 end
    if player_energy < 8 then return 0 end
    if node_name == node.name then
        local energy_cost = 8
        exchangeclone.drop_items_on_player(pos, minetest.get_node_drops(node.name, "exchangeclone:red_matter_pickaxe"), player)
        minetest.set_node(pos, {name = "air"})
        for x = pos.x-1,pos.x+1 do for y = pos.y-1,pos.y+1 do for z = pos.z-1,pos.z+1 do
            local cost = mine_vein(player, player_energy, start_pos, node_name, {x=x,y=y,z=z})
            if cost and cost > 0 then
                energy_cost = energy_cost + cost
            end
        end end end
        return energy_cost
    end
    return 0
end

local torch_itemstring = "default:torch"
if exchangeclone.mineclone then
    torch_itemstring = "mcl_torches:torch"
end

local torch_on_place = minetest.registered_items[torch_itemstring].on_place

local function pickaxe_on_use(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

	if player:get_player_control().sneak then
		local current_name = itemstack:get_name()
        local meta = itemstack:get_meta()
        local current_mode = itemstack:get_meta():get_string("exchangeclone_pick_mode")
        if current_mode == "" or not current_mode then current_mode = "1x1" end
        if current_mode == "1x1" then
            itemstack:set_name(current_name.."_3x1") -- set to 3x1 pick
            meta:set_string("exchangeclone_pick_mode", "tall")
            minetest.chat_send_player(player:get_player_name(), "3x1 tall mode")
        elseif current_mode == "tall" then
            meta:set_string("exchangeclone_pick_mode", "wide")
            minetest.chat_send_player(player:get_player_name(), "3x1 wide mode")
        elseif current_mode == "wide" then
            meta:set_string("exchangeclone_pick_mode", "long")
            minetest.chat_send_player(player:get_player_name(), "3x1 long mode")
        elseif current_mode == "long" then
            itemstack:set_name(string.sub(current_name, 1, -5)) -- set to 1x1 pick
            meta:set_string("exchangeclone_pick_mode", "1x1")
            minetest.chat_send_player(player:get_player_name(), "Single block mode")
        end
		return itemstack
	end

    if pointed_thing.type == "node" then
        if (minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "exchangeclone_ore") > 0) then
            local player_energy = exchangeclone.get_player_energy(player)
            exchangeclone.play_ability_sound(player)
            players_digging[player:get_player_name()] = true
            local energy_cost = mine_vein(player, player_energy, pointed_thing.under)
            players_digging[player:get_player_name()] = nil
            if energy_cost then
                exchangeclone.set_player_energy(player, player_energy - energy_cost)
            end
        elseif itemstack:get_name():find("red") then
            local player_energy = exchangeclone.get_player_energy(player)
            torch_on_place(ItemStack(torch_itemstring), player, pointed_thing)
            exchangeclone.set_player_energy(player, player_energy - exchangeclone.get_item_energy(torch_itemstring))
            -- If the torch could not be placed, it still costs energy... not sure how to fix that
        end
    end
end

for name, def in pairs(minetest.registered_nodes) do
    if name:find("_ore") or name:find("stone_with") or name:find("deepslate_with")
    or name:find("diorite_with") or name:find("andesite_with") or name:find("granite_with")
    or name:find("tuff_with") then
        local groups = table.copy(def.groups)
        groups.exchangeclone_ore = 1
        minetest.override_item(name, {groups = groups})
    end
end

minetest.register_tool("exchangeclone:dark_matter_pickaxe", {
	description = "Dark Matter Pickaxe",
	wield_image = "exchangeclone_dark_matter_pickaxe.png",
	inventory_image = "exchangeclone_dark_matter_pickaxe.png",
    exchangeclone_pick_mode = "1x1",
	groups = { tool=1, pickaxe=1, dig_speed_class=7, enchantability=0, dark_matter_pickaxe=1 },
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
    on_secondary_use = pickaxe_on_use,
    on_place = pickaxe_on_use,
})

minetest.register_tool("exchangeclone:dark_matter_pickaxe_3x1", {
	description = "Dark Matter Pickaxe",
	wield_image = "exchangeclone_dark_matter_pickaxe.png",
	inventory_image = "exchangeclone_dark_matter_pickaxe.png",
    exchangeclone_pick_mode = "tall",
	groups = { tool=1, pickaxe=1, dig_speed_class=7, enchantability=0, dark_matter_pickaxe=1, not_in_creative_inventory=1 },
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
    on_secondary_use = pickaxe_on_use,
    on_place = pickaxe_on_use,
})

minetest.register_tool("exchangeclone:red_matter_pickaxe", {
	description = "Red Matter Pickaxe",
	wield_image = "exchangeclone_red_matter_pickaxe.png",
	inventory_image = "exchangeclone_red_matter_pickaxe.png",
    exchangeclone_pick_mode = "1x1",
	groups = { tool=1, pickaxe=1, dig_speed_class=7, red_matter_pickaxe=1, enchantability=0 },
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1, [2]=0.5, [3]=0.25}, uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 20, level = 8, uses = 0 }
	},
    on_secondary_use = pickaxe_on_use,
    on_place = pickaxe_on_use,
})

minetest.register_tool("exchangeclone:red_matter_pickaxe_3x1", {
	description = "Red Matter Pickaxe",
	wield_image = "exchangeclone_red_matter_pickaxe.png",
	inventory_image = "exchangeclone_red_matter_pickaxe.png",
    exchangeclone_pick_mode = "tall",
	groups = { tool=1, pickaxe=1, dig_speed_class=7, enchantability=0, red_matter_pickaxe=1, not_in_creative_inventory=1 },
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=1.2, [2]=0.7, [3]=0.4}, uses=0, maxlevel=5},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 20, level = 8, uses = 0 }
	},
    on_secondary_use = pickaxe_on_use,
    on_place = pickaxe_on_use,
})

-- adapted from https://github.com/cultom/hammermod/blob/master/init.lua

local stone_group = "cracky"
if exchangeclone.mineclone then
	stone_group = "pickaxey"
end

local function dig_if_stone(pos, player)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, stone_group) ~= 0 then
		minetest.node_dig(pos, minetest.get_node(pos), player)
	end
end

minetest.register_on_dignode(
  function(pos, oldnode, player)
    if player == nil or (player:get_wielded_item():get_name() ~= "exchangeclone:dark_matter_pickaxe_3x1"
		and player:get_wielded_item():get_name() ~= "exchangeclone:red_matter_pickaxe_3x1") then
      return
    end
    local playerName = player:get_player_name()
    if (playerName == ""  or players_digging[playerName]) then
      return
    end
    players_digging[playerName] = true

    local current_mode = player:get_wielded_item():get_meta():get_string("exchangeclone_pick_mode")
    if current_mode == "" or not current_mode then current_mode = "tall" end

    local player_rotation = exchangeclone.get_face_direction(player)

    local new_pos = table.copy(pos)

    if current_mode == "long" then
        if player_rotation.y ~= 0 then
            new_pos.y = new_pos.y + player_rotation.y
            dig_if_stone(new_pos, player)
            new_pos.y = new_pos.y + player_rotation.y
            dig_if_stone(new_pos, player)
        elseif player_rotation.z ~= 0 then
            new_pos.z = new_pos.z + player_rotation.z
            dig_if_stone(new_pos, player)
            new_pos.z = new_pos.z + player_rotation.z
            dig_if_stone(new_pos, player)
        else
            new_pos.x = new_pos.x + player_rotation.x
            dig_if_stone(new_pos, player)
            new_pos.x = new_pos.x + player_rotation.x
            dig_if_stone(new_pos, player)
        end
    elseif current_mode == "tall" then
        if player_rotation.y ~= 0 then
            if player_rotation.x ~= 0 then
                new_pos.x = pos.x - 1
                dig_if_stone(new_pos, player)
                new_pos.x = pos.x + 1
                dig_if_stone(new_pos, player)
            else
                new_pos.z = pos.z - 1
                dig_if_stone(new_pos, player)
                new_pos.z = pos.z + 1
                dig_if_stone(new_pos, player)
            end
        else
            new_pos.y = pos.y - 1
            dig_if_stone(new_pos, player)
            new_pos.y = pos.y + 1
            dig_if_stone(new_pos, player)
        end
    elseif current_mode == "wide" then
        if player_rotation.x ~= 0 then
            new_pos.z = pos.z - 1
            dig_if_stone(new_pos, player)
            new_pos.z = pos.z + 1
            dig_if_stone(new_pos, player)
        else
            new_pos.x = pos.x - 1
            dig_if_stone(new_pos, player)
            new_pos.x = pos.x + 1
            dig_if_stone(new_pos, player)
        end
    end

    players_digging[playerName] = nil
  end
)

-- end copied code

minetest.register_craft({
    output = "exchangeclone:dark_matter_pickaxe",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {"", exchangeclone.diamond_itemstring, ""},
        {"", exchangeclone.diamond_itemstring, ""}
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_pickaxe",
    recipe = {
        {"exchangeclone:red_matter", "exchangeclone:red_matter", "exchangeclone:red_matter"},
        {"", "group:dark_matter_pickaxe", ""},
        {"", "exchangeclone:dark_matter", ""}
    }
})