if exchangeclone.exile then
    table.insert_all(exchangeclone.group_values, {
        {"log", 32},
        {"leafdecay", 1},
        {"_ncrafting_bundle", 64},
        {"_ncrafting_dye_color", 32},
        {"wet_sediment", 1},
    })
    for itemstring, emc_value in pairs({
        ["tech:soup"] = 16,

        ["bones:bones"] = 32,
        ["lore:exile_letter"] = 32,

        ["animals:gundu"] = 128,
        ["animals:pegasun_male"] = 128,
        ["animals:pegasun"] = 144, -- higher because they lay eggs
        ["animals:kubwakubwa"] = 144,
        ["animals:darkasthaan"] = 192,
        ["animals:sarkamos"] = 256,
        ["animals:impethu"] = 32,
        ["animals:sneachan"] = 32,

        ["animals:gundu_eggs"] = 64,
        ["animals:pegasun_eggs"] = 32,
        ["animals:kubwakubwa_eggs"] = 24,
        ["animals:darkasthaan_eggs"] = 32,
        ["animals:sarkamos_eggs"] = 64,
        ["animals:impethu_eggs"] = 16,
        ["animals:sneachan_eggs"] = 16,

        ["animals:carcass_invert_small"] = 3,
        ["animals:carcass_invert_large"] = 10,
        ["animals:carcass_bird_small"] = 20,
        ["animals:carcass_fish_small"] = 15,
        ["animals:carcass_fish_large"] = 45,

        ["nodes_nature:vansano"] = 32,
        ["nodes_nature:anperla"] = 32,
        ["nodes_nature:reshedaar"] = 64,
        ["nodes_nature:mahal"] = 64,
        ["nodes_nature:tikusati"] = 32,
        ["nodes_nature:nebiyi"] = 32,
        ["nodes_nature:marbhan"] = 32,
        ["nodes_nature:hakimi"] = 32,
        ["nodes_nature:merki"] = 32,
        ["nodes_nature:wiha"] = 32,
        ["nodes_nature:zufani"] = 32,
        ["nodes_nature:galanta"] = 32,
        ["nodes_nature:momo"] = 32,
        ["nodes_nature:glow_worm"] = 32,
        ["nodes_nature:lambakap"] = 64,

        ["nodes_nature:gemedi"] = 16,
        ["nodes_nature:cana"] = 16,
        ["nodes_nature:tiken"] = 16,
        ["nodes_nature:chalin"] = 16,

        ["nodes_nature:salt_water_source"] = 0.05, -- basically free
        ["nodes_nature:freshwater_source"] = 64, -- hard to get and doesn't duplicate
        ['nodes_nature:lava_source'] = 8192, -- because it's so hard to get
        ['tech:molten_slag_source'] = 8192, -- because it's so hard to get

        ['nodes_nature:ironstone_boulder'] = 64,
        ['tech:slag'] = 16,
        ['nodes_nature:volcanic_ash'] = 1,
        ['tech:wood_ash'] = 8,
        ['tech:broken_pottery'] = 8,
        ['nodes_nature:gneiss_boulder'] = 4,
        ['tech:clay_water_pot'] = 16,
        ['tech:cooking_pot'] = 16,
        ['tech:clay_storage_pot'] = 16,
        ['tech:clay_oil_lamp_empty'] = 16,

        ['nodes_nature:jade_boulder'] = 64,

        --costly processed materials, expensive tools, crap artifacts (rarity 4)
        --['artifacts:moon_glass'] = 64,
        ['artifacts:antiquorium_ladder'] = 4096 * 7 / 16,
        ['artifacts:antiquorium_chest'] = 4096 * 4,
        --['artifacts:antiquorium'] = 64,
        ['doors:door_antiquorium'] = 4096 * 4,
        ['artifacts:trapdoor_antiquorium'] = 4096 * 2,

        --['nodes_nature:zufani_seed'] = 64,


        --low level artifacts (rarity 5), non-durables
        ['artifacts:conveyor'] = 256,
        ['artifacts:trampoline'] = 256,

        --['nodes_nature:merki_seed'] = 256,

        ['artifacts:light_meter'] = 4000,
        ['artifacts:thermometer'] = 4000,
        ['artifacts:temp_probe'] = 4000,
        ['artifacts:fuel_probe'] = 4000,
        ['artifacts:smelter_probe'] = 4000,
        ['artifacts:potters_probe'] = 4000,
        ['artifacts:chefs_probe'] = 4000,
        ['artifacts:farmers_probe'] = 4000,
        ['artifacts:animal_probe'] = 4000,

        ['artifacts:spyglass'] = 256,
        ['artifacts:bell'] = 256,
        ['artifacts:waystone'] = 256,
        ['artifacts:wayfinder_0'] = 256,

        --['tech:stick'] = 256,

        --['tech:fine_fibre'] = 256,
        --['tech:coarse_fibre'] = 256,
        --['tech:paint_lime_white'] = 256,
        --['tech:paint_glow_paint'] = 256,

        ['artifacts:sculpture_mg_dancers'] = 256,
        ['artifacts:sculpture_mg_bonsai'] = 256,
        ['artifacts:sculpture_mg_bloom'] = 256,
        ['artifacts:sculpture_j_axeman'] = 256,
        ['artifacts:sculpture_j_dragon_head'] = 256,
        ['artifacts:sculpture_j_skull_head'] = 256,

        ['artifacts:star_stone'] = 256,
        ['artifacts:singing_stone'] = 256,
        ['artifacts:drumming_stone'] = 256,

        ['artifacts:gamepiece_a_black'] = 256,
        ['artifacts:gamepiece_a_white'] = 256,
        ['artifacts:gamepiece_b_black'] = 256,
        ['artifacts:gamepiece_b_white'] = 256,
        ['artifacts:gamepiece_c_black'] = 256,
        ['artifacts:gamepiece_c_white'] = 256,

        --high level artifacts, and intact non-durables (rarity 6)
        --['artifacts:moon_stone'] = 1024,
        --['artifacts:sun_stone'] = 1024,

        --['tech:fine_fabric'] = 1024,
        --['tech:torch'] = 1024,
        --['tech:vegetable_oil'] = 1024,
        --['tech:coarse_fabric'] = 1024,
        --['tech:mattress'] = 32768,

        --["backpacks:backpack_fabric_bag"] = 1024,

        ['artifacts:airboat'] = 8192,
        ['artifacts:mapping_kit'] = 1024,
        ['artifacts:antiquorium_chisel'] = 8192,

        ['artifacts:transporter_key'] = 1024,
        ['artifacts:transporter_regulator'] = 1024,
        ['artifacts:transporter_stabilizer'] = 1024,
        ['artifacts:transporter_focalizer'] = 1024,
        ['artifacts:transporter_power_dep'] = 1024,
        ['artifacts:transporter_power'] = 1024,
        ['artifacts:transporter_pad'] = 1024,
        ['artifacts:transporter_pad_charging'] = 1024,

        --['nodes_nature:lambakap_seed'] = 1024,
        --['nodes_nature:reshedaar_seed'] = 1024,
        --['nodes_nature:mahal_seed'] = 1024,

        ['artifacts:sculpture_g_arch_judge'] = 1024,
        ['artifacts:sculpture_g_arch_beast'] = 1024,
        ['artifacts:sculpture_g_arch_trickster'] = 1024,
        ['artifacts:sculpture_g_arch_mother'] = 1024,

        ['player_api:cloth_female_upper_default'] = 1024,
        ['player_api:cloth_female_lower_default'] = 1024,
        ['player_api:cloth_unisex_footwear_default'] = 1024,
        ['player_api:cloth_female_head_default'] = 1024,
        ['player_api:cloth_male_upper_default'] = 1024,
        ['player_api:cloth_male_lower_default'] = 1024,

        ['artifacts:metastim'] = 100000,

    }) do
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or emc_value
    end
    for _, v in ipairs(plantlist) do
        local itemstring = "nodes_nature:"..v[1]
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 16
        local itemstring = "nodes_nature:"..v[1].."_seedling"
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 8
    end
    for _, v in ipairs(searooted_list) do
        local itemstring = "nodes_nature:"..v[1]
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 16
    end
    for _, v in ipairs(rock_list) do
        local itemstring = "nodes_nature:"..v[1]
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 4
        local itemstring = "nodes_nature:"..v[1].."_boulder"
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 4
        exchangeclone.register_alias("nodes_nature:"..v[1].."_cobble2", "nodes_nature:"..v[1].."_cobble1")
        exchangeclone.register_alias("nodes_nature:"..v[1].."_cobble2", "nodes_nature:"..v[1].."_cobble3")
    end
    for _, v in ipairs(sed_list) do
        local itemstring = "nodes_nature:"..v[1]
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 1
    end
    for _, v in ipairs(stone_list) do
        local itemstring = "nodes_nature:"..v[1]
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 1
        local itemstring = "nodes_nature:"..v[1].."_block"
        exchangeclone.base_emc_values[itemstring] = exchangeclone.base_emc_values[itemstring] or 1
    end
    exchangeclone.register_alias("artifacts:antiquorium", "rings:antiquorium")
    exchangeclone.register_alias("artifacts:moon_glass", "rings:moon_glass")
end