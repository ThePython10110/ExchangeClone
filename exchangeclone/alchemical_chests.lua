local S = minetest.get_translator()

-- color is nil for regular alchemical chests (not advanced/bags)
local function alchemical_formspec(color)
    local listname, label
    local centered = exchangeclone.mcl and 2 or 2.5
    if color then
        local codified_color = string.lower(color):gsub(" ", "_")
        listname = "current_player;"..codified_color.."_alchemical_inventory"
        label = S("@1 Alchemical Inventory", color)
    else
        listname = "context;main"
        label = S("Alchemical Chest")
    end
    local formspec =
        "size[14,13]"..
        "label[0.25,0.0;"..label.."]"..
        "list["..listname..";0,0.5;13,8]"..
        exchangeclone.inventory_formspec(centered, 9)..
        "listring[current_player;main]"..
        "listring["..listname.."]"
    if exchangeclone.mcl then
        formspec = formspec..mcl_formspec.get_itemslot_bg(0,0.5,13,8)
    end
    return formspec
end

local function alchemical_on_construct(color)
    return function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", alchemical_formspec(color))
        meta:set_string("infotext", color.." Advanced Alchemical Chest")
    end
end

local pipeworks_connect = exchangeclone.pipeworks and "^pipeworks_tube_connection_stony.png" or ""

minetest.register_node("exchangeclone:alchemical_chest", {
    description = S("Alchemical Chest"),
    groups = {container = 2, alchemical_chest = 1, cracky = 2, pickaxey = 2, tubedevice = 1, tubedevice_receiver = 1},
    _mcl_hardness = 10,
	_mcl_blast_resistance = 15,
    paramtype2 = "4dir",
	tiles = {
		"exchangeclone_alchemical_chest_top.png"..pipeworks_connect,
		"exchangeclone_alchemical_chest_bottom.png"..pipeworks_connect,
		"exchangeclone_alchemical_chest_side.png"..pipeworks_connect,
		"exchangeclone_alchemical_chest_side.png"..pipeworks_connect,
		"exchangeclone_alchemical_chest_side.png"..pipeworks_connect,
		"exchangeclone_alchemical_chest_front.png"..pipeworks_connect,
	},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        meta:set_string("formspec", alchemical_formspec())
        meta:set_string("infotext", S("Alchemical Chest"))
        inv:set_size("main", 104)
        inv:set_width("main", 13)
    end,
    tube = exchangeclone.pipeworks and {
        input_inventory = "main",
        connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1},
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local result = inv:add_item("main", stack)
            if result then
                local func = minetest.registered_items[node.name].on_metadata_inventory_put
                if func then func(pos) end
            end
            return result
        end
    },
    on_blast = exchangeclone.on_blast({"main"}),
    on_rotate = exchangeclone.pipeworks and pipeworks.on_rotate,
    after_place_node = exchangeclone.pipeworks and pipeworks.after_place,
    after_dig_node = exchangeclone.drop_after_dig({"main"}),
    can_dig = exchangeclone.can_dig,
})

local stone_itemstring = exchangeclone.mcl and "mcl_core:stone" or "default:stone"
local chest_itemstring = exchangeclone.mcl and "mcl_chests:chest" or "default:chest"

minetest.register_craft({
    output = "exchangeclone:alchemical_chest",
    recipe = {
        {"exchangeclone:low_covalence_dust", "exchangeclone:medium_covalence_dust", "exchangeclone:high_covalence_dust"},
        {stone_itemstring, exchangeclone.itemstrings.diamond, stone_itemstring},
        {exchangeclone.itemstrings.iron, chest_itemstring, exchangeclone.itemstrings.iron}
    }
})

minetest.register_on_joinplayer(function(player, last_login)
    local inv = player:get_inventory()
    for color, color_data in pairs(exchangeclone.colors) do
        inv:set_size(color.."_alchemical_inventory", 104)
        inv:set_width(color.."_alchemical_inventory", 13)
    end
end)

