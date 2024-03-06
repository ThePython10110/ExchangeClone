-- This function is mostly copied from `sneak_drop` by Krunegan because I was too lazy to do it myself
local function pickup_items(player)
    local pos = player:get_pos()
    local objs = minetest.get_objects_inside_radius(pos, 5)
    for j = 1, #objs do
        local obj = objs[j]
        if obj:get_luaentity() and obj:get_luaentity().name == "__builtin:item" then
            local objpos = obj:get_pos()
            local objdir = vector.direction(pos, objpos)
            local objdist = vector.distance(pos, objpos)
            local itemstack = obj:get_luaentity().itemstring
            if player:get_inventory():room_for_item("main", itemstack) then
                player:get_inventory():add_item("main", itemstack)
                obj:remove()
                exchangeclone.play_sound(player, "exchangeclone_pickup")
            else
                obj:set_pos(vector.offset(player:get_pos(), 0, 1, 0))
            end
        end
    end
end

local function void_ring_teleport(player)
    if exchangeclone.check_cooldown(player, "void_ring") then return end
    local new_pos
	local start = player:get_pos()
	start.y = start.y + player:get_properties().eye_height
	local look_dir = player:get_look_dir()
	local _end = vector.add(start, vector.multiply(look_dir, 60))

	local ray = minetest.raycast(start, _end, false, false)
	for pointed_thing in ray do
		local name = minetest.get_node(pointed_thing.under).name
		local def = minetest.registered_nodes[name]
        if def.walkable then
            local offset = -0.5
            if pointed_thing.under.y > pointed_thing.above.y then
                offset = -1.5
            end
            new_pos = vector.offset(pointed_thing.above, 0, offset, 0)
            break
        elseif def.climbable then
            local offset = -0.5
            if pointed_thing.under.y > pointed_thing.above.y then
                offset = -1.5
            end
            new_pos = vector.offset(pointed_thing.under, 0, offset, 0)
            break
        end
	end
    if not new_pos then
        -- If no nodes found, teleport 32 nodes
        new_pos = vector.offset(player:get_pos() + (player:get_look_dir()*32), 0, -0.5, 0)
    end
    player:add_velocity(-player:get_velocity()) -- Why don't players have set_velocity?
    player:set_pos(new_pos)
    exchangeclone.start_cooldown(player, "void_ring", 0.5)
end

minetest.register_tool("exchangeclone:black_hole_band", {
    description = "Black Hole Band",
    inventory_image = "exchangeclone_black_hole_band.png",
    on_secondary_use = exchangeclone.toggle_active,
    on_place = exchangeclone.toggle_active,
    groups = {exchangeclone_passive = 1, disable_repair = 1, immune_to_fire = 1},
    _exchangeclone_passive = {
        func = pickup_items,
        hotbar = true,
        active_image = "exchangeclone_black_hole_band_active.png",
        exclude = {"exchangeclone:void_ring"}
    },
})

-- A lot of duplication here, unfortunately
local function get_void_ring_description(itemstack)
    local meta = itemstack:get_meta()
    local current_target = math.max(meta:get_int("density_target"), 1)
    local target_message = "Target: "..ItemStack(exchangeclone.density_targets[current_target]):get_short_description()
    local emc = exchangeclone.get_item_emc(itemstack:get_name())
    local stored = itemstack:_get_emc() - emc
    return "Void Ring\n"..target_message.."\nEMC: "..exchangeclone.format_number(emc).."\nStored EMC: "..exchangeclone.format_number(stored)
end

