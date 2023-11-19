local S = minetest.get_translator()

function exchangeclone.mine_vein(player, start_pos, node_name, pos, depth)
    -- Not very efficient, but it works.
    if not player then return end
    if not start_pos then return end
    if not pos then pos = start_pos end
    depth = depth or 0
    --minetest.log(dump(pos))
    local node = minetest.get_node(pos)
    if not node_name then node_name = node.name end
    local distance = vector.distance(pos, start_pos)
    if node_name == node.name then
        exchangeclone.drop_items_on_player(pos, minetest.get_node_drops(node.name, "exchangeclone:red_matter_pickaxe"), player)
        minetest.set_node(pos, {name = "air"})
        for x = pos.x-1,pos.x+1 do for y = pos.y-1,pos.y+1 do for z = pos.z-1,pos.z+1 do
            if depth <= 10 then
                exchangeclone.mine_vein(player, start_pos, node_name, {x=x,y=y,z=z}, depth+1)
            end
        end end end
    end
    return 0
end

local torch_itemstring = "default:torch"
if exchangeclone.mcl then
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
	end

    if pointed_thing.type == "node" then
        if exchangeclone.check_cooldown(player, "pickaxe") then return itemstack end
        if (minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "exchangeclone_ore") > 0) then
            exchangeclone.play_ability_sound(player)
            exchangeclone.multidig[player:get_player_name()] = true
            exchangeclone.mine_vein(player, pointed_thing.under)
            exchangeclone.multidig[player:get_player_name()] = nil
        elseif itemstack:get_name():find("red") then
            local player_energy = exchangeclone.get_player_energy(player)
            torch_on_place(ItemStack(torch_itemstring), player, pointed_thing)
            exchangeclone.set_player_energy(player, player_energy - math.max(exchangeclone.get_item_energy(torch_itemstring) or 0, 8))
            -- If the torch could not be placed, it still costs energy... not sure how to fix that
        end
        exchangeclone.start_cooldown(player, "pickaxe", 0.3)
    end
end

for name, def in pairs(minetest.registered_nodes) do
    if name:find("_ore")
    or name:find("stone_with")
    or name:find("deepslate_with")
    or name:find("diorite_with")
    or name:find("andesite_with")
    or name:find("granite_with")
    or name:find("tuff_with")
    or name:find("mineral_")
    or (name == "mcl_blackstone:nether_gold")
    or (name == "mcl_nether:ancient_debris") then
        local groups = table.copy(def.groups)
        groups.exchangeclone_ore = 1
        minetest.override_item(name, {groups = groups})
    end
end

local pick_def = {
	description = S("Dark Matter Pickaxe").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_dark_matter_pickaxe.png",
	inventory_image = "exchangeclone_dark_matter_pickaxe.png",
    exchangeclone_pick_mode = "1x1",
	groups = { tool=1, pickaxe=1, dig_speed_class=7, enchantability=0, dark_matter_pickaxe=1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.5,
		max_drop_level=6,
		damage_groups = {fleshy=7},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times={[1]=0.4, [2]=0.2, [3]=0.1}, uses=0, maxlevel=4},
		},
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 40, level = 7, uses = 0 }
	},
    on_secondary_use = pickaxe_on_use,
    on_place = pickaxe_on_use,
}

minetest.register_tool("exchangeclone:dark_matter_pickaxe", table.copy(pick_def))

local pick_def_3x1 = table.copy(pick_def)
pick_def_3x1.description = S("Dark Matter Pickaxe").."\n"..S("3x1 mode")
pick_def_3x1.exchangeclone_pick_mode = "tall"
pick_def_3x1.groups.not_in_creative_inventory = 1
pick_def_3x1.tool_capabilities.groupcaps.cracky.times = {[1]=0.45, [2]=0.27, [3]=0.11}
pick_def_3x1._mcl_diggroups.pickaxey.speed = 35

minetest.register_tool("exchangeclone:dark_matter_pickaxe_3x1", table.copy(pick_def_3x1))

exchangeclone.register_energy_alias("exchangeclone:dark_matter_pickaxe", "exchangeclone:dark_matter_pickaxe_3x1")

pick_def.description = S("Red Matter Pickaxe").."\n"..S("Single node mode")
pick_def.wield_image = "exchangeclone_red_matter_pickaxe.png"
pick_def.inventory_image = "exchangeclone_red_matter_pickaxe.png"
pick_def.groups.dark_matter_pickaxe = nil
pick_def.groups.red_matter_pickaxe = 1
pick_def.groups.dig_speed_class = 8
pick_def.tool_capabilities = {
    full_punch_interval = 0.5,
    max_drop_level=7,
    damage_groups = {fleshy=9},
    punch_attack_uses = 0,
    groupcaps={
        cracky = {times={[1]=0.27, [2]=0.13, [3]=0.07}, uses=0, maxlevel=5},
    },
}
pick_def._mcl_diggroups.pickaxey = { speed = 60, level = 8, uses = 0 }

minetest.register_tool("exchangeclone:red_matter_pickaxe", table.copy(pick_def))

pick_def_3x1.description = S("Red Matter Pickaxe").."\n"..S("3x1 mode")
pick_def_3x1 = table.copy(pick_def)
pick_def_3x1.exchangeclone_pick_mode = "tall"
pick_def_3x1.groups.not_in_creative_inventory = 1
pick_def_3x1.tool_capabilities.groupcaps.cracky.times = {[1]=0.32, [2]=0.16, [3]=0.08}
pick_def_3x1._mcl_diggroups.pickaxey.speed = 52

minetest.register_tool("exchangeclone:red_matter_pickaxe_3x1", table.copy(pick_def_3x1))

exchangeclone.register_energy_alias("exchangeclone:red_matter_pickaxe", "exchangeclone:red_matter_pickaxe_3x1")

minetest.register_craft({
    output = "exchangeclone:dark_matter_pickaxe",
    recipe = {
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {"", exchangeclone.itemstrings.diamond, ""},
        {"", exchangeclone.itemstrings.diamond, ""}
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