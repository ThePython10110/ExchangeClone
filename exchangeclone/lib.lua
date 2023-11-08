-- Just a collection of a whole bunch of functions used here. There's very little order.

-- Don't know if this even works.
function exchangeclone.get_inventory_drops(pos, inventory, drops) --removes default dependency
    local inv = minetest.get_meta(pos):get_inventory()
    local n = #drops
    for i = 1, inv:get_size(inventory) do
        local stack = inv:get_stack(inventory, i)
        if stack:get_count() > 0 then
            drops[n+1] = stack:to_table()
            n = n + 1
        end
    end
end

function exchangeclone.get_item_energy(item)
    if not item then return end
    if type(item) == "string" and item:sub(1,6) == "group:" and exchangeclone.group_values then
        local item_group = item:sub(7,-1)
        for _, group in ipairs(exchangeclone.group_values) do
            if item_group == group[1] then return group[2] end
        end
        local group_items = exchangeclone.get_group_items(item_group)
        local cheapest
        for _, group_item in ipairs(group_items[item_group]) do
            if group_item then
                local energy_value = exchangeclone.get_item_energy(group_item)
                if energy_value then
                    if energy_value > 0 and ((not cheapest) or energy_value < cheapest) then
                        cheapest = energy_value
                    end
                end
            end
        end
        return cheapest
    end
    item = ItemStack(item)
    local def = minetest.registered_items[item:get_name()]
    if not def then return 0 end
    if item:get_name() == "exchangeclone:exchange_orb" then
        return def.energy_value or 0 + exchangeclone.get_orb_itemstack_energy(item)
    end
    if def.energy_value then
        return (def.energy_value) * item:get_count()
    else
        return
    end
end

-- Rounds to the nearest integer
function exchangeclone.round(num)
    if num % 1 < 0.5 then
        return math.floor(num)
    else
        return math.ceil(num)
    end
end

-- https://forum.unity.com/threads/re-map-a-number-from-one-range-to-another.119437/
-- Remaps a number from one range to another
function exchangeclone.map(input, min1, max1, min2, max2)
    return (input - min1) / (max1 - min1) * (max2 - min2) + min2
end

-- Gets the energy stored in a specified exchange_orb itemstack.
function exchangeclone.get_orb_itemstack_energy(itemstack)
    if not itemstack then return end
    if itemstack:get_name() ~= "exchangeclone:exchange_orb" then return end
    return itemstack:get_meta():get_float("stored_energy") or 0
end

-- Gets the amount of energy stored in an orb in a specific inventory slot
function exchangeclone.get_orb_energy(inventory, listname, index)
    if not inventory then return 0 end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    return exchangeclone.get_orb_itemstack_energy(itemstack)
end

-- Decides what mod to use for sounds
if exchangeclone.mcl then exchangeclone.sound_mod = mcl_sounds else exchangeclone.sound_mod = default end

-- Sets the amount of energy in an orb in a specific inventory slot
function exchangeclone.set_orb_energy(inventory, listname, index, amount)
    if not inventory or amount < 0 then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    if not itemstack then return end
    if itemstack:get_name() ~= "exchangeclone:exchange_orb" then return end
    local old_energy = exchangeclone.get_orb_itemstack_energy(itemstack)
    if amount > old_energy and old_energy > exchangeclone.orb_max then return end -- don't allow more energy to be put into an over-filled orb

    -- Square roots will hopefully make it less linear
    -- And if they don't, I don't really care and I don't want to think about math anymore.
    local sqrt_amount = math.sqrt(amount)
    local sqrt_max = math.sqrt(exchangeclone.orb_max)

    local r, g, b = 0, 0, 0
    if amount == 0 then
        -- do nothing
    elseif sqrt_amount < (sqrt_max/4) then
        r = exchangeclone.map(sqrt_amount, 0, sqrt_max/4, 0, 255)
    elseif sqrt_amount < (sqrt_max/2) then
        g = exchangeclone.map(sqrt_amount, sqrt_max/4, sqrt_max/2, 0, 255)
        r = 255 - g
    elseif sqrt_amount < (3*sqrt_max/4) then
        b = exchangeclone.map(sqrt_amount, sqrt_max/2, 3*sqrt_max/4, 0, 255)
        g = 255 - b
    else
        r = math.min(exchangeclone.map(sqrt_amount, 3*sqrt_max/4, sqrt_max, 0, 255), 255)
        b = 255
    end

    local colorstring = minetest.rgba(r,g,b)

    local meta = itemstack:get_meta()
    meta:set_float("stored_energy", amount)
    meta:set_string("description", "Exchange Orb\nCurrent Charge: "..amount)
    meta:set_string("color", colorstring)
    inventory:set_stack(listname, index, itemstack)
end

-- HUD stuff (show energy value in bottom right)
local hud_elements = {}

