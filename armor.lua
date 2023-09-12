local blocked_damage_types = {
    drown = true,
    lava = true,
    in_fire = true,
    on_fire = true,
    hot_floor = true,
}

local function get_armor_texture(type, matter, preview)
    local modifier = ""
    -- hsl only works in 5.8 which hasn't been released yet
    if matter == "dark" then
        modifier = "^[multiply:#222222"
        --modifier = "^[hsl:0:-100:-100^[hsl:0:-100:-100"
    else
        modifier = "^[multiply:#990000"
        --modifier = "^[hsl:-180:100:-100"
    end
    local result
    if exchangeclone.mineclone then
        result = "exchangeclone_mcl_"..type.."_base.png"..modifier
    else
        result = "exchangeclone_mtg_"..type.."_base"
        if preview then result = result.."_preview" end
        result = result..".png"..modifier
    end
    --minetest.log(result)
    return result
end

function exchangeclone.check_armor_health(obj)
    local max_armor = 5
    local armor_pieces = 0
    if exchangeclone.mineclone then
        max_armor = 4
        local inv = mcl_util.get_inventory(obj)
        if inv then
            for name, element in pairs(mcl_armor.elements) do
                local itemstack = inv:get_stack("armor", element.index)
                if not itemstack:is_empty() then
                    if minetest.get_item_group(itemstack:get_name(), "red_matter_armor") > 0 then
                        armor_pieces = armor_pieces + 1
                    end
                end
            end
        end
    else
        local name, armor_inv = armor:get_valid_player(obj, "[checking for red matter]")
        if not armor_inv then minetest.log("Inventory is nil") return end
        local list = armor_inv:get_list("armor")
        if type(list) ~= "table" then
            return
        end
        for i, stack in ipairs(list) do
            if stack:get_count() == 1 then
                if minetest.get_item_group(stack:get_name(), "red_matter_armor") > 0  then
                    armor_pieces = armor_pieces + 1
                end
            end
        end
    end
    local already_has_health = 0
    if obj:is_player() then
        already_has_health = obj:get_meta():get_int("exchangeclone_red_matter_armor") or 0
    end
    if armor_pieces >= max_armor then
        obj:set_properties({hp_max = 2000})
        if already_has_health == 0 then
            -- fix this if MineCraft changes to max_hp instead of hardcoding 20
            obj:set_hp(2000-math.max(20-obj:get_hp(), 0))
            obj:get_meta():set_int("exchangeclone_red_matter_armor", 1)
        end
    else
        if already_has_health == 1 then
            obj:set_hp(math.min(obj:get_hp(), 20))
            obj:set_properties({hp_max = 20})
            obj:get_meta():set_int("exchangeclone_red_matter_armor", 0)
        end
    end
end

minetest.register_on_joinplayer(function(ObjectRef, last_login)
    exchangeclone.check_armor_health(ObjectRef)
end)

minetest.register_on_respawnplayer(function(ObjectRef)
    exchangeclone.check_armor_health(ObjectRef)
end)

