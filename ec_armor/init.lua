if not (core.get_modpath("3d_armor") or core.get_modpath("mcl_armor")) then return end

local S = core.get_translator()

local armor_pieces = {
    ["ec_armor:helmet_dark_matter"] = { material = "dark_matter", piece = "helmet", category = "weak" },
    ["ec_armor:chestplate_dark_matter"] = { material = "dark_matter", piece = "chestplate", category = "strong" },
    ["ec_armor:leggings_dark_matter"] = { material = "dark_matter", piece = "leggings", category = "strong" },
    ["ec_armor:boots_dark_matter"] = { material = "dark_matter", piece = "boots", category = "weak" },
    ["ec_armor:helmet_red_matter"] = { material = "red_matter", piece = "helmet", category = "weak" },
    ["ec_armor:chestplate_red_matter"] = { material = "red_matter", piece = "chestplate", category = "strong" },
    ["ec_armor:leggings_red_matter"] = { material = "red_matter", piece = "leggings", category = "strong" },
    ["ec_armor:boots_red_matter"] = { material = "red_matter", piece = "boots", category = "weak" },
}

local armor_categories = {
    weak = { dark_matter = exchangeclone.mcl and 0.16 or 0.13, red_matter = exchangeclone.mcl and 0.18 or 0.15 },
    strong = { dark_matter = exchangeclone.mcl and 0.24 or 0.18, red_matter = exchangeclone.mcl and 0.27 or 0.2 }
}

local modifiers = {
    dark = "^[hsl:0:-100:-80",
    red = "^[multiply:#bb0033"
}

local function damage_formula(armor_data, damage, reason)
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
        return damage - (first_value + ((damage - 1) * ((0.03 * (damage) / 2) + first_value)))
    else
        return damage * 0.05 -- Not exact (some armor pieces are 3%, some are 7%, but I don't care)
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
        return base_block * damage
    elseif reason.type == "explosion" or reason.type == "anvil" or (exchangeclone.mcl and reason.flags.is_projectile) then
        return damage_formula(armor_data, damage, reason)
    elseif reason.type == "drown" then
        if armor_data.piece == "helmet" then
            if damage < 10 then
                return 2
            end
        end
        return base_block * damage
    end
    return base_block * damage
end

-- Reset health (old versions increased HP with full RM armor)
function exchangeclone.check_armor_health(obj)
    if obj:get_meta():get_int("exchangeclone_red_matter_armor") == 1 then
        obj:set_hp(math.min(obj:get_hp(), 20))
        obj:set_properties({ hp_max = 20 })
        obj:get_meta():set_int("exchangeclone_red_matter_armor", 0)
    end
end

core.register_on_joinplayer(function(ObjectRef, last_login)
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
            head = "exchangeclone_dark_matter_helmet.png",
            torso = "exchangeclone_dark_matter_chestplate.png",
            legs = "exchangeclone_dark_matter_leggings.png",
            feet = "exchangeclone_dark_matter_boots.png",
        },
        toughness = 4,
        groups = { dark_matter_armor = 1, fire_immune = 1, exchangeclone_upgradable = 1 },
        craft_material = "ec_matter:dark_matter",
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
            head = "exchangeclone_red_matter_helmet.png",
            torso = "exchangeclone_red_matter_chestplate.png",
            legs = "exchangeclone_red_matter_leggings.png",
            feet = "exchangeclone_red_matter_boots.png",
        },
        toughness = 5,
        groups = { red_matter_armor = 1, disable_repair = 1, fire_immune = 1, exchangeclone_upgradable = 1 },
        craft_material = "ec_matter:red_matter",
        cook_material = "ec_matter:dark_matter",
        sound_equip = "mcl_armor_equip_diamond",
        sound_unequip = "mcl_armor_unequip_diamond",
    })

    -- for _, matter in pairs({ "dark", "red" }) do
    --     for _, piece in pairs({ "helmet", "chestplate", "leggings", "boots" }) do
    --         core.override_item("ec_armor:" .. piece .. "_" .. matter .. "_matter", {
    --             inventory_image = "exchangeclone_inv_" .. piece .. ".png"..modifiers[matter],
    --         })
    --     end
    -- end

    mcl_damage.register_modifier(function(obj, damage, reason)
        if not obj:is_player() then return end
        local inv = mcl_util.get_inventory(obj)
        local blocked = 0
        if inv then
            for name, element in pairs(mcl_armor.elements) do
                local itemstack = inv:get_stack("armor", element.index)
                local item_blocked = math.max(0, get_blocked_damage(itemstack, damage, reason))
                blocked = blocked + item_blocked
            end
            return math.max(0, damage - blocked)
        end
    end, -100)
