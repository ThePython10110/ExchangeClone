local function alchemical_formspec(color)
end

local colors = {
    "Red",
    "Orange",
    "Yellow",
    "Green",
    "Cyan",
    "Blue",
    "Magenta",
    ""
}

for _, color in colors do
    local lower_color = string.lower(color)
    local itemstring = "exchangeclone:"..lower_color.."_advanced_alchemical_chest"
    minetest.register_node(itemstring, {
        description = color.." Alchemical Chest",
        groups = {container = 2, alchemical_chest = 1},
        after_place_node = function(pos, player, itemstack, pointed_thing)
            local meta = minetest.get_meta(pos)
            meta:set_string("formspec", alchemical_formspec(color))
            meta:set_string("infotext", color.." Alchemical Chest")
        end,
    })
    local wool_itemstring = (exchangeclone.mcl and "mcl_wool:" or "wool:")..lower_color
    minetest.register_craft({
        output = itemstring,
        recipe = {
            {"exchangeclone:low_covalence_dust", "exchangeclone:medium_covalence_dust", "exchangeclone:high_covalence_dust"},

        }
    })
end