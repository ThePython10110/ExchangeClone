local S = minetest.get_translator()

local function get_armor_texture(type, matter, preview)
    local modifier
    -- hsl unfortunately only works in 5.8
    if matter == "dark" then
        modifier = "^[multiply:#222222"
        --modifier = "^[hsl:0:-100:-100^[hsl:0:-100:-100"
    else
        modifier = "^[multiply:#990000"
        --modifier = "^[hsl:-180:100:-100"
    end
    local result
    if type:sub(1,3) == "inv" then
        result = "exchangeclone_"..type..".png"
    elseif exchangeclone.mcl then
        result = "exchangeclone_mcl_"..type.."_base.png"..modifier
    else
        result = "exchangeclone_mtg_"..type.."_base"
        if preview then result = result.."_preview" end
        result = result..".png"..modifier
    end
    return result
end

local armor_pieces = {
    ["exchangeclone:helmet_dark_matter"] = {material = "dark_matter", piece = "helmet", category = "weak"},
    ["exchangeclone:helmet_red_matter"] = {material = "red_matter", piece = "helmet", category = "weak"},
    ["exchangeclone:chestplate_dark_matter"] = {material = "dark_matter", piece = "chestplate", category = "strong"},
    ["exchangeclone:chestplate_red_matter"] = {material = "red_matter", piece = "chestplate", category = "strong"},
    ["exchangeclone:leggings_dark_matter"] = {material = "dark_matter", piece = "leggings", category = "strong"},
    ["exchangeclone:leggings_red_matter"] = {material = "red_matter", piece = "leggings", category = "strong"},
    ["exchangeclone:boots_dark_matter"] = {material = "dark_matter", piece = "boots", category = "weak"},
    ["exchangeclone:boots_red_matter"] = {material = "red_matter", piece = "boots", category = "weak"},
}

local armor_categories = {
    weak = {dark_matter = exchangeclone.mcl and 0.16 or 0.13, red_matter = exchangeclone.mcl and 0.18 or 0.15},
    strong = {dark_matter = exchangeclone.mcl and 0.24 or 0.18, red_matter = exchangeclone.mcl and 0.27 or 0.2}
}