local function void_ring_rightclick(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end
    local meta = itemstack:get_meta()
    if player:get_player_control().aux1 then
        local current_target = math.max(meta:get_int("density_target"), 1)
        if player:get_player_control().sneak then
            current_target = math.max(1, current_target - 1)
        else
            current_target = math.min(#exchangeclone.density_targets, current_target + 1)
        end
        minetest.chat_send_player(player:get_player_name(), "Target: "..ItemStack(exchangeclone.density_targets[current_target]):get_short_description())
        meta:set_int("density_target", current_target)
        meta:set_string("description", get_void_ring_description(itemstack))
        return itemstack
    elseif player:get_player_control().sneak then
        local mode = meta:get_int("exchangeclone_void_ring_mode") or 0
        local old_mode = mode
        if mode == 1 then
            mode = 0 -- 0: off, 1: GOED, 2: BHB, 3: both
        elseif mode == 3 then
            mode = 2
        elseif mode == 0 then
            mode = 1
        elseif mode == 2 then
            mode = 3
        end
        meta:set_int("exchangeclone_void_ring_mode", mode)
        minetest.log(string.format("%s -> %s", old_mode, mode))
        if mode < old_mode then
            exchangeclone.play_sound(player, "exchangeclone_charge_down")
        else
            exchangeclone.play_sound(player, "exchangeclone_enable")
        end
        if mode == 0 then
            meta:set_string("exchangeclone_active", "")
            meta:set_string("inventory_image", "")
        else
            meta:set_string("exchangeclone_active", "true")
            local active_image = itemstack:get_definition()._exchangeclone_passive.active_image
            if active_image then
                meta:set_string("inventory_image", active_image)
            end
        end
        return itemstack
    else
        return exchangeclone.goed_condense(player, itemstack)
    end
end

local void_ring_leftclick = function(itemstack, player, pointed_thing)
    local meta = itemstack:get_meta()
    if player:get_player_control().sneak then
        local mode = meta:get_int("exchangeclone_void_ring_mode")
        local old_mode = mode
        if mode == 1 then
            mode = 3 -- 0: off, 1: GOED, 2: BHB, 3: both
        elseif mode == 3 then
            mode = 1
        elseif mode == 0 then
            mode = 2
        elseif mode == 2 then
            mode = 0
        end
        minetest.log(string.format("%s -> %s", old_mode, mode))
        meta:set_int("exchangeclone_void_ring_mode", mode)
        if mode < old_mode then
            exchangeclone.play_sound(player, "exchangeclone_charge_down")
        else
            exchangeclone.play_sound(player, "exchangeclone_enable")
        end
        if mode == 0 then
            meta:set_string("exchangeclone_active", "")
            meta:set_string("inventory_image", "")
        else
            meta:set_string("exchangeclone_active", "true")
            local active_image = itemstack:get_definition()._exchangeclone_passive.active_image
            if active_image then
                meta:set_string("inventory_image", active_image)
            end
        end
        return itemstack
    elseif player:get_player_control().aux1 then
        void_ring_teleport(player)
        return itemstack
    end
    exchangeclone.goed_filter_formspec(player)
    return itemstack
end

minetest.register_tool("exchangeclone:void_ring", {
    description = "Void Ring",
    inventory_image = "exchangeclone_void_ring.png",
    on_secondary_use = void_ring_rightclick,
    on_place = void_ring_rightclick,
    on_use = void_ring_leftclick,
    groups = {exchangeclone_passive = 1, disable_repair = 1, immune_to_fire = 1},
    _exchangeclone_passive = {
        func = function(player, itemstack)
            local meta = itemstack:get_meta()
            local mode = meta:get_int("exchangeclone_void_ring_mode")
            if mode == 2 or mode == 3 then
                pickup_items(player)
            end
            if mode == 1 or mode == 3 then
                exchangeclone.goed_condense(player, itemstack)
            end
        end,
        hotbar = true,
        active_image = "exchangeclone_void_ring_active.png",
        exclude = {"exchangeclone:black_hole_band", "exchangeclone:gem_of_eternal_density"}
    },
})

minetest.register_craftitem("exchangeclone:iron_band", {
    description = "Iron Band", -- I could easily make it "Steel Band" in MTG but I don't care.
    groups = {craftitem = 1},
    inventory_image = "exchangeclone_iron_band.png"
})

minetest.register_craft({
    output = "exchangeclone:iron_band",
    recipe = {
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
    },
    replacements = {{exchangeclone.itemstrings.lava_bucket, exchangeclone.itemstrings.empty_bucket}}
})

minetest.register_craft({
    output = "exchangeclone:iron_band",
    recipe = {
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, "exchangeclone:volcanite_amulet", exchangeclone.itemstrings.iron},
        {exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron, exchangeclone.itemstrings.iron},
    },
    replacements = {{"exchangeclone:volcanite_amulet", "exchangeclone:volcanite_amulet"}}
})

local ingredient = exchangeclone.mcl and "mcl_mobitems:string" or "farming:cotton"
minetest.register_craft({
    output = "exchangeclone:black_hole_band",
    recipe = {
        {ingredient, ingredient, ingredient},
        {"exchangeclone:dark_matter", "exchangeclone:iron_band", "exchangeclone:dark_matter"},
        {ingredient, ingredient, ingredient},
    }
})

minetest.register_craft({
    output = "exchangeclone:void_ring",
    type = "shapeless",
    recipe = {
        "exchangeclone:black_hole_band",
        "exchangeclone:gem_of_eternal_density",
        "exchangeclone:red_matter",
        "exchangeclone:red_matter"
    }
})