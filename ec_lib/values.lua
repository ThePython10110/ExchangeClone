-- The default width of inventory formspecs
exchangeclone.inv_width = exchangeclone.mtg and 8 or 9

-- Lua numbers go up to 100 trillion, and since I want fractional EMC to be possible, the maximum is 1 trillion.
exchangeclone.emc_limit = 1000000000000

--exchangeclone.int_limit = 2147483647

-- For some reason the maximum fuel burn time is 64 less than the integer limit. No idea why.
exchangeclone.fuel_limit = 2147483583

-- Itemstrings for various items used in crafting recipes.
exchangeclone.itemstrings = {
    cobble =            exchangeclone.mcl and "mcl_core:cobble"             or "default:cobble",
    stone =             exchangeclone.mcl and "mcl_core:stone"              or "default:stone",
    redstoneworth =     exchangeclone.mcl and "mesecons:redstone"           or "default:obsidian",
    obsidian =          exchangeclone.mcl and "mcl_core:obsidian"           or "default:obsidian",
    glowstoneworth =    exchangeclone.mcl and "mcl_nether:glowstone_dust"   or "default:tin_ingot",
    lapisworth =        exchangeclone.mcl and "mcl_core:lapis"              or "bucket:bucket_lava",
    coal =              exchangeclone.mcl and "mcl_core:coal_lump"          or "default:coal_lump",
    iron =              exchangeclone.mcl and "mcl_core:iron_ingot"         or "default:steel_ingot",
    copper =            exchangeclone.mcl and "mcl_copper:copper_ingot"     or "default:copper_ingot",
    gold =              exchangeclone.mcl and "mcl_core:gold_ingot"         or "default:gold_ingot",
    emeraldworth =      exchangeclone.mcl and "mcl_core:emerald"            or "default:mese_crystal",
    diamond =           exchangeclone.mcl and "mcl_core:diamond"            or "default:diamond",
    gravel =            exchangeclone.mcl and "mcl_core:gravel"             or "default:gravel",
    dirt =              exchangeclone.mcl and "mcl_core:dirt"               or "default:dirt",
    clay =              exchangeclone.mcl and "mcl_core:clay"               or "default:clay",
    sand =              exchangeclone.mcl and "mcl_core:sand"               or "default:sand",
    torch =             exchangeclone.mcl and "mcl_torches:torch"           or "default:torch",
    book =              exchangeclone.mcl and "mcl_books:book"              or "default:book",
    glass =             exchangeclone.mcl and "mcl_core:glass"              or "default:glass",
    water =             exchangeclone.mcl and "mcl_core:water_source"       or "default:water_source",
    lava =              exchangeclone.mcl and "mcl_core:lava_source"        or "default:lava_source",
    water_bucket =      exchangeclone.mcl and "mcl_buckets:bucket_water"    or "bucket:bucket_water",
    lava_bucket =       exchangeclone.mcl and "mcl_buckets:bucket_lava"     or "bucket:bucket_lava",
    empty_bucket =      exchangeclone.mcl and "mcl_buckets:bucket_empty"    or "bucket:bucket_empty",
    snow =              exchangeclone.mcl and "mcl_core:snow"               or "default:snow",
    fire =              exchangeclone.mcl and "mcl_fire:fire"               or "fire:fire",
    ice =               exchangeclone.mcl and "mcl_core:ice"                or "default:ice",
    chest =             exchangeclone.mcl and "mcl_chests:chest"            or "default:chest",
    furnace =           exchangeclone.mcl and "mcl_furnaces:furnace"        or "default:furnace",
    string =            exchangeclone.mcl and "mcl_mobitems:string"         or "farming:cotton",
}