-- true = blocks all damage
-- {base_block, block_per_rm}: Amount blocked by full dark matter, extra amount per red matter armor piece
local blocked_damage_types = {
    drown = true,
    lava = true,
    in_fire = true,
    on_fire = true,
    hot_floor = true,
    fall = {0.9, 0.0125},
}

local function get_armor_texture(type, matter, preview)
    local modifier
    -- hsl only works in 5.8 which hasn't been released yet
    if matter == "dark" then
        modifier = "^[multiply:#222222"
        --modifier = "^[hsl:0:-100:-100^[hsl:0:-100:-100"
    else
        modifier = "^[multiply:#990000"
        --modifier = "^[hsl:-180:100:-100"
    end
    local result
    if exchangeclone.mcl then
        result = "exchangeclone_mcl_"..type.."_base.png"..modifier
    else
        result = "exchangeclone_mtg_"..type.."_base"
        if preview then result = result.."_preview" end
        result = result..".png"..modifier
    end
    return result
end

-- Reset health
function exchangeclone.check_armor_health(obj)
    if obj:get_meta():get_int("exchangeclone_red_matter_armor") == 1 then
        obj:set_hp(math.min(obj:get_hp(), 20))
        obj:set_properties({hp_max = 20})
        obj:get_meta():set_int("exchangeclone_red_matter_armor", 0)
    end
end

minetest.register_on_joinplayer(function(ObjectRef, last_login)
    exchangeclone.check_armor_health(ObjectRef)
end)

if exchangeclone.mcl then
    mcl_armor.register_set({
        name = "dark_matter",
        description = "Dark Matter",
        descriptions = exchangeclone.mineclonia and {
            head = "Dark Matter Helmet",
            torso = "Dark Matter Chestplate",
            legs = "Dark Matter Leggings",
            feet = "Dark Matter Boots"
        },
        durability = -1,
        enchantability = 0,
        points = {
            head = 6,
            torso = 10,
            legs = 8,
            feet = 4,
        },
        textures = {
            head = get_armor_texture("helmet","dark"),
            torso = get_armor_texture("chestplate","dark"),
            legs = get_armor_texture("leggings","dark"),
            feet = get_armor_texture("boots","dark"),
        },
        toughness = 4,
        groups = {dark_matter_armor = 1, fire_immune = 1, exchangeclone_upgradable = 1},
        craft_material = "exchangeclone:dark_matter",
        cook_material = "mcl_core:diamondblock",
    })
    mcl_armor.register_set({
        name = "red_matter",
        description = "Red Matter",
        descriptions = exchangeclone.mineclonia and {
            head = "Red Matter Helmet",
            torso = "Red Matter Chestplate",
            legs = "Red Matter Leggings",
            feet = "Red Matter Boots"
        },
        durability = -1,
        enchantability = 0,
        points = {
            head = 7,
            torso = 12,
            legs = 9,
            feet = 5,
        },
        textures = {
            head = get_armor_texture("helmet","red"),
            torso = get_armor_texture("chestplate","red"),
            legs = get_armor_texture("leggings","red"),
            feet = get_armor_texture("boots","red"),
        },
        toughness = 5,
        groups = {red_matter_armor = 1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1},
        craft_material = "exchangeclone:red_matter",
        cook_material = "exchangeclone:dark_matter",
    })

    for _, matter in ipairs({"dark", "red"}) do
        for _, type in ipairs({"helmet", "chestplate", "leggings", "boots"}) do
            minetest.override_item("exchangeclone:"..type.."_"..matter.."_matter", {
                inventory_image = get_armor_texture("inv_"..type, matter),
                wield_image = get_armor_texture("inv_"..type, matter),
            })
        end
    end

    mcl_damage.register_modifier(function(obj, damage, reason)
        local blocked = blocked_damage_types[reason.type]
        local inv = mcl_util.get_inventory(obj)
        if inv then
            local armor_pieces = 0
            local red_armor_pieces = 0
            for name, element in pairs(mcl_armor.elements) do
                local itemstack = inv:get_stack("armor", element.index)
                if not itemstack:is_empty() then
                    if minetest.get_item_group(itemstack:get_name(), "dark_matter_armor") > 0 then
                        armor_pieces = armor_pieces + 1
                    elseif minetest.get_item_group(itemstack:get_name(), "red_matter_armor") > 0 then
                        armor_pieces = armor_pieces + 1
                        red_armor_pieces = red_armor_pieces + 1
                    end
                end
            end
            if armor_pieces >= 4 then
                if blocked then
                    if blocked == true then
                        return 0
                    else
                        return (blocked[1] + blocked[2]*red_armor_pieces) * damage
                    end
                end
            end
        end
    end)
