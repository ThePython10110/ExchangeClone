local function heal(player, amount)
    local hp_max = player:get_properties().hp_max
    local current_hp = player:get_hp()
    if current_hp < hp_max then
        player:set_hp(math.min(current_hp + amount, hp_max), { type = "set_hp", other = "healing" })
        return true
    end
end

local satiate = nil

if exchangeclone.mcl then
    if mcl_hunger.active then
        satiate = function(player, amount)
            local hunger = mcl_hunger.get_hunger(player)
            if hunger < 20 then
                mcl_hunger.set_hunger(player, hunger + amount)
                mcl_hunger.set_saturation(player, hunger + amount)
                return true
            end
        end
    end
elseif exchangeclone.mtg then
    if minetest.get_modpath("stamina") then
        satiate = function(player, amount)
            if stamina.get_saturation(player) < stamina.settings.visual_max then
                stamina.change_saturation(player, amount)
                return true
            end
        end
    end
else
    assert(exchangeclone.exile)
    -- FIXME: implement satiate()
end

minetest.register_tool("exchangeclone:soul_stone", {
    description = "Soul Stone",
    inventory_image = "exchangeclone_soul_stone.png",
    _exchangeclone_passive = {
        func = function(player)
            if player:_get_emc() >= 64 then
                if heal(player, 2) then
                    player:_add_emc(-64)
                end
            end
        end,
        hotbar = true,
        active_image = "exchangeclone_soul_stone_active.png",
        exclude = {"exchangeclone:life_stone"}
    },
    _exchangeclone_pedestal = function(pos)
        for _, object in pairs(minetest.get_objects_inside_radius(pos, 5)) do
            if object:is_player() then
                heal(object, 2)
            end
        end
    end,
    on_secondary_use = exchangeclone.toggle_active,
    on_place = exchangeclone.toggle_active,
    groups = {exchangeclone_passive = 1, disable_repair = 1}
})
minetest.register_craft({
    output = "exchangeclone:soul_stone",
    recipe = {
        {exchangeclone.itemstrings.glowstoneworth, exchangeclone.itemstrings.glowstoneworth, exchangeclone.itemstrings.glowstoneworth},
        {"exchangeclone:red_matter", exchangeclone.itemstrings.lapisworth, "exchangeclone:red_matter"},
        {exchangeclone.itemstrings.glowstoneworth, exchangeclone.itemstrings.glowstoneworth, exchangeclone.itemstrings.glowstoneworth},
    }
})

if satiate then
    minetest.register_tool("exchangeclone:body_stone", {
        description = "Body Stone",
        inventory_image = "exchangeclone_body_stone.png",
        _exchangeclone_passive = {
            func = function(player)
                if player:_get_emc() >= 64 then
                    if satiate(player, 2) then
                        player:_add_emc(-64)
                    end
                end
            end,
            hotbar = true,
            active_image = "exchangeclone_body_stone_active.png",
            exclude = {"exchangeclone:life_stone"}
        },
        _exchangeclone_pedestal = function(pos)
            for _, object in pairs(minetest.get_objects_inside_radius(pos, 5)) do
                if object:is_player() then
                    satiate(object, 2)
                end
            end
        end,
        on_secondary_use = exchangeclone.toggle_active,
        on_place = exchangeclone.toggle_active,
        groups = {exchangeclone_passive = 1, disable_repair = 1}
    })

    local sugar_ingredient = exchangeclone.itemstrings.sugar
    minetest.register_craft({
        output = "exchangeclone:body_stone",
        recipe = {
            {sugar_ingredient, sugar_ingredient, sugar_ingredient},
            {"exchangeclone:red_matter", exchangeclone.itemstrings.lapisworth, "exchangeclone:red_matter"},
            {sugar_ingredient, sugar_ingredient, sugar_ingredient},
        }
    })

    minetest.register_tool("exchangeclone:life_stone", {
        description = "Life Stone",
        inventory_image = "exchangeclone_life_stone.png",
        _exchangeclone_passive = {
            func = function(player)
                if player:_get_emc() >= 64 then
                    local changed
                    if heal(player, 2)  then
                        changed = true
                    end
                    if satiate(player, 2) then
                        changed = true
                    end
                    if changed then
                        player:_add_emc(-64)
                    end
                end
            end,
            hotbar = true,
            active_image = "exchangeclone_life_stone_active.png",
            exclude = {"exchangeclone:body_stone", "exchangeclone:soul_stone"}
        },
        _exchangeclone_pedestal = function(pos)
            for _, object in pairs(minetest.get_objects_inside_radius(pos, 5)) do
                if object:is_player() then
                    heal(object, 2)
                    satiate(object, 2)
                end
            end
        end,
        on_secondary_use = exchangeclone.toggle_active,
        on_place = exchangeclone.toggle_active,
        groups = {exchangeclone_passive = 1, disable_repair = 1},
    })
    minetest.register_craft({
        output = "exchangeclone:life_stone",
        type = "shapeless",
        recipe = {"exchangeclone:soul_stone", "exchangeclone:body_stone"}
    })