function exchangeclone.update_hud(player)
    local hud_text = hud_elements[player:get_player_name()]
    player:hud_change(hud_text, "text", "Personal Energy: "..tostring(exchangeclone.get_player_energy(player)))
end

minetest.register_on_joinplayer(function(player, last_login)
    hud_elements[player:get_player_name()] = player:hud_add({
        hud_elem_type = "text",
        position      = {x = 1, y = 1},
        offset        = {x = 0,   y = 0},
        text          = "Personal Energy: 0",
        alignment     = {x = -1, y = -1},
        scale         = {x = 100, y = 100},
        number = 0xDDDDDD
    })
    exchangeclone.update_hud(player)
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    hud_elements[player:get_player_name()] = nil
end)

-- Go from old integer energy to fancy new string energy
minetest.register_on_joinplayer(function(player, last_login)
    local meta = player:get_meta()
    local energy = meta:get_int("exchangeclone_stored_energy") or 0
    minetest.log(energy)
    if energy > 0 then
        -- Not sure at all whether this is necessary
        meta:set_int("exchangeclone_stored_energy", 0)
        meta:set_string("exchangeclone_stored_energy", tonumber(energy))
    end
end)

-- Get a player's personal energy
function exchangeclone.get_player_energy(player)
    return tonumber(player:get_meta():get_string("exchangeclone_stored_energy")) or 0
end

-- Set a player's personal energy
function exchangeclone.set_player_energy(player, amount)
    player:get_meta():set_string("exchangeclone_stored_energy", tonumber(amount))
    exchangeclone.update_hud(player)
end

-- copied from http://lua-users.org/wiki/IntegerDomain
-- Basically gets the highest number Lua supports

-- get highest power of 2 which Lua can still handle as integer
local step = 2
while true do
	local nextstep = step*2
	if nextstep - (nextstep-1) == 1 and nextstep > 0 then
		step = nextstep
	else
		break
	end
end

-- now get the highest number which Lua can still handle as integer
exchangeclone.limit, step = step, math.floor(step/2)
while step > 0 do
	local nextlimit = exchangeclone.limit + step
	if nextlimit - (nextlimit-1) == 1 and nextlimit > 0 then
		exchangeclone.limit = nextlimit
	end
	step = math.floor(step/2)
end