else
    armor:register_armor("exchangeclone:helmet_dark_matter", {
        description = "Dark Matter Helmet",
        texture = get_armor_texture("helmet","dark"),
        inventory_image = get_armor_texture("inv_helmet","dark"),
        preview = get_armor_texture("helmet","dark", true),
        armor_groups = {fleshy = 13},
        groups = {armor_head = 1, dark_matter_armor = 1, armor_heal = 5, armor_fire = 1, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:chestplate_dark_matter", {
        description = "Dark Matter Chestplate",
        texture = get_armor_texture("chestplate","dark"),
        inventory_image = get_armor_texture("inv_chestplate","dark"),
        preview = get_armor_texture("chestplate","dark", true),
        armor_groups = {fleshy = 21},
        groups = {armor_torso = 1, dark_matter_armor = 1, armor_heal = 8, armor_fire = 2, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:leggings_dark_matter", {
        description = "Dark Matter Leggings",
        texture = get_armor_texture("leggings","dark"),
        inventory_image = get_armor_texture("inv_leggings","dark"),
        preview = get_armor_texture("leggings","dark", true),
        armor_groups = {fleshy = 18},
        groups = {armor_legs = 1, dark_matter_armor = 1, armor_heal = 7, armor_fire = 1, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:boots_dark_matter", {
        description = "Dark Matter Boots",
        texture = get_armor_texture("boots","dark"),
        inventory_image = get_armor_texture("inv_boots","dark"),
        preview = get_armor_texture("boots","dark", true),
        armor_groups = {fleshy = 10},
        groups = {armor_feet = 1, dark_matter_armor = 1, armor_heal = 4, armor_fire = 1, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:shield_dark_matter", {
        description = "Dark Matter Shield",
        texture = get_armor_texture("shield","dark"),
        inventory_image = get_armor_texture("inv_shield","dark"),
        preview = get_armor_texture("shield","dark", true),
        armor_groups = {fleshy = 18},
        groups = {armor_shield = 1, dark_matter_armor = 1, armor_heal = 7, armor_fire = 1, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:helmet_red_matter", {
        description = "Red Matter Helmet",
        texture = get_armor_texture("helmet","red"),
        inventory_image = get_armor_texture("inv_helmet","red"),
        preview = get_armor_texture("helmet","red", true),
        armor_groups = {fleshy = 15},
        groups = {armor_head = 1, red_matter_armor = 1, armor_heal = 10, armor_fire = 2, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:chestplate_red_matter", {
        description = "Red Matter Chestplate",
        texture = get_armor_texture("chestplate","red"),
        inventory_image = get_armor_texture("inv_chestplate","red"),
        preview = get_armor_texture("chestplate","red", true),
        armor_groups = {fleshy = 23},
        groups = {armor_torso = 1, red_matter_armor = 1, armor_heal = 16, armor_fire = 2, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:leggings_red_matter", {
        description = "Red Matter Leggings",
        texture = get_armor_texture("leggings","red"),
        inventory_image = get_armor_texture("inv_leggings","red"),
        preview = get_armor_texture("leggings","red", true),
        armor_groups = {fleshy = 20},
        groups = {armor_legs = 1, red_matter_armor = 1, armor_heal = 14, armor_fire = 2, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:boots_red_matter", {
        description = "Red Matter Boots",
        texture = get_armor_texture("boots","red"),
        inventory_image = get_armor_texture("inv_boots","red"),
        preview = get_armor_texture("boots","red", true),
        armor_groups = {fleshy = 12},
        groups = {armor_feet = 1, red_matter_armor = 1, armor_heal = 8, armor_fire = 2, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:shield_red_matter", {
        description = "Red Matter Shield",
        texture = get_armor_texture("shield","red"),
        inventory_image = get_armor_texture("inv_shield","red"),
        preview = get_armor_texture("shield","red", true),
        armor_groups = {fleshy = 20},
        groups = {armor_shield = 1, red_matter_armor = 1, armor_heal = 14, armor_fire = 2, armor_water = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
end
local d = "exchangeclone:dark_matter"
local r = "exchangeclone:red_matter"
minetest.register_craft({
    output = "exchangeclone:helmet_dark_matter",
    recipe = {
        {d,d,d},
        {d,"",d}
    }
})
minetest.register_craft({
    output = "exchangeclone:chestplate_dark_matter",
    recipe = {
        {d,"",d},
        {d,d,d},
        {d,d,d},
    }
})
minetest.register_craft({
    output = "exchangeclone:leggings_dark_matter",
    recipe = {
        {d,d,d},
        {d,"",d},
        {d,"",d},
    }
})
minetest.register_craft({
    output = "exchangeclone:boots_dark_matter",
    recipe = {
        {d,"",d},
        {d,"",d},
    }
})
minetest.register_craft({
    output = "exchangeclone:helmet_red_matter",
    recipe = {
        {r,r,r},
        {r,"exchangeclone:helmet_dark_matter",r}
    }
})
minetest.register_craft({
    output = "exchangeclone:chestplate_red_matter",
    recipe = {
        {r,"exchangeclone:chestplate_dark_matter",r},
        {r,r,r},
        {r,r,r},
    }
})
minetest.register_craft({
    output = "exchangeclone:leggings_red_matter",
    recipe = {
        {r,r,r},
        {r,"exchangeclone:leggings_dark_matter",r},
        {r,"",r},
    }
})
minetest.register_craft({
    output = "exchangeclone:boots_red_matter",
    recipe = {
        {r,"exchangeclone:boots_dark_matter",r},
        {r,"",r},
    }
})
if minetest.get_modpath("3d_armor") then
    minetest.register_craft({
        output = "exchangeclone:shield_dark_matter",
        recipe = {
            {d,d,d},
            {d,d,d},
            {"",d,""},
        }
    })
    minetest.register_craft({
        output = "exchangeclone:shield_red_matter",
        recipe = {
            {r,r,r},
            {r,r,r},
            {"exchangeclone:shield_dark_matter",r,""},
        }
    })
end