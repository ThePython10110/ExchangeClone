core.register_craftitem("ec_random:iron_band", {
    description = "Iron Band",
    groups = {craftitem = 1},
    inventory_image = "exchangeclone_iron_band.png"
})

core.register_craft({
    output = "ec_random:iron_band",
    recipe = {
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
    },
    replacements = {{exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.empty_bucket}}
})

core.register_craft({
    output = "ec_random:iron_band",
    recipe = {
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, "ec_magic_items:volcanite_amulet", exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
    },
    replacements = {{"ec_magic_items:volcanite_amulet", "ec_magic_items:volcanite_amulet"}}
})