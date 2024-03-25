-- This list is copied/modified from 3D Armor.
local fire_nodes = {
    ["nether:lava_source"] = true,
    ["default:lava_source"] = true,
    ["default:lava_flowing"] = true,
    ["fire:basic_flame"] = true,
    ["fire:permanent_flame"] = true,
    ["ethereal:crystal_spike"] = true,
    ["ethereal:fire_flower"] = true,
    ["nether:lava_crust"] = true,
    ["default:torch"] = true,
    ["default:torch_ceiling"] = true,
    ["default:torch_wall"] = true,
    ["tech:small_wood_fire"] = true,
    ["tech:large_wood_fire"] = true,
    ["tech:small_wood_fire_smoldering"] = true,
    ["tech:large_wood_fire_smoldering"] = true,
    ["tech:small_charcoal_fire"] = true,
    ["tech:large_charcoal_fire"] = true,
    ["tech:small_charcoal_fire_smoldering"] = true,
    ["tech:large_charcoal_fire_smoldering"] = true,
    ["tech:torch"] = true,
    ["tech:torch_wall"] = true,
    ["tech:torch_ceiling"] = true,
    ["nodes_nature:lava_source"] = true,
    ["nodes_nature:lava_flowing"] = true,
    ["climate:air_temp"] = true,
    ["climate:air_temp_visible"] = true,
}