for color, color_data in pairs(exchangeclone.colors) do
    local bag_itemstring = "exchangeclone:alchemical_bag_"..color
    local advanced_itemstring = "exchangeclone:advanced_alchemical_chest_"..color
    local wool_itemstring = (exchangeclone.mcl and "mcl_wool:" or "wool:")..color
    local dye_itemstring = (exchangeclone.mcl and "mcl_dye:" or "dye:")..color

    local bag_modifier = "^[multiply:"..color_data.hex
    if color == "white" then bag_modifier = "" end
    if color == "black" then bag_modifier = "^[invert:rgb" end

    local function alchemical_bag_action(itemstack, player, pointed_thing)
        local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
        if click_test ~= false then
            return click_test
        end
        if pointed_thing.type == "node"
        and minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "advanced_alchemical_chest") > 0 then
            if minetest.is_protected(player) then
                minetest.record_protection_violation(player)
            else
                minetest.set_node(pointed_thing.under, {name=advanced_itemstring})
                local on_construct = alchemical_on_construct(color_data.name)
                on_construct(pointed_thing.under)
                return
            end
        else
            minetest.show_formspec(player:get_player_name(), bag_itemstring, alchemical_formspec(color_data.name))
        end
    end

    minetest.register_tool(bag_itemstring, {
        description = S("@1 Alchemical Bag", color_data.name),
        inventory_image = "exchangeclone_alchemical_bag.png"..bag_modifier,
        wield_image = "exchangeclone_alchemical_bag.png"..bag_modifier,
        groups = {disable_repair = 1, alchemical_bag = 1},
        on_secondary_use = alchemical_bag_action,
        on_place = alchemical_bag_action
    })

    minetest.register_craft({
        output = bag_itemstring,
        recipe = {
            {"exchangeclone:high_covalence_dust", "exchangeclone:high_covalence_dust", "exchangeclone:high_covalence_dust"},
            {wool_itemstring, "exchangeclone:alchemical_chest", wool_itemstring},
            {wool_itemstring, wool_itemstring, wool_itemstring},
        }
    })
    minetest.register_craft({
        output = bag_itemstring,
        type = "shapeless",
        recipe = {
            "group:alchemical_bag",
            dye_itemstring
        }
    })

    minetest.register_node(advanced_itemstring, {
        description = S("@1 Advanced Alchemical Chest", color_data.name).."\n"..S("Shift+right-click with an alchemical bag to change the color."),
        _mcl_hardness = 10,
        _mcl_blast_resistance = 15,
        groups = {container = 1, advanced_alchemical_chest = 1, cracky = 2, pickaxey = 2},
        paramtype2 = "4dir",
        tiles = {
            "exchangeclone_advanced_alchemical_chest_top.png",
            "exchangeclone_alchemical_chest_bottom.png",
            "exchangeclone_alchemical_chest_side.png",
            "exchangeclone_alchemical_chest_side.png",
            "exchangeclone_alchemical_chest_side.png",
            "exchangeclone_alchemical_chest_side.png^(exchangeclone_advanced_alchemical_chest_overlay.png^[multiply:"..color_data.hex..")",
        },
        on_construct = alchemical_on_construct(color_data.name)
    })

    minetest.register_craft({
        output = advanced_itemstring,
        recipe = {
            {"exchangeclone:dark_matter", "exchangeclone:low_covalence_dust", "exchangeclone:dark_matter"},
            {"exchangeclone:medium_covalence_dust", "exchangeclone:alchemical_bag_"..color, "exchangeclone:medium_covalence_dust"},
            {"exchangeclone:high_covalence_dust", "exchangeclone:low_covalence_dust", "exchangeclone:high_covalence_dust"},
        }
    })
    minetest.register_craft({
        output = advanced_itemstring,
        type = "shapeless",
        recipe = {
            "group:advanced_alchemical_chest",
            dye_itemstring
        }
    })
end