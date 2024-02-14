local register_award = exchangeclone.mcl and awards.register_achievement or awards.register_award

register_award("exchangeclone:best_friend", {
    title = "An alchemist's best friend",
    description = "Let's get things started! Craft a Philosopher's Stone",
    icon = "exchangeclone_philosophers_stone.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:philosophers_stone",
        target = 1,
    }
})

register_award("exchangeclone:this_into_that", {
    title = "Transmute this into that!",
    description = "The beginning (and end) of everything.",
    icon = "exchangeclone_transmutation_table_top.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:transmutation_table",
        target = 1,
    }
})

register_award("exchangeclone:on_the_go", {
    title = "Transmutation on the go!",
    description = "And then you thought things couldn't get better.",
    icon = "exchangeclone_transmutation_tablet.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:transmutation_tablet",
        target = 1,
    }
})

register_award("exchangeclone:emc_batteries", {
    title = "EMC Batteries",
    description = "Storing EMC for a rainy day.",
    icon = "exchangeclone_klein_star_ein.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:klein_star_ein",
        target = 1,
    }
})

register_award("exchangeclone:big_emc_batteries", {
    title = "BIG EMC Batteries",
    description = "Holding the universe in your pocket.",
    icon = "exchangeclone_klein_star_omega.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:klein_star_omega",
        target = 1,
    }
})

register_award("exchangeclone:massive_emc_batteries", {
    title = "MASSIVE EMC Batteries",
    description = "Holding... uhh... the multiverse in your pocket.",
    icon = "exchangeclone_magnum_star_omega.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:magnum_star_omega",
        target = 1,
    }
})

register_award("exchangeclone:storage_upgrade", {
    title = "Storage Upgrade!",
    description = 'A "little" chest upgrade.',
    icon = "exchangeclone_alchemical_chest_top.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:alchemical_chest",
        target = 1,
    }
})

register_award("exchangeclone:matter_on_matter", {
    title = "Using Matter on Matter?",
    description = "Because why not?",
    icon = "exchangeclone_dark_matter_pickaxe.png",
    target = 1,
    trigger = {
        type = "craft",
        item = "exchangeclone:dark_matter_pickaxe",
        target = 1,
    }
})

register_award("exchangeclone:is_this_safe", {
    title = "Is this thing safe?",
    description = "Probably not.",
    icon = "exchangeclone_red_matter_pickaxe.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:red_matter_pickaxe",
        target = 1,
    }
})

register_award("exchangeclone:hot_matter", {
    title = "Hot matter!",
    description = "A furnace is even better when made from dark matter.",
    icon = "exchangeclone_red_matter_furnace_active.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:dark_matter_furnace",
        target = 1,
    }
})

register_award("exchangeclone:even_hotter_matter", {
    title = "Even hotter matter!",
    description = "Wow, that thing is fast.",
    icon = "exchangeclone_red_matter_furnace_active.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:red_matter_furnace",
        target = 1,
    }
})

-- MCL2 does not support groups in awards for some reason.
-- https://git.minetest.land/MineClone2/MineClone2/issues/4191
if not exchangeclone.mcl2 then
    register_award("exchangeclone:pocket_storage", {
        title = "Pocket storage!",
        description = "All the wonders of an alchemical chest, in your pocket.",
        icon = "exchangeclone_alchemical_bag.png",
        trigger = {
            type = "craft",
            item = "group:alchemical_bag",
            target = 1,
        }
    })

    register_award("exchangeclone:power_of_sun", {
        title = "The power of the sun!",
        description = "Now the fun begins.",
        icon = "exchangeclone_energy_collector_base.png^exchangeclone_energy_collector_overlay.png",
        trigger = "craft",
        item = "group:energy_collector",
        target = 1,
    })
end

register_award("exchangeclone:all_that_matters", {
    title = "All that Matters.",
    description = "It looks... weird....",
    icon = "exchangeclone_dark_matter.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:dark_matter",
        target = 1,
    }
})

register_award("exchangeclone:even_better_matter", {
    title = "Even better Matter!",
    description = "The space time continuum may be broken.",
    icon = "exchangeclone_red_matter.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:red_matter",
        target = 1,
    }
})

register_award("exchangeclone:red_and_shiny", {
    title = "Red and shiny!",
    description = "Now you're getting somewhere!",
    icon = "exchangeclone_red_matter_block.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:red_matter_block",
        target = 1,
    }
})

register_award("exchangeclone:block_that_matters", {
    title = "A block that Matters!",
    description = "Stuffing matter together. Because that's a good idea.",
    icon = "exchangeclone_dark_matter_block.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:dark_matter_block",
        target = 1,
    }
})

register_award("exchangeclone:artificial_enchantment", {
    title = "Artificial enchantment!",
    description = "Why use magic when alchemy works just as well?",
    icon = "exchangeclone_upgrader_side.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:upgrader",
        target = 1,
    }
})

register_award("exchangeclone:things_into_emc", {
    title = "Turn things into EMC!",
    description = "A trash can, but useful.",
    icon = "exchangeclone_deconstructor_up.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:deconstructor",
        target = 1,
    }
})

register_award("exchangeclone:energetic_duplication", {
    title = "Energetic duplication!",
    description = "Not a trash can, but useful.",
    icon = "exchangeclone_constructor_up.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:constructor",
        target = 1
    }
})

register_award("exchangeclone:one_thousand_damage", {
    title = "One thousand damage!",
    description = "Now that's overpowered.",
    icon = "exchangeclone_red_katar.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:red_katar",
        target = 1
    }
})

register_award("exchangeclone:better_matter_miner", {
    title = "Better matter miner!",
    description = "Even better than all other miners made of matter.",
    icon = "exchangeclone_red_morningstar.png",
    trigger = {
        type = "craft",
        item = "exchangeclone:red_morningstar",
        target = 1
    }
})