local function a_damage_formula(armor_data, damage, reason)
    local start
    local threshold
    local first_value
    if armor_data.material == "dark_matter" then
        if armor_data.category == "weak" then
            if reason.type == "explosion" then
                start = 70
            else
                start = 20
            end
            threshold = start + 6
            first_value = 0.9
        else
            if reason.type == "explosion" then
                start = 105
            else
                start = 45
            end
            threshold = start + 16
            first_value = 0.7
        end
    else
        if armor_data.category == "weak" then
            if reason.type == "explosion" then
                start = 100
            else
                start = 50
            end
            threshold = start + 6
            first_value = 0.9
        else
            if reason.type == "explosion" then
                start = 150
                threshold = 162
                first_value = 0.78
            else
                start = 70
                threshold = 76
                first_value = 0.9
            end
        end
    end
    if damage < start then
        return damage
    elseif damage <= threshold then
        -- This formula took me unnecessarily long to figure out.
        return damage-(first_value+((damage-1)*((0.03*(damage)/2)+first_value)))
    else
        return damage*0.05 -- Not exact (some armor pieces are 3%, some are 7%, but I don't care)
    end
end

local function get_blocked_damage(itemstack, damage, reason)

    local armor_data = armor_pieces[itemstack:get_name()]
    if not armor_data then return 0 end
    local base_block = armor_categories[armor_data.category][armor_data.material]
    if reason.type == "lava" then
        return damage
    elseif reason.type == "fall" then
        if armor_data.piece == "boots" then
            if armor_data.material == "dark_matter" then
                if damage < 31 then
                    return 5
                end
            elseif damage < 55 then
                return 10
            end
        end
        return base_block*damage
    elseif reason.type == "explosion" or reason.type == "anvil" or reason.flags.is_projectile then
        return a_damage_formula(armor_data, damage, reason)
    elseif reason.type == "drown" then
        if armor_data.piece == "helmet" then
            if damage < 10 then
                return 2
            end
        end
        return base_block*damage
    end
    return base_block*damage
end

-- Reset health (old versions increased HP with full RM armor)
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
        descriptions = exchangeclone.mcla and {
            head = S("Dark Matter Helmet"),
            torso = S("Dark Matter Chestplate"),
            legs = S("Dark Matter Leggings"),
            feet = S("Dark Matter Boots")
        },
        durability = -1,
        enchantability = 0,
        -- No armor points because I don't want MCL's armor code messing up the math.
        points = {
            head = 0,
            torso = 0,
            legs = 0,
            feet = 0,
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
        sound_equip = "mcl_armor_equip_diamond",
        sound_unequip = "mcl_armor_unequip_diamond",
    })
    mcl_armor.register_set({
        name = "red_matter",
        description = "Red Matter",
        descriptions = exchangeclone.mcla and {
            head = S("Red Matter Helmet"),
            torso = S("Red Matter Chestplate"),
            legs = S("Red Matter Leggings"),
            feet = S("Red Matter Boots")
        },
        durability = -1,
        enchantability = 0,
        -- No armor points because I don't want MCL's armor code messing up the math.
        points = {
            head = 0,
            torso = 0,
            legs = 0,
            feet = 0,
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
        sound_equip = "mcl_armor_equip_diamond",
        sound_unequip = "mcl_armor_unequip_diamond",
    })

    for _, matter in pairs({"dark", "red"}) do
        for _, type in pairs({"helmet", "chestplate", "leggings", "boots"}) do
            minetest.override_item("exchangeclone:"..type.."_"..matter.."_matter", {
                inventory_image = get_armor_texture("inv_"..matter.."_matter_"..type, matter),
                wield_image = get_armor_texture("inv_"..type, matter),
            })
        end
    end

    -- Until Minetest fixes an issue, there's no way to make this work correctly.
    mcl_damage.register_modifier(function(obj, damage, reason)
        local start_time = minetest.get_us_time()
        if not obj:is_player() then return end
        local inv = mcl_util.get_inventory(obj)
        local blocked = 0
        if inv then
            for name, element in pairs(mcl_armor.elements) do
                local itemstack = inv:get_stack("armor", element.index)
                local item_blocked = math.max(0,get_blocked_damage(itemstack, damage, reason))
                blocked = blocked + item_blocked
                minetest.log(dump({name, item_blocked}))
            end
            minetest.log(((minetest.get_us_time() - start_time)/1000).." milliseconds")
            return math.max(0, damage - blocked)
        end
    end, -100)
else
    armor:register_armor("exchangeclone:helmet_dark_matter", {
        description = S("Dark Matter Helmet"),
        texture = get_armor_texture("helmet","dark"),
        inventory_image = get_armor_texture("inv_helmet","dark"),
        preview = get_armor_texture("helmet","dark", true),
        groups = {armor_head = 1, dark_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:chestplate_dark_matter", {
        description = S("Dark Matter Chestplate"),
        texture = get_armor_texture("chestplate","dark"),
        inventory_image = get_armor_texture("inv_chestplate","dark"),
        preview = get_armor_texture("chestplate","dark", true),
        groups = {armor_torso = 1, dark_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:leggings_dark_matter", {
        description = S("Dark Matter Leggings"),
        texture = get_armor_texture("leggings","dark"),
        inventory_image = get_armor_texture("inv_leggings","dark"),
        preview = get_armor_texture("leggings","dark", true),
        groups = {armor_legs = 1, dark_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:boots_dark_matter", {
        description = S("Dark Matter Boots"),
        texture = get_armor_texture("boots","dark"),
        inventory_image = get_armor_texture("inv_boots","dark"),
        preview = get_armor_texture("boots","dark", true),
        groups = {armor_feet = 1, dark_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1, armor_feather = 1}
    })
    armor:register_armor("exchangeclone:helmet_red_matter", {
        description = S("Red Matter Helmet"),
        texture = get_armor_texture("helmet","red"),
        inventory_image = get_armor_texture("inv_helmet","red"),
        preview = get_armor_texture("helmet","red", true),
        groups = {armor_head = 1, red_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:chestplate_red_matter", {
        description = S("Red Matter Chestplate"),
        texture = get_armor_texture("chestplate","red"),
        inventory_image = get_armor_texture("inv_chestplate","red"),
        preview = get_armor_texture("chestplate","red", true),
        groups = {armor_torso = 1, red_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:leggings_red_matter", {
        description = S("Red Matter Leggings"),
        texture = get_armor_texture("leggings","red"),
        inventory_image = get_armor_texture("inv_leggings","red"),
        preview = get_armor_texture("leggings","red", true),
        groups = {armor_legs = 1, red_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    armor:register_armor("exchangeclone:boots_red_matter", {
        description = S("Red Matter Boots"),
        texture = get_armor_texture("boots","red"),
        inventory_image = get_armor_texture("inv_boots","red"),
        preview = get_armor_texture("boots","red", true),
        groups = {armor_feet = 1, red_matter_armor = 1, disable_repair = 1, exchangeclone_upgradable = 1}
    })
    minetest.register_on_player_hpchange(function(player, hp_change, reason)
        if hp_change < 0 then
            local _, armor_inv = armor:get_valid_player(player, "3d_armor")
            local blocked = 0
            for i = 1, 6 do
                local itemstack = armor_inv:get_stack("armor", i)
                blocked = blocked + get_blocked_damage(itemstack, hp_change, reason)
            end
            return math.max(0, hp_change - blocked)
        else
            return hp_change
        end
    end, true)
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

if exchangeclone.mtg then
    minetest.register_tool("exchangeclone:shield_dark_matter", {
        description = "Dark Matter Shield (deprecated)\nYou still have this so you can turn it into EMC.\nAnd no, it's not supposed to have a texture.",
        groups = {disable_repair = 1, not_in_creative_inventory = 1}
    })
    exchangeclone.register_craft({
        output = "exchangeclone:shield_dark_matter",
        type = "shapeless",
        recipe = {
            "exchangeclone:dark_matter",
            "exchangeclone:dark_matter",
            "exchangeclone:dark_matter",
            "exchangeclone:dark_matter",
            "exchangeclone:dark_matter",
            "exchangeclone:dark_matter",
            "exchangeclone:dark_matter",
        }
    })

    minetest.register_tool("exchangeclone:shield_red_matter", {
        description = "Red Matter Shield (deprecated)\nYou still have this so you can turn it into EMC.\nAnd no, it's not supposed to have a texture.",
        groups = {disable_repair = 1, not_in_creative_inventory = 1}
    })
    exchangeclone.register_craft({
        output = "exchangeclone:shield_red_matter",
        type = "shapeless",
        recipe = {
            "exchangeclone:shield_dark_matter",
            "exchangeclone:red_matter",
            "exchangeclone:red_matter",
            "exchangeclone:red_matter",
            "exchangeclone:red_matter",
            "exchangeclone:red_matter",
            "exchangeclone:red_matter",
        }
    })
end