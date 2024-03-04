local width = (exchangeclone.mcl and 9) or 8

local upgrader_formspec =
    "size["..tostring(width)..", 7]"..
    "label[0.5,0.5;Upgrader]"..
    "label["..tostring(width/3-0.5)..",0.5;Upgrade]"..
    "list[context;fuel;"..tostring(width/3-0.5)..",1;1,1]"..
    "label["..tostring(width/2-0.5)..",0.5;Gear]"..
    "list[context;src;"..tostring(width/2-0.5)..",1;1,1]"..
    "label["..tostring(2*width/3-0.5)..",0.5;Output]"..
    "list[context;dst;"..tostring(2*width/3-0.5)..",1;1,1]"..
    exchangeclone.inventory_formspec(0,2.75)..
    "listring[current_player;main]"..
    "listring[context;src]"..
    "listring[current_player;main]"..
    "listring[context;fuel]"..
    "listring[current_player;main]"..
    "listring[context;dst]"..
    "listring[current_player;main]"

if exchangeclone.mcl then
    upgrader_formspec = upgrader_formspec..
        mcl_formspec.get_itemslot_bg(width/3-0.5,1,1,1)..
        mcl_formspec.get_itemslot_bg(width/2-0.5,1,1,1)..
        mcl_formspec.get_itemslot_bg(2*width/3-0.5,1,1,1)
end

function exchangeclone.enchant(itemstack, enchantment, level)
	local enchantments = mcl_enchanting.get_enchantments(itemstack) or {}
    if enchantments[enchantment] and enchantments[enchantment] == level then return false end
	enchantments[enchantment] = level
	mcl_enchanting.set_enchantments(itemstack, enchantments)
	return itemstack
end

function exchangeclone.register_upgrade(itemstring, name, modifier, recipe, enchantment, level, upgradable_items)
    minetest.register_craftitem(itemstring, {
        description = name,
        wield_image = "exchangeclone_upgrade.png"..modifier,
        inventory_image = "exchangeclone_upgrade.png"..modifier,
        groups = {exchangeclone_upgrade = 1},
        enchantment = enchantment,
        level = level,
        upgradable_items = upgradable_items
    })
    minetest.register_craft({
        output = itemstring,
        recipe = recipe,
    })
end