end

if exchangeclone.mcl then

    local function get_mind_description(itemstack)
        local meta = itemstack:get_meta()
        local emc = itemstack:_get_emc() or 0
        local stored = meta:get_int("exchangeclone_stored_xp") or 0
        return "Mind Stone\nEMC: "..exchangeclone.format_number(emc).."\nStored XP: "..exchangeclone.format_number(stored)
    end

    local function drain_xp(player, itemstack)
        local meta = itemstack:get_meta()
        local stored = meta:get_int("exchangeclone_stored_xp") or 0
        local player_xp = mcl_experience.get_xp(player)
        meta:set_int("exchangeclone_stored_xp", stored + player_xp)
        mcl_experience.set_xp(player, 0)
        meta:set_string("description", get_mind_description(itemstack))
        return itemstack
    end

    local function mind_action(itemstack, player, pointed_thing)
        local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
        if click_test ~= false then
            return click_test
        end

        local meta = itemstack:get_meta()
        local stored = meta:get_int("exchangeclone_stored_xp") or 0
        if player:get_player_control().aux1 then
            return exchangeclone.toggle_active(itemstack, player, pointed_thing)
        elseif player:get_player_control().sneak then
            local player_xp = mcl_experience.get_xp(player)
            local amount_to_take = math.min(100, player_xp)
            mcl_experience.set_xp(player, player_xp - amount_to_take)
            stored = stored + amount_to_take
            meta:set_int("exchangeclone_stored_xp", stored)
            if stored > 0 then
                meta:set_string("exchangeclone_emc_value", "none")
            else
                meta:set_string("exchangeclone_emc_value", "")
            end
            meta:set_string("description", get_mind_description(itemstack))
            return itemstack
        else
            local player_xp = mcl_experience.get_xp(player)
            local amount_to_take = math.min(100, stored)
            mcl_experience.set_xp(player, player_xp + amount_to_take)
            stored = stored - amount_to_take
            meta:set_int("exchangeclone_stored_xp", stored)
            if stored > 0 then
                meta:set_string("exchangeclone_emc_value", "none")
            else
                meta:set_string("exchangeclone_emc_value", "")
            end
            meta:set_string("description", get_mind_description(itemstack))
            return itemstack
        end
    end

    minetest.register_tool("exchangeclone:mind_stone", {
        description = "Mind Stone",
        inventory_image = "exchangeclone_mind_stone.png",
        _exchangeclone_passive = {
            func = drain_xp,
            hotbar = true,
            active_image = "exchangeclone_mind_stone_active.png",
        },
        on_secondary_use = mind_action,
        on_place = mind_action,
        groups = {exchangeclone_passive = 1, disable_repair = 1},
        _mcl_generate_description = get_mind_description,
        _exchangeclone_pedestal = function(pos, itemstack)
            local meta = itemstack:get_meta()
            for _, object in pairs(minetest.get_objects_inside_radius(pos, 5)) do
                local lua_entity = object:get_luaentity()
                if lua_entity and lua_entity.name == "mcl_experience:orb" then
                    local amount = lua_entity._xp
                    meta:set_int("exchangeclone_stored_xp", meta:get_int("exchangeclone_stored_xp") + amount)
                    if meta:get_int("exchangeclone_stored_xp") > 0 then
                        meta:set_string("exchangeclone_emc_value", "none")
                    else
                        meta:set_string("exchangeclone_emc_value", "")
                    end
                    meta:set_string("description", get_mind_description(itemstack))
                    object:remove()
                end
            end
            return itemstack
        end,
    })

    local book = exchangeclone.itemstrings.book
    minetest.register_craft({
        output = "exchangeclone:mind_stone",
        recipe = {
            {book, book, book},
            {"exchangeclone:red_matter", exchangeclone.itemstrings.lapisworth, "exchangeclone:red_matter"},
            {book, book, book},
        }
    })
end