if exchangeclone.mineclone then
    mcl_armor.register_set({
        name = "dark_matter",
        description = "Dark Matter",
        durability = -1,
        enchantability = 0,
        points = {
            head = 5,
            torso = 8,
            legs = 7,
            feet = 4,
        },
        textures = {
            head = get_armor_texture("helmet","dark"),
            torso = get_armor_texture("chestplate","dark"),
            legs = get_armor_texture("leggings","dark"),
            feet = get_armor_texture("boots","dark"),
        },
        toughness = 4,
        groups = {dark_matter_armor = 1, fire_immune = 1},
        craft_material = "exchangeclone:dark_matter",
        cook_material = "mcl_core:diamondblock",
    })
    mcl_armor.register_set({
        name = "red_matter",
        description = "Red Matter",
        durability = -1,
        enchantability = 0,
        points = {
            head = 7,
            torso = 12,
            legs = 8,
            feet = 5,
        },
        textures = {
            head = get_armor_texture("helmet","red"),
            torso = get_armor_texture("chestplate","red"),
            legs = get_armor_texture("leggings","red"),
            feet = get_armor_texture("boots","red"),
        },
        toughness = 5,
        groups = {red_matter_armor = 1, fire_immune = 1},
        craft_material = "exchangeclone:red_matter",
        cook_material = "exchangeclone:dark_matter",
        on_equip_callbacks = {
            head=exchangeclone.check_armor_health,
            torso=exchangeclone.check_armor_health,
            legs=exchangeclone.check_armor_health,
            feet=exchangeclone.check_armor_health
        },
        on_unequip_callbacks = {
            head=exchangeclone.check_armor_health,
            torso=exchangeclone.check_armor_health,
            legs=exchangeclone.check_armor_health,
            feet=exchangeclone.check_armor_health
        }
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
        if reason.type == "fall" then
            return damage/5
        elseif not blocked_damage_types[reason.type] then return end
        local inv = mcl_util.get_inventory(obj)
        if inv then
            local armor_pieces = 0
            for name, element in pairs(mcl_armor.elements) do
                local itemstack = inv:get_stack("armor", element.index)
                if not itemstack:is_empty() then
                    if minetest.get_item_group(itemstack:get_name(), "dark_matter_armor") > 0
                    or minetest.get_item_group(itemstack:get_name(), "red_matter_armor") > 0 then
                        armor_pieces = armor_pieces + 1
                    end
                end
            end
            if armor_pieces >= 4 then
                return 0
            end
        end
    end, 0)
else
    armor:register_armor("exchangeclone:helmet_dark_matter", {
        description = "Dark Matter Helmet",
        texture = get_armor_texture("helmet","dark"),
        inventory_image = get_armor_texture("inv_helmet","dark"),
        preview = get_armor_texture("helmet","dark", true),
        armor_groups = {fleshy = 13},
        groups = {["armor_head"] = 1, ["dark_matter_armor"] = 1, armor_heal = 5, armor_fire = 1, armor_water = 1}
    })
    armor:register_armor("exchangeclone:chestplate_dark_matter", {
        description = "Dark Matter Chestplate",
        texture = get_armor_texture("chestplate","dark"),
        inventory_image = get_armor_texture("inv_chestplate","dark"),
        preview = get_armor_texture("chestplate","dark", true),
        armor_groups = {fleshy = 21},
        groups = {["armor_torso"] = 1, ["dark_matter_armor"] = 1, armor_heal = 8, armor_fire = 2, armor_water = 1}
    })
    armor:register_armor("exchangeclone:leggings_dark_matter", {
        description = "Dark Matter Leggings",
        texture = get_armor_texture("leggings","dark"),
        inventory_image = get_armor_texture("inv_leggings","dark"),
        preview = get_armor_texture("leggings","dark", true),
        armor_groups = {fleshy = 18},
        groups = {["armor_legs"] = 1, ["dark_matter_armor"] = 1, armor_heal = 7, armor_fire = 1, armor_water = 1}
    })
    armor:register_armor("exchangeclone:boots_dark_matter", {
        description = "Dark Matter Boots",
        texture = get_armor_texture("boots","dark"),
        inventory_image = get_armor_texture("inv_boots","dark"),
        preview = get_armor_texture("boots","dark", true),
        armor_groups = {fleshy = 10},
        groups = {["armor_feet"] = 1, ["dark_matter_armor"] = 1, armor_heal = 4, armor_fire = 1, armor_water = 1, armor_feather = 1}
    })
    armor:register_armor("exchangeclone:shield_dark_matter", {
        description = "Dark Matter Shield",
        texture = get_armor_texture("shield","dark"),
        inventory_image = get_armor_texture("inv_shield","dark"),
        preview = get_armor_texture("shield","dark", true),
        armor_groups = {fleshy = 18},
        groups = {["armor_shield"] = 1, ["dark_matter_armor"] = 1, armor_heal = 7, armor_fire = 1, armor_water = 1}
    })
    armor:register_armor("exchangeclone:helmet_red_matter", {
        description = "Red Matter Helmet",
        texture = get_armor_texture("helmet","red"),
        inventory_image = get_armor_texture("inv_helmet","red"),
        preview = get_armor_texture("helmet","red", true),
        armor_groups = {fleshy = 15},
        groups = {["armor_head"] = 1, ["red_matter_armor"] = 1, armor_heal = 10, armor_fire = 2, armor_water = 1}
    })
    armor:register_armor("exchangeclone:chestplate_red_matter", {
        description = "Red Matter Chestplate",
        texture = get_armor_texture("chestplate","red"),
        inventory_image = get_armor_texture("inv_chestplate","red"),
        preview = get_armor_texture("chestplate","red", true),
        armor_groups = {fleshy = 23},
        groups = {["armor_torso"] = 1, ["red_matter_armor"] = 1, armor_heal = 16, armor_fire = 2, armor_water = 1}
    })
    armor:register_armor("exchangeclone:leggings_red_matter", {
        description = "Red Matter Leggings",
        texture = get_armor_texture("leggings","red"),
        inventory_image = get_armor_texture("leggings","red"),
        preview = get_armor_texture("leggings","red", true),
        armor_groups = {fleshy = 20},
        groups = {["armor_legs"] = 1, ["red_matter_armor"] = 1, armor_heal = 14, armor_fire = 2, armor_water = 1, armor_feather = 1}
    })
    armor:register_armor("exchangeclone:boots_red_matter", {
        description = "Red Matter Boots",
        texture = get_armor_texture("boots","red"),
        inventory_image = get_armor_texture("boots","red"),
        preview = get_armor_texture("boots","red", true),
        armor_groups = {fleshy = 12},
        groups = {["armor_feet"] = 1, ["red_matter_armor"] = 1, armor_heal = 8, armor_fire = 2, armor_water = 1, armor_feather = 1}
    })
    armor:register_armor("exchangeclone:shield_red_matter", {
        description = "Red Matter Shield",
        texture = get_armor_texture("shield","red"),
        inventory_image = get_armor_texture("shield","red"),
        preview = get_armor_texture("shield","red", true),
        armor_groups = {fleshy = 20},
        groups = {["armor_shield"] = 1, ["red_matter_armor"] = 1, armor_heal = 14, armor_fire = 2, armor_water = 1}
    })
    armor:register_on_equip(function(player, index, stack)
        exchangeclone.check_armor_health(player)
    end)
    
    armor:register_on_unequip(function(player, index, stack)
        exchangeclone.check_armor_health(player)
    end)
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
            {d,d,d},
            {d,d,d},
            {"exchangeclone:shield_dark_matter",d,""},
        }
    })
end