local function upgrader_action(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local upgrade = inv:get_stack("fuel", 1)
    local tool = inv:get_stack("src", 1)
    local dst = inv:get_stack("dst", 1)
    if (not dst:is_empty())
    or upgrade:is_empty()
    or tool:is_empty() then
        return
    end
    local upgrade_def = upgrade:get_definition()
    if not upgrade_def.upgradable_items[tool:get_name()] then
        local found = false
        for item, _ in pairs(upgrade_def.upgradable_items) do
            if item:sub(1,6) == "group:" and (minetest.get_item_group(tool:get_name(), item:sub(7,-1)) > 0) then
                found = true
                break
            end
        end
        if not found then return end
    end

    local new_tool = exchangeclone.enchant(tool, upgrade_def.enchantment, upgrade_def.level)
    if not new_tool then return end -- If the tool already has that enchantment

    local new_emc = new_tool:_get_emc() + exchangeclone.get_item_emc(upgrade:get_name())

    new_tool:get_meta():set_string("exchangeclone_emc_value", new_emc)

    inv:set_stack("dst", 1, new_tool)

    tool:set_count(tool:get_count() - 1)
    if tool:get_count() == 0 then tool = ItemStack("") end
    inv:set_stack("src", 1, tool)

    upgrade:set_count(upgrade:get_count() - 1)
    if upgrade:get_count() == 0 then upgrade = ItemStack("") end
    inv:set_stack("fuel", 1, upgrade)
end


local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if player and player.get_player_name and minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    if listname == "fuel" then
        if minetest.get_item_group(stack:get_name(), "exchangeclone_upgrade") > 0 then
            return stack:get_count()
        else
            return 0
        end
    elseif listname == "src" then
        if minetest.get_item_group(stack:get_name(), "exchangeclone_upgradable") > 0 then
            return stack:get_count()
        else
            return 0
        end
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
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    return stack:get_count()
end

minetest.register_node("exchangeclone:upgrader", {
    description = "Upgrader",
    tiles = {
        "exchangeclone_upgrader_top.png",
        "exchangeclone_upgrader_bottom.png",
        "exchangeclone_upgrader_side.png",
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("fuel", 1)
        inv:set_size("src", 1)
        inv:set_size("dst", 1)
        meta:set_string("infotext", "Upgrader")
        meta:set_string("formspec", upgrader_formspec)
    end,
	groups = {pickaxey=5, material_stone=1, cracky = 3, container = exchangeclone.mcl2 and 2 or 4, level = exchangeclone.mtg and 4 or 0, tubedevice = 1, tubedevice_receiver = 1},
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    on_metadata_inventory_move = upgrader_action,
    on_metadata_inventory_take = upgrader_action,
    on_metadata_inventory_put = upgrader_action,
    on_blast = exchangeclone.on_blast({"src", "fuel", "dst"}),
    after_dig_node = exchangeclone.drop_after_dig({"src", "fuel", "dst"}),
    can_dig = exchangeclone.can_dig,
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 75,
	_mcl_hoppers_on_try_pull = exchangeclone.mcl2_hoppers_on_try_pull(),
	_mcl_hoppers_on_try_push = exchangeclone.mcl2_hoppers_on_try_push(
        function(stack) return minetest.get_item_group(stack:get_name(), "exchangeclone_upgradable") > 0 end,
        function(stack) return minetest.get_item_group(stack:get_name(), "exchangeclone_upgrade") > 0 end,
        upgrader_action
    ),
	_mcl_hoppers_on_after_push = upgrader_action,
    _mcl_hoppers_on_after_pull = upgrader_action,
    after_place_node = exchangeclone.pipeworks and pipeworks.after_place,
	_on_hopper_in = exchangeclone.mcla_on_hopper_in(
        function(stack) return minetest.get_item_group(stack:get_name(), "exchangeclone_upgradable") > 0 end,
        function(stack) return minetest.get_item_group(stack:get_name(), "exchangeclone_upgrade") > 0 end,
        upgrader_action
    ),
})

if exchangeclone.pipeworks then
	local function get_list(direction)
		return (direction.y == 0 and "src") or "fuel"
	end
    minetest.override_item("exchangeclone:upgrader", {tube = {
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
    },
    on_rotate = pipeworks.on_rotate,})
end

minetest.register_craft({
    output = "exchangeclone:upgrader",
    recipe = {
        {"exchangeclone:dark_matter_block", "mcl_deepslate:tuff", "exchangeclone:dark_matter_block"}, -- Tuff has to be useful SOMEHOW...
        {"mcl_deepslate:tuff", "exchangeclone:philosophers_stone", "mcl_deepslate:tuff"},
        {"exchangeclone:red_matter_block", "mcl_deepslate:tuff", "exchangeclone:red_matter_block"}
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})


minetest.register_craftitem("exchangeclone:blank_upgrade", {
    description = "Blank Upgrade",
    wield_image = "exchangeclone_upgrade.png",
    inventory_image = "exchangeclone_upgrade.png",
})

minetest.register_craft({
    output = "exchangeclone:blank_upgrade",
    recipe = {
        {"mcl_copper:copper_ingot", "mcl_deepslate:tuff", "mcl_copper:copper_ingot"}, -- Copper and tuff because they're useless.
        {"mcl_deepslate:tuff", "exchangeclone:philosophers_stone", "mcl_deepslate:tuff"},
        {"mcl_copper:copper_ingot", "mcl_deepslate:tuff", "mcl_copper:copper_ingot"}
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

exchangeclone.register_upgrade(
    "exchangeclone:fire_aspect_1_upgrade",
    "Fire Aspect I Upgrade",
    "^[multiply:#ff0000",
    {
        {"exchangeclone:dark_matter", "mcl_nether:magma", "exchangeclone:dark_matter"},
        {"mcl_nether:magma", "exchangeclone:blank_upgrade", "mcl_nether:magma"},
        {"exchangeclone:dark_matter", "mcl_nether:magma", "exchangeclone:dark_matter"},
    },
    "fire_aspect",
    1,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:red_katar"] = true,
        ["exchangeclone:red_katar_3x3"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:fire_aspect_2_upgrade",
    "Fire Aspect II Upgrade",
    "^[multiply:#ffaa00",
    {
        {"exchangeclone:dark_matter", "mcl_nether:magma", "exchangeclone:dark_matter"},
        {"mcl_nether:magma", "exchangeclone:fire_aspect_1_upgrade", "mcl_nether:magma"},
        {"exchangeclone:dark_matter", "mcl_nether:magma", "exchangeclone:dark_matter"},
    },
    "fire_aspect",
    2,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:red_katar"] = true,
        ["exchangeclone:red_katar_3x3"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:knockback_1_upgrade",
    "Knockback I Upgrade",
    "^[multiply:#777777",
    {
        {"exchangeclone:dark_matter", "mcl_core:slimeblock", "exchangeclone:dark_matter"},
        {"mcl_core:slimeblock", "exchangeclone:blank_upgrade", "mcl_core:slimeblock"},
        {"exchangeclone:dark_matter", "mcl_core:slimeblock", "exchangeclone:dark_matter"},
    },
    "knockback",
    1,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:red_katar"] = true,
        ["exchangeclone:red_katar_3x3"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:knockback_2_upgrade",
    "Knockback II Upgrade",
    "^[multiply:#aaaaaa",
    {
        {"exchangeclone:dark_matter", "mcl_core:slimeblock", "exchangeclone:dark_matter"},
        {"mcl_core:slimeblock", "exchangeclone:knockback_1_upgrade", "mcl_core:slimeblock"},
        {"exchangeclone:dark_matter", "mcl_core:slimeblock", "exchangeclone:dark_matter"},
    },
    "knockback",
    2,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:red_katar"] = true,
        ["exchangeclone:red_katar_3x3"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:looting_1_upgrade",
    "Looting I Upgrade",
    "^[multiply:#33aa00",
    {
        {"exchangeclone:dark_matter", "mcl_mobitems:blaze_rod", "exchangeclone:dark_matter"},
        {"mcl_mobitems:blaze_rod", "exchangeclone:blank_upgrade", "mcl_mobitems:blaze_rod"},
        {"exchangeclone:dark_matter", "mcl_mobitems:blaze_rod", "exchangeclone:dark_matter"},
    },
    "looting",
    1,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:red_katar"] = true,
        ["exchangeclone:red_katar_3x3"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:looting_2_upgrade",
    "Looting II Upgrade",
    "^[multiply:#77ff00",
    {
        {"exchangeclone:dark_matter", "mcl_mobitems:blaze_rod", "exchangeclone:dark_matter"},
        {"mcl_mobitems:blaze_rod", "exchangeclone:looting_1_upgrade", "mcl_mobitems:blaze_rod"},
        {"exchangeclone:dark_matter", "mcl_mobitems:blaze_rod", "exchangeclone:dark_matter"},
    },
    "looting",
    2,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:red_katar"] = true,
        ["exchangeclone:red_katar_3x3"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:looting_3_upgrade",
    "Looting III Upgrade",
    "^[multiply:#ffff00",
    {
        {"exchangeclone:dark_matter", "mcl_mobitems:blaze_rod", "exchangeclone:dark_matter"},
        {"mcl_mobitems:blaze_rod", "exchangeclone:looting_2_upgrade", "mcl_mobitems:blaze_rod"},
        {"exchangeclone:dark_matter", "mcl_mobitems:blaze_rod", "exchangeclone:dark_matter"},
    },
    "looting",
    3,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:red_katar"] = true,
        ["exchangeclone:red_katar_3x3"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:thorns_1_upgrade",
    "Thorns I Upgrade",
    "^[multiply:#773300",
    {
        {"exchangeclone:dark_matter", "mcl_core:cactus", "exchangeclone:dark_matter"},
        {"mcl_core:cactus", "exchangeclone:blank_upgrade", "mcl_core:cactus"},
        {"exchangeclone:dark_matter", "mcl_core:cactus", "exchangeclone:dark_matter"},
    },
    "thorns",
    1,
    {
        ["group:dark_matter_armor"] = true,
        ["group:red_matter_armor"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:thorns_2_upgrade",
    "Thorns II Upgrade",
    "^[multiply:#441100",
    {
        {"exchangeclone:dark_matter", "mcl_core:cactus", "exchangeclone:dark_matter"},
        {"mcl_core:cactus", "exchangeclone:thorns_1_upgrade", "mcl_core:cactus"},
        {"exchangeclone:dark_matter", "mcl_core:cactus", "exchangeclone:dark_matter"},
    },
    "thorns",
    2,
    {
        ["group:dark_matter_armor"] = true,
        ["group:red_matter_armor"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:thorns_3_upgrade",
    "Thorns III Upgrade",
    "^[multiply:#220500",
    {
        {"exchangeclone:dark_matter", "mcl_core:cactus", "exchangeclone:dark_matter"},
        {"mcl_core:cactus", "exchangeclone:thorns_2_upgrade", "mcl_core:cactus"},
        {"exchangeclone:dark_matter", "mcl_core:cactus", "exchangeclone:dark_matter"},
    },
    "thorns",
    3,
    {
        ["group:dark_matter_armor"] = true,
        ["group:red_matter_armor"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:frost_walker_1_upgrade",
    "Frost Walker I Upgrade",
    "^[multiply:#77aaff",
    {
        {"exchangeclone:dark_matter", "mcl_core:packed_ice", "exchangeclone:dark_matter"},
        {"mcl_core:packed_ice", "exchangeclone:blank_upgrade", "mcl_core:packed_ice"},
        {"exchangeclone:dark_matter", "mcl_core:packed_ice", "exchangeclone:dark_matter"},
    },
    "frost_walker",
    1,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:frost_walker_2_upgrade",
    "Frost Walker II Upgrade",
    "^[multiply:#77ffff",
    {
        {"exchangeclone:dark_matter", "mcl_core:packed_ice", "exchangeclone:dark_matter"},
        {"mcl_core:packed_ice", "exchangeclone:frost_walker_1_upgrade", "mcl_core:packed_ice"},
        {"exchangeclone:dark_matter", "mcl_core:packed_ice", "exchangeclone:dark_matter"},
    },
    "frost_walker",
    2,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:depth_strider_1_upgrade",
    "Depth Strider I Upgrade",
    "^[multiply:#000066",
    {
        {"exchangeclone:dark_matter", "mcl_fishing:salmon_raw", "exchangeclone:dark_matter"},
        {"mcl_fishing:salmon_raw", "exchangeclone:blank_upgrade", "mcl_fishing:salmon_raw"},
        {"exchangeclone:dark_matter", "mcl_fishing:salmon_raw", "exchangeclone:dark_matter"},
    },
    "depth_strider",
    1,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:depth_strider_2_upgrade",
    "Depth Strider II Upgrade",
    "^[multiply:#0000aa",
    {
        {"exchangeclone:dark_matter", "mcl_fishing:salmon_raw", "exchangeclone:dark_matter"},
        {"mcl_fishing:salmon_raw", "exchangeclone:depth_strider_1_upgrade", "mcl_fishing:salmon_raw"},
        {"exchangeclone:dark_matter", "mcl_fishing:salmon_raw", "exchangeclone:dark_matter"},
    },
    "depth_strider",
    2,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:depth_strider_3_upgrade",
    "Depth Strider III Upgrade",
    "^[multiply:#0000ff",
    {
        {"exchangeclone:dark_matter", "mcl_fishing:salmon_raw", "exchangeclone:dark_matter"},
        {"mcl_fishing:salmon_raw", "exchangeclone:depth_strider_2_upgrade", "mcl_fishing:salmon_raw"},
        {"exchangeclone:dark_matter", "mcl_fishing:salmon_raw", "exchangeclone:dark_matter"},
    },
    "depth_strider",
    3,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:soul_speed_1_upgrade",
    "Soul Speed I Upgrade",
    "^[brighten^[invert:rgb^[brighten^[multiply:#181400",
    {
        {"exchangeclone:dark_matter", "mcl_blackstone:soul_soil", "exchangeclone:dark_matter"},
        {"mcl_blackstone:soul_soil", "exchangeclone:blank_upgrade", "mcl_blackstone:soul_soil"},
        {"exchangeclone:dark_matter", "mcl_blackstone:soul_soil", "exchangeclone:dark_matter"},
    },
    "soul_speed",
    1,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:soul_speed_2_upgrade",
    "Soul Speed II Upgrade",
    "^[brighten^[invert:rgb^[brighten^[multiply:#2c2000",
    {
        {"exchangeclone:dark_matter", "mcl_blackstone:soul_soil", "exchangeclone:dark_matter"},
        {"mcl_blackstone:soul_soil", "exchangeclone:soul_speed_1_upgrade", "mcl_blackstone:soul_soil"},
        {"exchangeclone:dark_matter", "mcl_blackstone:soul_soil", "exchangeclone:dark_matter"},
    },
    "soul_speed",
    2,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:soul_speed_3_upgrade",
    "Soul Speed III Upgrade",
    "^[brighten^[invert:rgb^[brighten^[multiply:#352700",
    {
        {"exchangeclone:dark_matter", "mcl_blackstone:soul_soil", "exchangeclone:dark_matter"},
        {"mcl_blackstone:soul_soil", "exchangeclone:soul_speed_2_upgrade", "mcl_blackstone:soul_soil"},
        {"exchangeclone:dark_matter", "mcl_blackstone:soul_soil", "exchangeclone:dark_matter"},
    },
    "soul_speed",
    3,
    {
        ["exchangeclone:boots_dark_matter"] = true,
        ["exchangeclone:boots_red_matter"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:silk_touch_upgrade",
    "Silk Touch Upgrade",
    "^[brighten",
    {
        {"exchangeclone:dark_matter", "mcl_core:cobweb", "exchangeclone:dark_matter"},
        {"mcl_core:cobweb", "exchangeclone:blank_upgrade", "mcl_core:cobweb"},
        {"exchangeclone:dark_matter", "mcl_core:cobweb", "exchangeclone:dark_matter"},
    },
    "silk_touch",
    1,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:dark_matter_shovel"] = true,
        ["exchangeclone:red_matter_shovel"] = true,
        ["exchangeclone:dark_matter_shears"] = true,
        ["exchangeclone:red_matter_shears"] = true,
        ["group:dark_matter_pickaxe"] = true,
        ["group:red_matter_pickaxe"] = true,
        ["group:dark_matter_hoe"] = true,
        ["group:red_matter_hoe"] = true,
        ["group:dark_matter_hammer"] = true,
        ["group:red_matter_hammer"] = true,
        ["group:red_katar"] = true,
        ["group:red_morningstar"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:fortune_1_upgrade",
    "Fortune I Upgrade",
    "^[multiply:#ff00ff",
    {
        {"exchangeclone:dark_matter", "mcl_core:diamond", "exchangeclone:dark_matter"},
        {"mcl_core:diamond", "exchangeclone:blank_upgrade", "mcl_core:diamond"},
        {"exchangeclone:dark_matter", "mcl_core:diamond", "exchangeclone:dark_matter"},
    },
    "fortune",
    1,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:dark_matter_shovel"] = true,
        ["exchangeclone:red_matter_shovel"] = true,
        ["exchangeclone:dark_matter_shears"] = true,
        ["exchangeclone:red_matter_shears"] = true,
        ["group:dark_matter_pickaxe"] = true,
        ["group:red_matter_pickaxe"] = true,
        ["group:dark_matter_hoe"] = true,
        ["group:red_matter_hoe"] = true,
        ["group:dark_matter_hammer"] = true,
        ["group:red_matter_hammer"] = true,
        ["group:red_katar"] = true,
        ["group:red_morningstar"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:fortune_2_upgrade",
    "Fortune II Upgrade",
    "^[multiply:#aa00ff",
    {
        {"exchangeclone:dark_matter", "mcl_core:diamond", "exchangeclone:dark_matter"},
        {"mcl_core:diamond", "exchangeclone:fortune_1_upgrade", "mcl_core:diamond"},
        {"exchangeclone:dark_matter", "mcl_core:diamond", "exchangeclone:dark_matter"},
    },
    "fortune",
    2,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:dark_matter_shovel"] = true,
        ["exchangeclone:red_matter_shovel"] = true,
        ["exchangeclone:dark_matter_shears"] = true,
        ["exchangeclone:red_matter_shears"] = true,
        ["group:dark_matter_pickaxe"] = true,
        ["group:red_matter_pickaxe"] = true,
        ["group:dark_matter_hoe"] = true,
        ["group:red_matter_hoe"] = true,
        ["group:dark_matter_hammer"] = true,
        ["group:red_matter_hammer"] = true,
        ["group:red_katar"] = true,
        ["group:red_morningstar"] = true,
    }
)

exchangeclone.register_upgrade(
    "exchangeclone:fortune_3_upgrade",
    "Fortune III Upgrade",
    "^[multiply:#7700ff",
    {
        {"exchangeclone:dark_matter", "mcl_core:diamond", "exchangeclone:dark_matter"},
        {"mcl_core:diamond", "exchangeclone:fortune_2_upgrade", "mcl_core:diamond"},
        {"exchangeclone:dark_matter", "mcl_core:diamond", "exchangeclone:dark_matter"},
    },
    "fortune",
    3,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:dark_matter_shovel"] = true,
        ["exchangeclone:red_matter_shovel"] = true,
        ["exchangeclone:dark_matter_shears"] = true,
        ["exchangeclone:red_matter_shears"] = true,
        ["group:dark_matter_pickaxe"] = true,
        ["group:red_matter_pickaxe"] = true,
        ["group:dark_matter_hoe"] = true,
        ["group:red_matter_hoe"] = true,
        ["group:dark_matter_hammer"] = true,
        ["group:red_matter_hammer"] = true,
        ["group:red_katar"] = true,
        ["group:red_morningstar"] = true,
    }
)

-- Intentionally NOT making a Curse of Binding upgrade (because if Keep Inventory is enabled, they will never break)

exchangeclone.register_upgrade(
    "exchangeclone:curse_of_vanishing_upgrade",
    "Curse of Vanishing \"Upgrade\"",
    "^[invert:rgb",
    {
        {"exchangeclone:dark_matter", "xpanes:pane_silver_flat", "exchangeclone:dark_matter"},
        {"xpanes:pane_silver_flat", "exchangeclone:blank_upgrade", "xpanes:pane_silver_flat"},
        {"exchangeclone:dark_matter", "xpanes:pane_silver_flat", "exchangeclone:dark_matter"},
    },
    "curse_of_vanishing",
    1,
    {
        ["exchangeclone:dark_matter_sword"] = true,
        ["exchangeclone:red_matter_sword"] = true,
        ["exchangeclone:dark_matter_axe"] = true,
        ["exchangeclone:red_matter_axe"] = true,
        ["exchangeclone:dark_matter_shovel"] = true,
        ["exchangeclone:red_matter_shovel"] = true,
        ["exchangeclone:dark_matter_shears"] = true,
        ["exchangeclone:red_matter_shears"] = true,
        ["group:dark_matter_pickaxe"] = true,
        ["group:red_matter_pickaxe"] = true,
        ["group:dark_matter_hoe"] = true,
        ["group:red_matter_hoe"] = true,
        ["group:dark_matter_hammer"] = true,
        ["group:red_matter_hammer"] = true,
        ["group:red_katar"] = true,
        ["group:red_morningstar"] = true,
        ["group:dark_matter_armor"] = true,
        ["group:red_matter_armor"] = true,
    }
)