else
    for _, matter in pairs({ "Dark", "Red" }) do
        for piece, place in pairs({ Helmet = "head", Chestplate = "torso", Leggings = "legs", Boots = "feet" }) do
            local matter_lower = matter:lower()
            local piece_lower = piece:lower()
            armor:register_armor("ec_armor:" .. piece_lower .. "_" .. matter_lower .. "_matter", {
                description = S("@1 Matter @2", matter, piece),
                texture = "exchangeclone_" .. matter_lower .. "_matter_" .. piece_lower .. ".png",
                inventory_image = "exchangeclone_inv_"  .. piece_lower .. ".png"..modifiers[matter_lower],
                groups = { ["armor_" .. place] = 1, [matter_lower .. "_matter_armor"] = 1, disable_repair = 1, exchangeclone_upgradable = 1 }
            })
        end
    end

    core.register_on_player_hpchange(function(player, hp_change, reason)
        core.log("[EC Debug] Original HP change: " .. hp_change)
        if hp_change < 0 then
            local damage = -hp_change
            local _, armor_inv = armor:get_valid_player(player, "3d_armor")
            local blocked = 0
            for i = 1, #armor_inv:get_list("armor") do
                local itemstack = armor_inv:get_stack("armor", i)
                blocked = blocked + get_blocked_damage(itemstack, damage, reason)
            end
            return -math.max(0, damage - blocked)
        else
            return hp_change
        end
    end, true)
end

local d = "ec_matter:dark_matter"
local r = "ec_matter:red_matter"
core.register_craft({
    output = "ec_armor:helmet_dark_matter",
    recipe = {
        { d, d,  d },
        { d, "", d }
    }
})
core.register_craft({
    output = "ec_armor:chestplate_dark_matter",
    recipe = {
        { d, "", d },
        { d, d,  d },
        { d, d,  d },
    }
})
core.register_craft({
    output = "ec_armor:leggings_dark_matter",
    recipe = {
        { d, d,  d },
        { d, "", d },
        { d, "", d },
    }
})
core.register_craft({
    output = "ec_armor:boots_dark_matter",
    recipe = {
        { d, "", d },
        { d, "", d },
    }
})
core.register_craft({
    output = "ec_armor:helmet_red_matter",
    recipe = {
        { r, r,                                  r },
        { r, "ec_armor:helmet_dark_matter", r }
    }
})
core.register_craft({
    output = "ec_armor:chestplate_red_matter",
    recipe = {
        { r, "ec_armor:chestplate_dark_matter", r },
        { r, r,                                      r },
        { r, r,                                      r },
    }
})
core.register_craft({
    output = "ec_armor:leggings_red_matter",
    recipe = {
        { r, r,                                    r },
        { r, "ec_armor:leggings_dark_matter", r },
        { r, "",                                   r },
    }
})
core.register_craft({
    output = "ec_armor:boots_red_matter",
    recipe = {
        { r, "ec_armor:boots_dark_matter", r },
        { r, "",                                r },
    }
})

for piece, _ in pairs(armor_pieces) do
    core.register_alias("exchangeclone"..piece:sub(9), piece)
end