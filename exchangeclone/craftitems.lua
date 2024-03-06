minetest.register_craftitem("exchangeclone:iron_band", {
    description = "Iron Band", -- I could easily make it "Steel Band" in MTG but I don't care.
    groups = {craftitem = 1},
    inventory_image = "exchangeclone_iron_band.png"
})

minetest.register_craft({
    output = "exchangeclone:iron_band",
    recipe = {
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
    },
    replacements = {{exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.empty_bucket}}
})

minetest.register_craft({
    output = "exchangeclone:iron_band",
    recipe = {
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, "exchangeclone:volcanite_amulet", exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
    },
    replacements = {{"exchangeclone:volcanite_amulet", "exchangeclone:volcanite_amulet"}}
})