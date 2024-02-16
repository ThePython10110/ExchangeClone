local S = minetest.get_translator()

function exchangeclone.mine_vein(player, start_pos, node_name, pos, depth, visited)
    if not player or not start_pos then
        return
    end

    pos = pos or start_pos
    depth = depth or 0
    visited = visited or {}

    local pos_str = minetest.pos_to_string(pos)
    if visited[pos_str] then
        return
    end
    visited[pos_str] = true

    local node = minetest.get_node(pos)
    if not node_name then
        node_name = node.name
    end

    if node_name == node.name then
        local drops = minetest.get_node_drops(node.name, "exchangeclone:red_matter_pickaxe")
        exchangeclone.drop_items_on_player(pos, drops, player)
        exchangeclone.check_nearby_falling(pos)
        minetest.set_node(pos, {name = "air"})

        if depth < 10 then
            for _, neighbor_pos in ipairs(minetest.find_nodes_in_area(
                {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
                {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
                node_name)) do
                exchangeclone.mine_vein(player, start_pos, node_name, neighbor_pos, depth + 1, visited)
            end
        end
    end
end

local function pickaxe_on_use(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
		return exchangeclone.charge_update(itemstack, player)
    elseif player:get_player_control().sneak then
        local meta = itemstack:get_meta()
        local current_mode = itemstack:get_meta():get_string("exchangeclone_multidig_mode") or "1x1"
        if current_mode == "1x1" then
            meta:set_string("exchangeclone_multidig_mode", "3x1_tall")
            minetest.chat_send_player(player:get_player_name(), S("3x1 tall mode"))
        elseif current_mode == "tall" then
            meta:set_string("exchangeclone_multidig_mode", "3x1_wide")
            minetest.chat_send_player(player:get_player_name(), S("3x1 wide mode"))
        elseif current_mode == "wide" then
            meta:set_string("exchangeclone_multidig_mode", "3x1_long")
            minetest.chat_send_player(player:get_player_name(), S("3x1 long mode"))
        else
            meta:set_string("exchangeclone_multidig_mode", "1x1")
            minetest.chat_send_player(player:get_player_name(), S("Single node mode"))
        end
		return itemstack
	elseif pointed_thing.type == "node" then
        if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "exchangeclone_ore") > 0 then
            if exchangeclone.check_cooldown(player, "pickaxe") then return itemstack end
            exchangeclone.play_sound(player, "exchangeclone_destruct")
            exchangeclone.mine_vein(player, pointed_thing.under)
            exchangeclone.start_cooldown(player, "pickaxe", 0.5)
        elseif itemstack:get_name():find("red_") then
            exchangeclone.place_torch(player, pointed_thing)
            exchangeclone.add_player_emc(player, -math.max(exchangeclone.get_item_emc(exchangeclone.itemstrings.torch) or 0, 8))
            -- If the torch could not be placed, it still costs EMC... not sure how to fix that
        end
    end
end

minetest.register_tool("exchangeclone:dark_matter_pickaxe", {
	description = S("Dark Matter Pickaxe").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_dark_matter_pickaxe.png",
	inventory_image = "exchangeclone_dark_matter_pickaxe.png",
	groups = { tool=1, pickaxe=1, dig_speed_class=5, enchantability=0, dark_matter_pickaxe=1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = exchangeclone.mtg and {
		full_punch_interval = 1/1.2,
		max_drop_level=6,
		damage_groups = {fleshy=8},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times = exchangeclone.get_mtg_times(14, nil, "cracky"), uses=0, maxlevel=4},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 14, level = 5, uses = 0 }
	},
    on_secondary_use = pickaxe_on_use,
    on_place = pickaxe_on_use,
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.register_multidig_tool("exchangeclone:dark_matter_pickaxe", {"group:"..exchangeclone.pickaxe_group})
minetest.register_alias("exchangeclone:dark_matter_pickaxe_3x1", "exchangeclone:dark_matter_pickaxe")
exchangeclone.set_charge_type("exchangeclone:dark_matter_pickaxe", "dark_matter")

minetest.register_tool("exchangeclone:red_matter_pickaxe", {
	description = S("Red Matter Pickaxe").."\n"..S("Single node mode"),
	wield_image = "exchangeclone_red_matter_pickaxe.png",
	inventory_image = "exchangeclone_red_matter_pickaxe.png",
	groups = { tool=1, pickaxe=1, dig_speed_class=5, enchantability=0, red_matter_pickaxe=1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
	wield_scale = exchangeclone.wield_scale,
	tool_capabilities = exchangeclone.mtg and {
		full_punch_interval = 1/1.2,
		max_drop_level=7,
		damage_groups = {fleshy=9},
		punch_attack_uses = 0,
		groupcaps={
			cracky = {times = exchangeclone.get_mtg_times(16, nil, "cracky"), uses=0, maxlevel=5},
		},
	},
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 16, level = 6, uses = 0 }
	},
    on_secondary_use = pickaxe_on_use,
    on_place = pickaxe_on_use,
	wear_represents = "exchangeclone_charge_level"
})

exchangeclone.register_multidig_tool("exchangeclone:red_matter_pickaxe", {"group:"..exchangeclone.pickaxe_group})
minetest.register_alias("exchangeclone:red_matter_pickaxe_3x1", "exchangeclone:red_matter_pickaxe")
exchangeclone.set_charge_type("exchangeclone:red_matter_pickaxe", "red_matter")

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


-- Can't find a good way to automate this...
minetest.register_on_mods_loaded(function()
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
end)