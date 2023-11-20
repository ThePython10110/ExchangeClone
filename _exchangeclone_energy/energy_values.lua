if exchangeclone.mcl then
    --[[ Groups are organized so that order matters. Groups that are lower on the
    list will have their energies applied later, making them  higher priority. It's
    unnecessary for single items because order doesn't matter for them. The NO_GROUP
    value is for values that are not in any other group, but adding this means that
    NO items will have their energy calculated by recipes. ]]
    table.insert_all(exchangeclone.group_values, {
        {"flower", 8},
        {"mushroom", 32},
        {"smithing_template", 8192*7+1792*2},
        {"decorated_pot_recipe", 4}, -- has to be 4 because of brick.
    })

    for itemstring, energy_value in pairs({

        ["fake_liquids:bucket_fake_lava"] = 832,
        ["fake_liquids:bucket_fake_water"] = 960,

        ["lava_sponge:lava_sponge_wet"] = 1160,

        ["mcl_amethyst:amethyst_cluster"] = 512,
        ["mcl_amethyst:amethyst_shard"] = 256,
        ["mcl_amethyst:calcite"] = 128,
        ["mcl_amethyst:large_amethyst_bud"] = 426,
        ["mcl_amethyst:medium_amethyst_bud"] = 341,
        ["mcl_amethyst:small_amethyst_bud"] = 256,

        ["mcl_anvils:anvil_damage_1"] = 5632,
        ["mcl_anvils:anvil_damage_2"] = 3328,

        ["mcl_armor:boots_chain"] = 768,
        ["mcl_armor:boots_netherite"] = 106496,
        ["mcl_armor:chestplate_chain"] = 1792,
        ["mcl_armor:chestplate_netherite"] = 139264,
        ["mcl_armor:elytra"] = 297216,
        ["mcl_armor:helmet_chain"] = 1024,
        ["mcl_armor:helmet_netherite"] = 114688,
        ["mcl_armor:leggings_chain"] = 1536,
        ["mcl_armor:leggings_netherite"] = 131072,

        ["mcl_bamboo:bamboo"] = 2,
        ["mcl_bamboo:bamboo_block_stripped"] = 16,

        ["mcl_banners:pattern_globe"] = 360,
        ["mcl_banners:pattern_piglin"] = 300,

        ["mcl_beehives:beehive"] = 144,

        ["mcl_bells:bell"] = 8192,

        ["mcl_blackstone:basalt"] = 1,
        ["mcl_blackstone:blackstone"] = 1,
        ["mcl_blackstone:blackstone_gilded"] = 2048,
        ["mcl_blackstone:nether_gold"] = 2048,
        ["mcl_blackstone:soul_soil"] = 49,

        ["mcl_books:book"] = 150,
        ["mcl_books:written_book"] = 206,

        ["mcl_bows:crossbow_loaded"] = 298,

        ["mcl_buckets:bucket_axolotl"] = 1024,
        ["mcl_buckets:bucket_cod"] = 896,
        ["mcl_buckets:bucket_lava"] = 896,
        ["mcl_buckets:bucket_river_water"] = 768,
        ["mcl_buckets:bucket_salmon"] = 896,
        ["mcl_buckets:bucket_tropical_fish"] = 896,
        ["mcl_buckets:bucket_water"] = 768,

        ["mcl_campfires:campfire"] = 140,
        ["mcl_campfires:soul_campfire"] = 157,

        ["mcl_cocoas:cocoa_beans"] = 128,

        ["mcl_copper:copper_ingot"] = 85,

        ["mcl_core:andesite"] = 1,
        ["mcl_core:apple"] = 128,
        ["mcl_core:apple_gold_enchanted"] = 147584,
        ["mcl_core:cactus"] = 8,
        ["mcl_core:charcoal_lump"] = 32,
        ["mcl_core:clay_lump"] = 4,
        ["mcl_core:coal_lump"] = 128,
        ["mcl_core:cobble"] = 1,
        ["mcl_core:cobweb"] = 12,
        ["mcl_core:crying_obsidian"] = 1000,
        ["mcl_core:dead_bush"] = 8,
        ["mcl_core:deadbush"] = 8,
        ["mcl_core:diamond"] = 8192,
        ["mcl_core:diorite"] = 1,
        ["mcl_core:dirt"] = 1,
        ["mcl_core:emerald"] = 4096,
        ["mcl_core:flint"] = 4,
        ["mcl_core:gold_ingot"] = 2048,
        ["mcl_core:granite"] = 1,
        ["mcl_core:grass"] = 1,
        ["mcl_core:gravel"] = 1,
        ["mcl_core:ice"] = 1,
        ["mcl_core:iron_ingot"] = 256,
        ["mcl_core:lapis"] = 864,
        ["mcl_core:mycelium"] = 1,
        ["mcl_core:obsidian"] = 64,
        ["mcl_core:redsand"] = 1,
        ["mcl_core:reeds"] = 32,
        ["mcl_core:sand"] = 1,
        ["mcl_core:vine"] = 8,

        ["mcl_crimson:shroomlight"] = 64,
        ["mcl_crimson:twisting_vines"] = 8,
        ["mcl_crimson:warped_wart_block"] = 216,
        ["mcl_crimson:weeping_vines"] = 8,

        ["mcl_deepslate:deepslate_cobbled"] = 1,
        ["mcl_deepslate:tuff"] = 1,

        ["mcl_end:chorus_flower"] = 32,
        ["mcl_end:chorus_fruit"] = 16,
        ["mcl_end:dragon_egg"] = 139264,
        ["mcl_end:end_stone"] = 1,

        ["mcl_experience:bottle"] = 2048,

        ["mcl_farming:beetroot_item"] = 24,
        ["mcl_farming:beetroot_seeds"] = 16,
        ["mcl_farming:carrot_item"] = 24,
        ["mcl_farming:hoe_netherite"] = 90108,
        ["mcl_farming:melon_item"] = 36,
        ["mcl_farming:potato_item"] = 24,
        ["mcl_farming:potato_item_poison"] = 24,
        ["mcl_farming:pumpkin"] = 144,
        ["mcl_farming:pumpkin_face"] = 144,
        ["mcl_farming:sweet_berry"] = 16,
        ["mcl_farming:wheat_item"] = 24,
        ["mcl_farming:wheat_seeds"] = 16,

        ["mcl_fishing:clownfish_raw"] = 64,
        ["mcl_fishing:fish_raw"] = 40,
        ["mcl_fishing:pufferfish_raw"] = 64,
        ["mcl_fishing:salmon_raw"] = 48,

        ["mcl_flowers:waterlily"] = 16,
        ["mcl_flowers:wither_rose"] = 128,

        ["mcl_heads:creeper"] = 256,
        ["mcl_heads:skeleton"] = 256,
        ["mcl_heads:steve"] = 256,
        ["mcl_heads:wither_skeleton"] = 50000,
        ["mcl_heads:zombie"] = 256,

        ["mcl_honey:honey_bottle"] = 33,
        ["mcl_honey:honeycomb"] = 32,

        ["mcl_lush_caves:cave_vines"] = 8,
        ["mcl_lush_caves:cave_vines_lit"] = 0,
        ["mcl_lush_caves:glow_berry"] = 36,
        ["mcl_lush_caves:spore_blossom"] = 32,

        ["mcl_mangrove:mangrove_roots"] = 1,

        ["mcl_maps:filled_map"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_18D471DFF_female_crea"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_18D471DFF_female_surv"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_18D471DFF_male_crea"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_18D471DFF_male_surv"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1B47A57FF_female_crea"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1B47A57FF_female_surv"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1B47A57FF_male_crea"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1B47A57FF_male_surv"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1EEB592FF_female_crea"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1EEB592FF_female_surv"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1EEB592FF_male_crea"] = 1120,
        ["mcl_maps:filled_map_mcl_skins_base_1EEB592FF_male_surv"] = 1120,

        ["mcl_mobitems:beef"] = 64,
        ["mcl_mobitems:blaze_rod"] = 1536,
        ["mcl_mobitems:bone"] = 144,
        ["mcl_mobitems:chicken"] = 48,
        ["mcl_mobitems:diamond_horse_armor"] = 73728,
        ["mcl_mobitems:feather"] = 48,
        ["mcl_mobitems:ghast_tear"] = 4096,
        ["mcl_mobitems:glow_ink_sac"] = 256,
        ["mcl_mobitems:gold_horse_armor"] = 18432,
        ["mcl_mobitems:gunpowder"] = 192,
        ["mcl_mobitems:heart_of_the_sea"] = 50000,
        ["mcl_mobitems:ink_sac"] = 8,
        ["mcl_mobitems:iron_horse_armor"] = 2304,
        ["mcl_mobitems:leather"] = 64,
        ["mcl_mobitems:magma_cream"] = 768,
        ["mcl_mobitems:milk_bucket"] = 832,
        ["mcl_mobitems:mutton"] = 48,
        ["mcl_mobitems:nametag"] = 128,
        ["mcl_mobitems:nautilus_shell"] = 10000,
        ["mcl_mobitems:nether_star"] = 73728,
        ["mcl_mobitems:porkchop"] = 64,
        ["mcl_mobitems:rabbit"] = 40,
        ["mcl_mobitems:rabbit_foot"] = 64,
        ["mcl_mobitems:rabbit_hide"] = 16,
        ["mcl_mobitems:rotten_flesh"] = 24,
        ["mcl_mobitems:saddle"] = 192,
        ["mcl_mobitems:shulker_shell"] = 2048,
        ["mcl_mobitems:slimeball"] = 24,
        ["mcl_mobitems:spider_eye"] = 128,
        ["mcl_mobitems:string"] = 12,

        ["mcl_mobs:nametag"] = 128,

        ["mcl_mud:mud"] = 1,

        ["mcl_nether:ancient_debris"] = 16384,
        ["mcl_nether:glowstone_dust"] = 384,
        ["mcl_nether:nether_wart_item"] = 24,
        ["mcl_nether:netherrack"] = 1,
        ["mcl_nether:quartz"] = 128,
        ["mcl_nether:soul_sand"] = 49,

        ["mcl_ocean:brain_coral"] = 8,
        ["mcl_ocean:brain_coral_block"] = 8,
        ["mcl_ocean:brain_coral_fan"] = 8,
        ["mcl_ocean:bubble_coral"] = 8,
        ["mcl_ocean:bubble_coral_block"] = 8,
        ["mcl_ocean:bubble_coral_fan"] = 8,
        ["mcl_ocean:dead_brain_coral"] = 8,
        ["mcl_ocean:dead_brain_coral_block"] = 8,
        ["mcl_ocean:dead_brain_coral_fan"] = 8,
        ["mcl_ocean:dead_bubble_coral"] = 8,
        ["mcl_ocean:dead_bubble_coral_block"] = 8,
        ["mcl_ocean:dead_bubble_coral_fan"] = 8,
        ["mcl_ocean:dead_fire_coral"] = 8,
        ["mcl_ocean:dead_fire_coral_block"] = 8,
        ["mcl_ocean:dead_fire_coral_fan"] = 8,
        ["mcl_ocean:dead_horn_coral"] = 8,
        ["mcl_ocean:dead_horn_coral_block"] = 8,
        ["mcl_ocean:dead_horn_coral_fan"] = 8,
        ["mcl_ocean:dead_tube_coral"] = 8,
        ["mcl_ocean:dead_tube_coral_block"] = 8,
        ["mcl_ocean:dead_tube_coral_fan"] = 8,
        ["mcl_ocean:fire_coral"] = 8,
        ["mcl_ocean:fire_coral_block"] = 8,
        ["mcl_ocean:fire_coral_fan"] = 8,
        ["mcl_ocean:horn_coral"] = 8,
        ["mcl_ocean:horn_coral_block"] = 8,
        ["mcl_ocean:horn_coral_fan"] = 8,
        ["mcl_ocean:kelp"] = 32,
        ["mcl_ocean:prismarine_crystals"] = 2054,
        ["mcl_ocean:prismarine_shard"] = 2,
        ["mcl_ocean:sea_pickle_1_dead_brain_coral_block"] = 8,
        ["mcl_ocean:seagrass"] = 1,
        ["mcl_ocean:tube_coral"] = 8,
        ["mcl_ocean:tube_coral_block"] = 8,
        ["mcl_ocean:tube_coral_fan"] = 8,

        ["mcl_potions:dragon_breath"] = 8.5,
        ["mcl_potions:fermented_spider_eye"] = 192,
        ["mcl_potions:glass_bottle"] = 1,
        ["mcl_potions:speckled_melon"] = 1852,

        ["mcl_pottery_sherds:pot"] = 16,

        ["mcl_sponges:sponge"] = 1024,
        ["mcl_sponges:sponge_wet"] = 1024,
        ["mcl_sponges:sponge_wet_river_water"] = 1024,

        ["mcl_throwing:egg"] = 32,
        ["mcl_throwing:ender_pearl"] = 1024,
        ["mcl_throwing:snowball"] = 0.25,

        ["mcl_tools:axe_netherite"] = 98312,
        ["mcl_tools:pick_netherite"] = 98312,
        ["mcl_tools:shovel_netherite"] = 81928,
        ["mcl_tools:sword_netherite"] = 90120,

        ["mcl_totems:totem"] = 106496,
        ["meat_blocks:meatball"] = 64,
        ["mesecons:redstone"] = 64,
        ["useful_green_potatoes:useful_green_potato"] = 256,
    }) do
        exchangeclone.energy_values[itemstring] = exchangeclone.energy_values[itemstring] or energy_value
    end

    exchangeclone.mcl_potion_data = exchangeclone.mcl_potion_data or {}
    table.insert_all(exchangeclone.mcl_potion_data, { -- automatically assumes base cost is awkward potion if not specified
        {name = "water", ingredient_cost = 0, custom_base_cost = 0, no_arrow = true},
        {name = "awkward", ingredient_cost = 0, no_arrow = true},
        {name = "fire_resistance", ingredient_cost = 768, plus = true},
        {name = "poison", ingredient_cost = 128, plus = true, two = true},
        {name = "harming", ingredient_cost = 192, custom_base_cost = 52, two = true},
        {name = "healing", ingredient_cost = 1852, two = true},
        {name = "leaping", ingredient_cost = 64, plus = true, two = true},
        {name = "mundane", ingredient_cost = 32, no_arrow = true, custom_base_cost = 0},
        {name = "night_vision", ingredient_cost = 1840, plus = true},
        {name = "regeneration", ingredient_cost = 4096, plus = true, two = true},
        {name = "slowness", ingredient_cost = 192, custom_base_cost = 20, plus = true, two = true},
        {name = "swiftness", ingredient_cost = 32, plus = true, two = true},
        {name = "thick", ingredient_cost = 384, no_arrow = true, custom_base_cost = 0},
        {name = "water_breathing", ingredient_cost = 64, plus = true},
        {name = "invisibility", ingredient_cost = 192, custom_base_cost = 623, plus = true},
        {name = "withering", ingredient_cost = 128, plus = true, two = true}
    })
else
    for itemstring, energy_value in pairs({
        ["bones:bones"] = 4,

        ["bucket:bucket_lava"] = 896,
        ["bucket:bucket_river_water"] = 768,
        ["bucket:bucket_water"] = 768,

        ["default:acacia_bush_leaves"] = 1,
        ["default:acacia_bush_sapling"] = 32,
        ["default:acacia_bush_stem"] = 8,
        ["default:apple"] = 5,
        ["default:blueberries"] = 16,
        ["default:blueberry_bush_leaves"] = 1,
        ["default:blueberry_bush_leaves_with_berries"] = 9,
        ["default:blueberry_bush_sapling"] = 32,
        ["default:book_written"] = 96,
        ["default:bush_leaves"] = 1,
        ["default:bush_sapling"] = 32,
        ["default:bush_stem"] = 8,
        ["default:cactus"] = 8,
        ["default:clay_lump"] = 4,
        ["default:coal_lump"] = 128,
        ["default:cobble"] = 1,
        ["default:copper_ingot"] = 320,
        ["default:coral_brown"] = 8,
        ["default:coral_cyan"] = 8,
        ["default:coral_green"] = 8,
        ["default:coral_orange"] = 8,
        ["default:coral_pink"] = 8,
        ["default:coral_skeleton"] = 8,
        ["default:desert_cobble"] = 1,
        ["default:desert_sand"] = 1,
        ["default:diamond"] = 8192,
        ["default:dirt"] = 1,
        ["default:dirt_with_grass"] = 1,
        ["default:dry_dirt"] = 1,
        ["default:dry_dirt_with_dry_grass"] = 1,
        ["default:dry_dirt_with_grass"] = 1,
        ["default:emergent_jungle_sapling"] = 32,
        ["default:flint"] = 4,
        ["default:gold_ingot"] = 2048,
        ["default:grass"] = 1,
        ["default:gravel"] = 1,
        ["default:ice"] = 1,
        ["default:iron_ingot"] = 256,
        ["default:large_cactus_seedling"] = 32,
        ["default:mese_crystal"] = 4096,
        ["default:mossycobble"] = 32,
        ["default:obsidian"] = 64,
        ["default:papyrus"] = 32,
        ["default:pine_bush_needles"] = 1,
        ["default:pine_bush_sapling"] = 32,
        ["default:pine_bush_stem"] = 8,
        ["default:sand"] = 1,
        ["default:sand_with_kelp"] = 32,
        ["default:silver_sand"] = 1,
        ["default:snow"] = 0.5,
        ["default:snowblock"] = 5,
        ["default:stick"] = 4,
        ["default:tin_ingot"] = 384,

        ["farming:cotton"] = 12,
        ["farming:cotton_wild"] = 12,
        ["farming:seed_cotton"] = 10,
        ["farming:seed_wheat"] = 16,
        ["farming:wheat"] = 24,

        ["moreores:mithril_ingot"] = 16384,
        ["moreores:silver_ingot"] = 4000,

        ["technic:chromium_ingot"] = 4096,
        ["technic:granite"] = 1,
        ["technic:lead_ingot"] = 256,
        ["technic:marble"] = 1,
        ["technic:sulfur_lump"] = 128,
        ["technic:uranium_ingot"] = 8192,
        ["technic:zinc_ingot"] = 512,

        ["useful_green_potatoes:useful_green_potato"] = 256
    }) do
        exchangeclone.energy_values[itemstring] = exchangeclone.energy_values[itemstring] or energy_value
    end

    exchangeclone.group_values = {
        {"flower", 32},
        --{"dye", 8},
    }

end

-- For things that are the same in both games:

for itemstring, energy_value in pairs ({
    ["exchangeclone:alchemical_tome"] = 0,
}) do
    exchangeclone.energy_values[itemstring] = energy_value
end

table.insert_all(exchangeclone.group_values, {
    {"tree", 32},
    {"leaves", 1},
    {"sapling", 32},
    {"useless", 0},
    {"exchangeclone_dirt", 1},
    {"exchangeclone_ore", 0}
})