-- Returns a table of all items in the specified group(s).
function exchangeclone.get_group_items(groups, allow_duplicates, include_no_group)
    if type(groups) ~= "table" then
        if type(groups) == "string" then
            groups = {groups}
        else
            return
        end
    end

    allow_duplicates = allow_duplicates or false
    include_no_group = include_no_group or false

    local g_cnt = #groups

    local result = {}
    for i = 1, g_cnt do
        result[groups[i]] = {}
    end
    if include_no_group then
        result["NO_GROUP"] = {}
    end
    local in_group

    for name, def in pairs(minetest.registered_items) do
        in_group = false
        for i = 1, g_cnt do
            local grp = groups[i]
            if def.groups[grp] ~= nil then
                result[grp][#result[grp]+1] = name
                in_group = true
                if allow_duplicates == false then
                    break
                end
            end
        end
        if include_no_group and in_group == false then
            result["NO_GROUP"][#result["NO_GROUP"]+1] = name
        end
    end

    return result
end

-- Plays the sound caused by ExchangeClone abilities
function exchangeclone.play_ability_sound(player, base_pitch)
    if not player then return end
    if not base_pitch then base_pitch = 1 end
    local new_pitch = base_pitch + (math.random(-100, 100) / 500)
    minetest.sound_play("exchangeclone_ability", {pitch = new_pitch, pos = player:get_pos(), max_hear_distance = 20, })
end

-- Check the clicked node for a right-click function.
function exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if pointed_thing.type ~= "node" then return false end
    if player:get_player_control().sneak then return false end
    local node = minetest.get_node(pointed_thing.under)
    if player and not player:get_player_control().sneak then
        if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
            return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
        end
    end
    return false
end

-- Update the range of an ExchangeClone tool
function exchangeclone.range_update(itemstack, player, max)
    if not max then max = 4 end
    local range = tonumber(itemstack:get_meta():get_int("exchangeclone_item_range"))
    if player:get_player_control().sneak then
        if range == 0 then
            range = max
        else
            range = range - 1
        end
    else
        if range == max then
            range = 0
        else
            range = range + 1
        end
    end
    minetest.chat_send_player(player:get_player_name(), "Current Range: "..range)
    itemstack:get_meta():set_int("exchangeclone_item_range", range)
    return itemstack
end

-- Make ExchangeClone tools slightly larger...
exchangeclone.wield_scale = {x=1,y=1,z=1}
if exchangeclone.mcl then
    exchangeclone.wield_scale = mcl_vars.tool_wield_scale
end

exchangeclone.wield_scale = vector.multiply(exchangeclone.wield_scale, 1.4)

-- Itemstrings for various items
exchangeclone.itemstrings = {
    diamond = exchangeclone.mcl and "mcl_core:diamond" or "default:diamond",
    gold = exchangeclone.mcl and "mcl_core:gold_ingot" or "default:gold_ingot",
    iron = exchangeclone.mcl and "mcl_core:iron_ingot" or "default:steel_ingot",
    coal = exchangeclone.mcl and "mcl_core:coal_lump" or "default:coal_lump",
    meseworth = exchangeclone.mcl and "mcl_core:emerald" or "default:mese_crystal"
}

-- Returns a player's inventory formspec with the correct width and hotbar position for the current game
function exchangeclone.inventory_formspec(x,y)
    local formspec
    if exchangeclone.mcl then
        formspec = "list[current_player;main;"..tostring(x)..","..tostring(y)..";9,3;9]"..
            mcl_formspec.get_itemslot_bg(x,y,9,3)..
            "list[current_player;main;"..tostring(x)..","..tostring(y+3.25)..";9,1]"..
            mcl_formspec.get_itemslot_bg(x,y+3.25,9,1)
    else
        formspec = "list[current_player;main;"..tostring(x)..","..tostring(y)..";8,1]"..
        "list[current_player;main;"..tostring(x)..","..tostring(y+1.25)..";8,3;8]"
    end
    return formspec
end

-- Modified from MineClone2 {
local doTileDrops = minetest.settings:get_bool("mcl_doTileDrops", true)

local function get_fortune_drops(fortune_drops, fortune_level)
    local drop
    local i = fortune_level
    repeat
        drop = fortune_drops[i]
        i = i - 1
    until drop or i < 1
    return drop or {}
end

local function discrete_uniform_distribution(drops, min_count, max_count, cap)
    local new_drops = table.copy(drops)
    for i, item in ipairs(drops) do
        local new_item = ItemStack(item)
        local multiplier = math.random(min_count, max_count)
        if cap then
            multiplier = math.min(cap, multiplier)
        end
        new_item:set_count(multiplier * new_item:get_count())
        new_drops[i] = new_item
    end
    return new_drops
end

local tmp_id = 0

local function get_drops(drop, toolname, param2, paramtype2)
    tmp_id = tmp_id + 1
    local tmp_node_name = "mcl_item_entity:" .. tmp_id
    minetest.registered_nodes[tmp_node_name] = {
        name = tmp_node_name,
        drop = drop,
        paramtype2 = paramtype2
    }
    local drops = minetest.get_node_drops({ name = tmp_node_name, param2 = param2 }, toolname)
    minetest.registered_nodes[tmp_node_name] = nil
    return drops
end

function exchangeclone.drop_items_on_player(pos, drops, player) --copied from MineClone's code
    if not exchangeclone.mcl then
        return minetest.handle_node_drops(pos, drops, player)
    end
    -- NOTE: This function override allows player to be nil.
    -- This means there is no player. This is a special case which allows this function to be called
    -- by hand. Creative Mode is intentionally ignored in this case.
    if player and player:is_player() and minetest.is_creative_enabled(player:get_player_name()) then
        local inv = player:get_inventory()
        if inv then
            for _, item in ipairs(drops) do
                if not inv:contains_item("main", item, true) then
                    inv:add_item("main", item)
                end
            end
        end
        return
    elseif not doTileDrops then return end

    -- Check if node will yield its useful drop by the player's tool
    local dug_node = minetest.get_node(pos)
    local tooldef
    local tool
    if player then
        tool = player:get_wielded_item()
        tooldef = minetest.registered_items[tool:get_name()]

        if not mcl_autogroup.can_harvest(dug_node.name, tool:get_name(), player) then
            return
        end
    end

    local diggroups = tooldef and tooldef._mcl_diggroups
    local shearsy_level = diggroups and diggroups.shearsy and diggroups.shearsy.level

    --[[ Special node drops when dug by shears by reading _mcl_shears_drop or with a silk touch tool reading _mcl_silk_touch_drop
    from the node definition.
    Definition of _mcl_shears_drop / _mcl_silk_touch_drop:
    * true: Drop itself when dug by shears / silk touch tool
    * table: Drop every itemstring in this table when dug by shears _mcl_silk_touch_drop
    ]]

    local enchantments = tool and mcl_enchanting.get_enchantments(tool)

    local silk_touch_drop = false
    local nodedef = minetest.registered_nodes[dug_node.name]
    if not nodedef then return end

    if shearsy_level and shearsy_level > 0 and nodedef._mcl_shears_drop then
        if nodedef._mcl_shears_drop == true then
            drops = { dug_node.name }
        else
            drops = nodedef._mcl_shears_drop
        end
    elseif tool and enchantments.silk_touch and nodedef._mcl_silk_touch_drop then
        silk_touch_drop = true
        if nodedef._mcl_silk_touch_drop == true then
            drops = { dug_node.name }
        else
            drops = nodedef._mcl_silk_touch_drop
        end
    end

    if tool and nodedef._mcl_fortune_drop and enchantments.fortune then
        local fortune_level = enchantments.fortune
        local fortune_drop = nodedef._mcl_fortune_drop
        if fortune_drop.discrete_uniform_distribution then
            local min_count = fortune_drop.min_count
            local max_count = fortune_drop.max_count + fortune_level * (fortune_drop.factor or 1)
            local chance = fortune_drop.chance or fortune_drop.get_chance and fortune_drop.get_chance(fortune_level)
            if not chance or math.random() < chance then
                drops = discrete_uniform_distribution(fortune_drop.multiply and drops or fortune_drop.items, min_count, max_count,
                    fortune_drop.cap)
            elseif fortune_drop.override then
                drops = {}
            end
        else
            -- Fixed Behavior
            local drop = get_fortune_drops(fortune_drop, fortune_level)
            drops = get_drops(drop, tool:get_name(), dug_node.param2, nodedef.paramtype2)
        end
    end

    if player and mcl_experience.throw_xp and not silk_touch_drop then
        local experience_amount = minetest.get_item_group(dug_node.name, "xp")
        if experience_amount > 0 then
            mcl_experience.throw_xp(player:get_pos(), experience_amount)
        end
    end

    for _, item in ipairs(drops) do
        local count
        if type(item) == "string" then
            count = ItemStack(item):get_count()
        else
            count = item:get_count()
        end
        local drop_item = ItemStack(item)
        drop_item:set_count(1)
        for i = 1, count do
            -- Spawn item
            local obj = minetest.add_item(player:get_pos(), drop_item)
            if obj then
                -- set the velocity multiplier to the stored amount or if the game dug this node, apply a bigger velocity
                obj:get_luaentity().age = 0.65
                obj:get_luaentity()._insta_collect = true
            end
        end
    end
end

-- }

-- Get the direction a player is facing (rounded to -1, 0, and 1 for each axis)
function exchangeclone.get_face_direction(player)
    local h_look = player:get_look_horizontal()
    local v_look = player:get_look_vertical()

    local result = {x = 0, y = 0, z = 0}

    if h_look <= math.pi / 4 or h_look >= (7*math.pi)/4 then
        result.z = 1
    elseif h_look > math.pi / 4 and h_look <= (3*math.pi)/4 then
        result.x = -1
    elseif h_look > (3*math.pi)/4 and h_look <= (5*math.pi)/4 then
        result.z = -1
    else
        result.x = 1
    end

    if v_look < -1 then
        result.y = 1
    elseif v_look > 1 then
        result.y = -1
    end

    return result
end

-- Execute an action for every node within a cubic radius
function exchangeclone.node_radius_action(player, center, range, functions, extra_info)
    if not functions.action then return end
    local data
    local stop = false
    if functions.start_action then
        data = functions.start_action(player, center, range, extra_info)
        if not data then return end
    end
    if not center then center = player:get_pos() end
    center.x = exchangeclone.round(center.x)
    center.y = math.floor(center.y) --make sure y is node BELOW player's feet
    center.z = exchangeclone.round(center.z)
    for x = center.x-range,center.x+range do
    for y = center.y-range,center.y+range do
    for z = center.z-range,center.z+range do
        local pos = {x=x,y=y,z=z}
        local node = minetest.get_node(pos)
        local result = functions.action(player, pos, node, data)
        if not result then stop = true break end
        if result ~= true then data = result end
    end
    if stop then break end
    end
    if stop then break end
    end
    if functions.end_action then
        data = functions.end_action(player, center, range, data)
    end
    return data
end

-- Cooldowns
exchangeclone.cooldowns = {}

minetest.register_on_joinplayer(function(player, last_login)
    exchangeclone.cooldowns[player:get_player_name()] = {}
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    exchangeclone.cooldowns[player:get_player_name()] = nil
end)

-- Start a <time>-second cooldown called <name> for <player> 
function exchangeclone.start_cooldown(player, name, time)
    local player_name = player:get_player_name()
    exchangeclone.cooldowns[player_name][name] = time
    minetest.after(time, function()
        if exchangeclone.cooldowns[player_name] then
            exchangeclone.cooldowns[player_name][name] = nil
        end
    end)
end

-- Returns the TOTAL time of a cooldown called <name> for <player> or nil if no matching cooldown is running.
function exchangeclone.check_cooldown(player, name)
    local player_name = player:get_player_name()
    if exchangeclone.cooldowns[player_name] then
        return exchangeclone.cooldowns[player_name][name]
    end
end