local function place_liquid(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    local liquid = itemstack:get_name() == "exchangeclone:volcanite_amulet" and "lava" or "water"
    local cost = liquid == "lava" and 64 or 0
    local sound = liquid == "lava" and "exchangeclone_transmute" or "exchangeclone_water"

    exchangeclone.play_sound(player, sound)
    if pointed_thing and pointed_thing.type == "node" then
        local bucket = ItemStack(exchangeclone.itemstrings[liquid.."_bucket"])
        bucket:get_definition().on_place(bucket, player, pointed_thing)
    else
        if (not exchangeclone.mcl) or minetest.settings:get_bool("mcl_buckets_use_select_box", false) then
            local velocity = player:get_look_dir()*20
            minetest.add_entity(
                vector.offset(player:get_pos(), 0, player:get_properties().eye_height, 0),
                "exchangeclone:projectile", minetest.serialize({
                    velocity = vector.to_string(velocity),
                    player = player:get_player_name(),
                    itemstring = itemstack:get_name(),
                    texture = liquid == "lava" and "exchangeclone_lava_projectile.png" or "exchangeclone_water_projectile.png"
                })
            )
        end
        player:_add_emc(-cost)
    end
end

minetest.register_entity("exchangeclone:projectile", {
    initial_properties = {
        hp_max = 1,
        physical = true,
        collide_with_objects = true,
        pointable = false,
        visual = "sprite",
        textures = {"blank.png"},
        static_save = false,
    },
    on_activate = function(self, staticdata)
        local table_data = minetest.deserialize(staticdata)
        local velocity = vector.from_string(table_data.velocity) or vector.new(0,0,0)
        self._itemstring = table_data.itemstring
        self._player = table_data.player
        self.object:set_velocity(velocity)
        self.object:set_properties({textures = {table_data.texture}})
        if not self._player then self.object:remove() end
    end,
    on_step = function(self, dtime, moveresult)
        for _, collision in ipairs(moveresult.collisions) do
            if collision.type == "node" then
                local player = minetest.get_player_by_name(self._player)
                if not player then
                    self.object:remove()
                    return
                end
                local above = vector.new(collision.node_pos)
                if collision.old_velocity[collision.axis] < 0 then
                    above[collision.axis] = above[collision.axis] + 1
                else
                    above[collision.axis] = above[collision.axis] - 1
                end
                place_liquid(ItemStack(self._itemstring), player, {type = "node", under = collision.node_pos, above = above})
            elseif collision.type == "object" then
                local obj = collision.object
                if exchangeclone.mcl then
					mcl_util.deal_damage(obj, 5, {type = "on_fire"})
                    mcl_burning.set_on_fire(obj, 4)
                else
                    obj:set_hp(obj:get_hp() - 5)
                    if minetest.get_modpath("fire_plus") and obj:is_player() then
                        fire_plus.burn_player(obj, 4, 1)
                    end
                end
            end
            self.object:remove()
        end
    end
})

local change_count = 9 -- numbers of calls before changing, starts at 9 to make it do it the first time (10)
local evertide_pedestal
if exchangeclone.mcl and minetest.settings:get_bool("mcl_doWeatherCycle", true) then
    evertide_pedestal = function()
        change_count = change_count + 1
        if change_count >= 10 then
            mcl_weather.change_weather("rain")
            change_count = 0
        end
    end
elseif minetest.get_modpath("weather") then
    evertide_pedestal = function()
        change_count = change_count + 1
        if change_count >= 10 then
            weather.type = "weather:rain"
            weather_mod.handle_lightning()
            weather_mod.handle_weather_change({type = "weather:rain"})
            change_count = 0
        end
    end
end
local volcanite_pedestal
if exchangeclone.mcl and minetest.settings:get_bool("mcl_doWeatherCycle", true) then
    volcanite_pedestal = function()
        change_count = change_count + 1
        if change_count >= 10 then
            mcl_weather.change_weather("none")
            change_count = 0
        end
    end
elseif minetest.get_modpath("weather") then
    volcanite_pedestal = function()
        change_count = change_count + 1
        if change_count >= 10 then
            weather.type = "none"
            weather_mod.handle_lightning()
            weather_mod.handle_weather_change({type = "none"})
            change_count = 0
        end
    end
end

minetest.register_tool("exchangeclone:evertide_amulet", {
    description = "Evertide Amulet",
    inventory_image = "exchangeclone_evertide_amulet.png",
    groups = {disable_repair = 1, immune_to_fire = 1},
    on_place = place_liquid,
    on_secondary_use = place_liquid,
    _exchangeclone_pedestal = evertide_pedestal
})

minetest.register_tool("exchangeclone:volcanite_amulet", {
    description = "Volcanite Amulet",
    inventory_image = "exchangeclone_volcanite_amulet.png",
    groups = {disable_repair = 1, immune_to_fire = 1},
    on_place = place_liquid,
    on_secondary_use = place_liquid,
    _exchangeclone_pedestal = volcanite_pedestal
})

-- Drowning damage looks the same in MCL and MTGs
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 then
        if reason.type == "drown" then
            local inv = player:get_inventory()
            local hotbar_max = player:hud_get_hotbar_itemcount() + 1
            for i = 1, hotbar_max do
                local stack = inv:get_stack("main", i)
                if stack:get_name() == "exchangeclone:evertide_amulet" then
                    return 0
                end
            end
        elseif exchangeclone.mtg and reason.type == "node_damage" and reason.node then
            if fire_nodes[reason.node] then
                local inv = player:get_inventory()
                local hotbar_max = player:hud_get_hotbar_itemcount() + 1
                for i = 1, hotbar_max do
                    local stack = inv:get_stack("main", i)
                    if stack:get_name() == "exchangeclone:volcanite_amulet" then
                        return 0
                    end
                end
            end
        end
    end
    return hp_change
end, true)

-- Fire damage is different (and a lot easier to detect in MCL)
if exchangeclone.mcl then
    mcl_damage.register_modifier(function(obj, damage, reason)
        if not obj:is_player() then return end
        if reason.flags.is_fire then
            local inv = obj:get_inventory()
            local hotbar_max = obj:hud_get_hotbar_itemcount() + 1
            for i = 1, hotbar_max do
                local stack = inv:get_stack("main", i)
                if stack:get_name() == "exchangeclone:volcanite_amulet" then
                    return 0
                end
            end
        end
        return damage
    end)
end

minetest.register_craft({
    output = "exchangeclone:evertide_amulet",
    recipe = {
        {exchangeclone.itemstrings.water_bucket, exchangeclone.itemstrings.water_bucket, exchangeclone.itemstrings.water_bucket},
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {exchangeclone.itemstrings.water_bucket, exchangeclone.itemstrings.water_bucket, exchangeclone.itemstrings.water_bucket},
    }
})

minetest.register_craft({
    output = "exchangeclone:volcanite_amulet",
    recipe = {
        {exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.lava_bucket},
        {"exchangeclone:dark_matter", "exchangeclone:dark_matter", "exchangeclone:dark_matter"},
        {exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.lava_bucket},
    }
})