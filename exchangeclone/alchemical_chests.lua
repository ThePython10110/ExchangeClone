local S = minetest.get_translator()

local colors = {
    red = "Red",
    orange = "Orange",
    yellow = "Yellow",
    green = "Lime",
    dark_green = "Green",
    cyan = "Cyan",
    light_blue = "Light Blue",
    blue = "Blue",
    purple = "Purple",
    magenta = "Magenta",
    pink = "Pink",
    black = "Black",
    white = "White",
    silver = exchangeclone.mcl and "Light Gray",
    grey = "Gray",
    brown = "Brown",
}

-- color is nil for regular alchemical chests (not advanced/bags)
local function alchemical_formspec(color)
    local listname, label
    local centered = exchangeclone.mcl and 2 or 2.5
    if color then
        local codified_color = string.lower(color):gsub(" ", "_")
        listname = "current_player;"..codified_color.."_alchemical_inventory"
        label = S("@1 Alchemical Inventory", S(color))
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
        meta:set_string("infotext", color.." Alchemical Chest")
    end
end

minetest.register_node("exchangeclone:alchemical_chest", {
    description = S("Alchemical Chest"),
    groups = {container = 2, alchemical_chest = 1, cracky = 2, pickaxey = 2},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        meta:set_string("formspec", alchemical_formspec())
        meta:set_string("infotext", S("Alchemical Chest"))
        inv:set_size("main", 104)
        inv:set_width("main", 13)
    end,
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
    for _, color in pairs(colors) do
        local codified_color = string.lower(color):gsub(" ", "_")
        inv:set_size(codified_color.."_alchemical_inventory", 104)
        inv:set_width(codified_color.."_alchemical_inventory", 13)
    end
end)

for dye_color, color in pairs(colors) do
    local codified_color = string.lower(color):gsub(" ", "_")
    local bag_itemstring = "exchangeclone:"..codified_color.."_alchemical_bag"
    local advanced_itemstring = "exchangeclone:"..codified_color.."_advanced_alchemical_chest"
    local wool_itemstring = (exchangeclone.mcl and "mcl_wool:" or "wool:")..dye_color
    local dye_itemstring = (exchangeclone.mcl and "mcl_dye:" or "dye:")..dye_color

    local function alchemical_bag_action(itemstack, player, pointed_thing)
        local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
        if click_test ~= false then
            return click_test
        end
        if pointed_thing.type == "node"
        and minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "advanced_alchemical_chest") > 0 then
            --minetest.log(advanced_itemstring)
            minetest.set_node(pointed_thing.under, {name=advanced_itemstring})
            local on_construct = alchemical_on_construct(color)
            on_construct(pointed_thing.under)
            return
        else
            minetest.show_formspec(player:get_player_name(), bag_itemstring, alchemical_formspec(color))
        end
    end

    minetest.register_tool(bag_itemstring, {
        description = S("@1 Alchemical Bag", S(color)),
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
        description = S("@1 Advanced Alchemical Chest", color).."\n"..S("Shift+right-click with an alchemical bag to change the color."),
        groups = {container = 2, advanced_alchemical_chest = 1},
        on_construct = alchemical_on_construct(color)
    })

    minetest.register_craft({
        output = advanced_itemstring,
        recipe = {
            {"exchangeclone:dark_matter", "exchangeclone:low_covalence_dust", "exchangeclone:dark_matter"},
            {"exchangeclone:medium_covalence_dust", "exchangeclone:"..codified_color.."_alchemical_bag", "exchangeclone:medium_covalence_dust"},
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