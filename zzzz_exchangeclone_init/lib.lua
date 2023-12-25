-- A ton of functions with approximately zero organization. At least there are comments now.

local S = minetest.get_translator()

--- Rounds to the nearest integer
function exchangeclone.round(num)
    if num % 1 < 0.5 then
        return math.floor(num)
    else
        return math.ceil(num)
    end
end

--- Adds all items in a certain list to a table.
function exchangeclone.get_inventory_drops(pos, listname, drops)
    local inv = minetest.get_meta(pos):get_inventory()
    local n = #drops
    for i = 1, inv:get_size(listname) do
        local stack = inv:get_stack(listname, i)
        if stack:get_count() > 0 then
            drops[n+1] = stack:to_table()
            n = n + 1
        end
    end
end

function exchangeclone.on_blast(lists)
    return function(pos)
        local drops = {}
        for _, list in pairs(lists) do
            exchangeclone.get_inventory_drops(pos, list, drops)
        end
        table.insert(drops, minetest.get_node(pos).name)
        minetest.remove_node(pos)
        if exchangeclone.mcl then
            for _, drop in pairs(drops) do
                local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                minetest.add_item(p, drop)
            end
        end
        return drops
    end
end

--- Gets the energy value of an itemstring or ItemStack
--- Handles "group:group_name" syntax (although it goes through every item), returns cheapest item in group
function exchangeclone.get_item_energy(item, ignore_wear)
    if (item == "") or not item then return end
    -- handle groups
    if type(item) == "string" and item:sub(1,6) == "group:" and exchangeclone.group_values then
        local item_group = item:sub(7,-1)
        for _, group in pairs(exchangeclone.group_values) do
            if item_group == group[1] then return group[2] end
        end
        local group_items = exchangeclone.get_group_items(item_group)
        local cheapest
        for _, group_item in pairs(group_items[item_group]) do
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
    -- handle items/itemstacks
    item = ItemStack(item)
    if item == ItemStack("") then return end
    item:set_name(exchangeclone.handle_alias(item))
    local meta_energy_value = tonumber(item:get_meta():get_string("exchangeclone_energy_value"))
    if meta_energy_value then
        if meta_energy_value < 0 then return 0 end
        if meta_energy_value > 0 then return meta_energy_value end
    end
    local def = minetest.registered_items[item:get_name()]
    if not def then return end
    if item:get_name() == "exchangeclone:exchange_orb" then
        if def.energy_value then
            return def.energy_value + exchangeclone.get_orb_itemstack_energy(item)
        end
    end
    if def.energy_value then
        return (def.energy_value) * item:get_count()
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
    return math.max(itemstack:get_meta():get_float("stored_energy"), 0)
end

-- Gets the amount of energy stored in an orb in a specific inventory slot
function exchangeclone.get_orb_energy(inventory, listname, index)
    if not inventory then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    return exchangeclone.get_orb_itemstack_energy(itemstack)
end

function exchangeclone.set_orb_itemstack_energy(itemstack, amount)
    if not itemstack or not amount then return end
    if itemstack:get_name() ~= "exchangeclone:exchange_orb" then return end
    local old_energy = exchangeclone.get_orb_itemstack_energy(itemstack)
    if amount > old_energy and old_energy > exchangeclone.orb_max then return end -- don't allow more energy to be put into an over-filled orb

    -- Square roots will hopefully make it less linear
    -- And if they don't, I don't really care and I don't want to think about math anymore.
    local sqrt_amount = math.sqrt(amount)
    local sqrt_max = math.sqrt(exchangeclone.orb_max)

    local r, g, b = 0, 0, 0
    if amount <= 0 then
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
    meta:set_string("description", S("Exchange Orb").."\n"..S("Current Charge: @1", exchangeclone.format_number(amount)))
    meta:set_string("color", colorstring)
    return itemstack
end

-- Sets the amount of energy in an orb in a specific inventory slot
function exchangeclone.set_orb_energy(inventory, listname, index, amount)
    if not inventory or not amount or amount < 0 then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    local new_stack = exchangeclone.set_orb_itemstack_energy(itemstack, amount)
    if not new_stack then return end
    inventory:set_stack(listname, index, new_stack)
end

-- HUD stuff (show energy value in bottom right)
local hud_elements = {}

function exchangeclone.update_hud(player)
    local hud_text = hud_elements[player:get_player_name()]
    player:hud_change(hud_text, "text", S("Personal Energy: @1", exchangeclone.format_number(exchangeclone.get_player_energy(player))))
end

minetest.register_on_joinplayer(function(player, last_login)
    hud_elements[player:get_player_name()] = player:hud_add({
        hud_elem_type = "text",
        position      = {x = 1, y = 1},
        offset        = {x = 0,   y = 0},
        text          = S("Personal Energy: @1", 0),
        alignment     = {x = -1, y = -1},
        scale         = {x = 100, y = 100},
        number = 0xDDDDDD
    })
    exchangeclone.update_hud(player)
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    hud_elements[player:get_player_name()] = nil
end)

-- Get a player's personal energy
function exchangeclone.get_player_energy(player)
    return tonumber(player:get_meta():get_string("exchangeclone_stored_energy")) or 0
end

-- Set a player's personal energy
function exchangeclone.set_player_energy(player, amount)
    amount = tonumber(amount)
    if not (player and amount) then return end
    if amount < 0 or amount > exchangeclone.limit then return end
    player:get_meta():set_string("exchangeclone_stored_energy", tonumber(amount))
    exchangeclone.update_hud(player)
end

-- Add to a player's personal energy (amount can be negative)
function exchangeclone.add_player_energy(player, amount)
    if not (player and amount) then return end
    exchangeclone.set_player_energy(player, (exchangeclone.get_player_energy(player) or 0) + amount)
end

-- Through trial and error, I have found that this number (1 trillion) works the best.
-- When a player has any more energy (as in ANY more), precision-based exploits such as creating infinite glass panes are possible.
-- I temporarily considered finding some Lua library that allowed for arbitrary precision (and therefore infinite maximum energy)
-- but I decided not to.
exchangeclone.limit = 1000000000000

-- From https://stackoverflow.com/questions/10989788/format-integer-in-lua
-- Formats an integer with commas, accounting for decimal points.
function exchangeclone.format_number(number)
    -- Quit if not a number
    if not tonumber(tostring(number)) then return tostring(number) end

    local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    if not int then return tostring(number) end
    -- reverse the int-string and append a comma to all blocks of 3 digits
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    -- reverse the int-string back remove an optional comma and put the
    -- optional minus and fractional part back
    return minus .. int:reverse():gsub("^,", "") .. fraction
  end

  -- Splits a string into a table using a delimiter (copied from somewhere, I don't remember)
function exchangeclone.split (input, sep)
    if sep == nil then
            sep = "%s"
    end
    local result={}
    for str in string.gmatch(input, "([^"..sep.."]+)") do
            table.insert(result, str)
    end
    return result
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

    local num_groups = #groups

    local result = {}
    for i = 1, num_groups do
        result[groups[i]] = {}
    end
    if include_no_group then
        result["NO_GROUP"] = {}
    end
    local in_group

    for name, def in pairs(minetest.registered_items) do
        in_group = false
        for i = 1, num_groups do
            local grp = groups[i]
            local subgroups = exchangeclone.split(grp, ",")
            local success = true
            for _, subgroup in pairs(subgroups) do
                if not def.groups[subgroup] then
                    success = false
                    break
                end
            end
            if success then
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
    minetest.chat_send_player(player:get_player_name(), S("Current Range: @1", range))
    itemstack:get_meta():set_int("exchangeclone_item_range", range)
    return itemstack
end

-- Itemstrings for various items used in crafting recipes.
exchangeclone.itemstrings = {
    cobble =            (exchangeclone.mcl and "mcl_core:cobble")             or "default:cobble",
    redstoneworth =     (exchangeclone.mcl and "mesecons:redstone")           or "default:obsidian",
    glowstoneworth =    (exchangeclone.mcl and "mcl_nether:glowstone_dust")   or "default:tin_ingot",
    coal =              (exchangeclone.mcl and "mcl_core:coal_lump")          or "default:coal_lump",
    iron =              (exchangeclone.mcl and "mcl_core:iron_ingot")         or "default:steel_ingot",
    copper =            (exchangeclone.mcl and "mcl_copper:copper_ingot")     or "default:copper_ingot",
    gold =              (exchangeclone.mcl and "mcl_core:gold_ingot")         or "default:gold_ingot",
    emeraldworth =      (exchangeclone.mcl and "mcl_core:emerald")            or "default:mese_crystal",
    diamond =           (exchangeclone.mcl and "mcl_core:diamond")            or "default:diamond",
}

exchangeclone.energy_aliases = {}

-- <itemstring> will be treated as <alias> in Deconstructors, Constructors, Transmutation Table(t)s, etc.
-- When you put <itemstring> into a TT, you will learn <alias> instead.
function exchangeclone.register_alias_force(alias, itemstring)
    if alias == itemstring then return end
    exchangeclone.energy_aliases[itemstring] = alias
end

function exchangeclone.register_alias(alias, itemstring)
    if not exchangeclone.energy_aliases[alias] then
        exchangeclone.register_alias_force(alias, itemstring)
    end
end

-- Returns the correct itemstring, handling both Minetest and Exchangeclone aliases.
function exchangeclone.handle_alias(item)
    item = ItemStack(item)
    if not item:is_empty() then
        local de_aliased = exchangeclone.energy_aliases[item:get_name()] or item:get_name() -- Resolve ExchangeClone aliases
        return ItemStack(de_aliased):get_name() or item:get_name() -- Resolve MT aliases
    end
end

-- Returns a player's inventory formspec with the correct width and hotbar position for the current game
function exchangeclone.inventory_formspec(x,y)
    local formspec
    if exchangeclone.mcl then
        formspec = "list[current_player;main;"..x..","..y..";9,3;9]"..
            mcl_formspec.get_itemslot_bg(x,y,9,3)..
            "list[current_player;main;"..x..","..(y+3.25)..";9,1]"..
            mcl_formspec.get_itemslot_bg(x,y+3.25,9,1)
    else
        formspec = "list[current_player;main;"..x..","..y..";8,1]"..
        "list[current_player;main;"..x..","..(y+1.25)..";8,3;8]"
    end
    return formspec
end

-- Modified from MineClone2, basically helps drop items on the player {
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

-- This function gets the drops from a node and drops them at the player's position
function exchangeclone.drop_items_on_player(pos, drops, player) -- modified from MineClone's code
    if not exchangeclone.mcl then
        return minetest.handle_node_drops(pos, drops, player)
    end
    -- NOTE: This function override allows player to be nil.
    -- This means there is no player. This is a special case which allows this function to be called
    -- by hand. Creative Mode is intentionally ignored in this case.
    if player and player:is_player() and minetest.is_creative_enabled(player:get_player_name()) then
        local inv = player:get_inventory()
        if inv then
            for _, item in pairs(drops) do
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

    for _, item in pairs(drops) do
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
-- extra_info is usually used for the tool's itemstack.
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

-- Chat commands:
minetest.register_chatcommand("add_player_energy", {
    params = "[player] <value>",
    description = "Add to a player's personal energy (player is self if not included, value can be negative to subtract)",
    privs = {privs = true},
    func = function(name, param)
        local split_param = exchangeclone.split(param, " ")
        local target_player
        local target_name
        local value
        if #split_param == 1 then
            target_name = name
            value = split_param[1]
        elseif #split_param == 2 then
            target_name = split_param[1]
            value = split_param[2]
        end
        target_player = minetest.get_player_by_name(target_name)
        if (not (target_player and value)) or not tonumber(value) then
            minetest.chat_send_player(name, "Bad command. Use /add_player_energy [player] [value] or /add_player_energy [value]")
            return
        end
        local energy = exchangeclone.get_player_energy(target_player)
        if (energy + value > exchangeclone.limit) or (energy + value < 0) then
            minetest.chat_send_player(name, "Out of bounds; personal energy must be between 0 and 1 trillion.")
            return
        end
        exchangeclone.add_player_energy(target_player, tonumber(value))
        minetest.chat_send_player(name, "Added "..exchangeclone.format_number(value).." to "..target_name.."'s personal energy.")
    end
})

-- Chat commands:
minetest.register_chatcommand("get_player_energy", {
    params = "[player]",
    description = "Gets a player's personal energy (player is self if not included).",
    privs = {privs = true},
    func = function(name, param)
        local target_player
        local target_name
        if param and param ~= "" then
            target_name = param
        else
            target_name = name
        end
        target_player = minetest.get_player_by_name(target_name)
        if not (target_player) then
            minetest.chat_send_player(name, "Bad command. Use /get_player_energy [player] or /get_player_energy")
            return
        end
        local energy = exchangeclone.get_player_energy(target_player)
        minetest.chat_send_player(name, target_name.."'s personal energy: "..exchangeclone.format_number(energy))
    end
})

minetest.register_chatcommand("set_player_energy", {
    params = "[player] <value>",
    description = "Set a player's personal energy (player is self if not included; use 'limit' as value to set it to maximum)",
    privs = {privs = true},
    func = function(name, param)
        local split_param = exchangeclone.split(param, " ")
        local target_player
        local target_name
        local value
        if #split_param == 1 then
            target_name = name
            value = split_param[1]
        end
        if #split_param == 2 then
            target_name = split_param[1]
            value = split_param[2]
        end
        target_player = minetest.get_player_by_name(name)
        if (not (target_player and value)) or (not (value == "limit" or tonumber(value))) then
            minetest.chat_send_player(name, "Bad command. Use /set_player_energy [player] [value] or /set_player_energy [value]")
            return
        end
        if value:lower() == "limit" then
            value = exchangeclone.limit
        elseif (tonumber(value) > exchangeclone.limit) or (tonumber(value) < 0) then
            minetest.chat_send_player(name, "Failed to set energy; must be between 0 and 1 trillion.")
            return
        end
        exchangeclone.set_player_energy(target_player, tonumber(value))
        minetest.chat_send_player(name, "Set "..target_name.."'s personal energy to "..exchangeclone.format_number(value))
    end
})

exchangeclone.neighbors = {
    {x=-1, y=0, z=0},
    {x=1, y=0, z=0},
    {x=0, y=-1, z=0},
    {x=0, y=1, z=0},
    {x=0, y=0, z=-1},
    {x=0, y=0, z=1},
}

function exchangeclone.check_nearby_falling(pos)
	for i = 1, 6 do
        local new_pos = vector.add(pos, exchangeclone.neighbors[i])
        if exchangeclone.mcl then
            local node = minetest.get_node(new_pos)
            if node.name == "mcl_core:vine" then
                mcl_core.check_vines_supported(new_pos, node)
            end
        end
	end
    minetest.check_for_falling(pos)
end

function exchangeclone.remove_nodes(positions)
    minetest.bulk_set_node(positions, {name = "air"})
    for _, pos in pairs(positions) do
        exchangeclone.check_nearby_falling(pos)
    end
end

--[[
Recipes are registered with the same format that they are in minetest.register_craft:
{
    type = <type>
    recipe = <recipe>
    output = <itemstring>
    replacements = {{<itemstring>, <replace_itemstring>}, {<itemstring>, <replace_itemstring>}}
}

You do NOT have to call exchangeclone.register_craft if you use minetest.register_craft.
]]

--[[
name (string): The name of the crafting type.
recipe_type (string): One of the following:
    shaped (default): Recipe is given in an array of arrays of ingredients.
    shapeless: Recipe is given as a array of ingredients
    cooking: Recipe is a single item
reverse (bool): Only applies for "cooking" recipe_type. If set to true, all recipes of this
                type will be registered twice: once normally, and once with the recipe and output swapped.
]]

exchangeclone.craft_types = {}

function exchangeclone.register_craft_type(name, recipe_type, reverse)
    exchangeclone.craft_types[name] = {type = recipe_type, reverse = reverse}
end

function exchangeclone.register_craft(data)
    if not data.output then return end
    local itemstring = ItemStack(data.output):get_name()
    exchangeclone.recipes[itemstring] = exchangeclone.recipes[itemstring] or {}
    table.insert(exchangeclone.recipes[itemstring], table.copy(data))
    -- Should reversed recipe be registered too?
    if data.type then
        local type_data = exchangeclone.craft_types[data.type]
        if type_data.type == "cooking" and type_data.reverse then
            local flipped_data = table.copy(data)
            flipped_data.output, flipped_data.recipe = flipped_data.recipe, flipped_data.output
            local flipped_output = ItemStack(flipped_data.output):get_name()
            exchangeclone.recipes[flipped_output] = exchangeclone.recipes[flipped_output] or {}
            table.insert(exchangeclone.recipes[flipped_output], table.copy(flipped_data))
        end
    end
end

-- Returns true if item (itemstring or ItemStack) can be used as a furnace fuel.
-- Returns false otherwise
function exchangeclone.is_fuel(item)
	return minetest.get_craft_result({method = "fuel", width = 1, items = {item}}).time ~= 0
end

-- Returns true if item (itemstring or ItemStack) can't be used as a furnace fuel.
-- Returns false otherwise
function exchangeclone.isnt_fuel(item)
	return not exchangeclone.is_fuel(item)
end

-- Copied from MCL2
--- Selects item stack to transfer from
--- @param src_inventory InvRef Source innentory to pull from
--- @param src_list string Name of source inventory list to pull from
--- @param dst_inventory InvRef Destination inventory to push to
--- @param dst_list string Name of destination inventory list to push to
--- @param condition? fun(stack: ItemStack) Condition which items are allowed to be transfered.
--- @return integer Item stack number to be transfered
function exchangeclone.select_stack(src_inventory, src_list, dst_inventory, dst_list, condition)
	local src_size = src_inventory:get_size(src_list)
	local stack
	for i = 1, src_size do
		stack = src_inventory:get_stack(src_list, i)
		if not stack:is_empty() and dst_inventory:room_for_item(dst_list, stack) and ((condition == nil or condition(stack))) then
			return i
		end
	end
	return nil
end

function exchangeclone.mcl2_hoppers_on_try_pull(dst_condition, fuel_condition)
    if not exchangeclone.mcl2 then return end
    return function(pos, hop_pos, hop_inv, hop_list)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        if exchangeclone.select_stack(inv, "dst", hop_inv, hop_list) then
            return inv, "dst", exchangeclone.select_stack(inv, "dst", hop_inv, hop_list, dst_condition)
        else
            return inv, "fuel", exchangeclone.select_stack(inv, "fuel", hop_inv, hop_list, fuel_condition or exchangeclone.isnt_fuel)
        end
    end
end

function exchangeclone.mcl2_hoppers_on_try_push(src_condition, fuel_condition)
    if not exchangeclone.mcl2 then return end
    return function(pos, hop_pos, hop_inv, hop_list)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        if math.abs(pos.y - hop_pos.y) > math.abs(pos.x - hop_pos.x) and math.abs(pos.y - hop_pos.y) > math.abs(pos.z - hop_pos.z) then
            return inv, "src", exchangeclone.select_stack(hop_inv, hop_list, inv, "src", src_condition)
        else
            return inv, "fuel", exchangeclone.select_stack(hop_inv, hop_list, inv, "fuel", fuel_condition or exchangeclone.is_fuel)
        end
    end
end

function exchangeclone.mcla_on_hopper_in(src_condition, fuel_condition, action)
    if not exchangeclone.mcla then return end
    return function(pos, to_pos)
        local sinv = minetest.get_inventory({type="node", pos = pos})
        local dinv = minetest.get_inventory({type="node", pos = to_pos})
        local handled
        local moved = true
        if pos.y == to_pos.y then
            -- Put fuel into fuel slot
            local slot_id,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "main", dinv, "fuel", fuel_condition or mcl_furnaces.is_transferrable_fuel)
            if slot_id then
                mcl_util.move_item_container(pos, to_pos, nil, slot_id, "fuel")
            else
                moved = false
            end
            handled = true
        elseif src_condition then
            -- Check src
            local slot_id,_ = mcl_util.get_eligible_transfer_item_slot(sinv, "main", dinv, "src", src_condition)
            if slot_id then
                mcl_util.move_item_container(pos, to_pos, nil, slot_id, "src")
            else
                moved = false
            end
            handled = true
        end
        if moved and action then action(to_pos) end
        return handled
    end
end

function exchangeclone.mcla_on_hopper_out(fuel_condition, action)
	fuel_condition = fuel_condition or function(stack)
		return not exchangeclone.is_fuel(stack)
	end
	return function(uppos, pos)
		local sucked = mcl_util.move_item_container(uppos, pos)

		-- Also suck in non-fuel items from furnace fuel slot
		if not sucked then
			local finv = minetest.get_inventory({type="node", pos=uppos})
			if finv and fuel_condition(finv:get_stack("fuel", 1)) then
				sucked = mcl_util.move_item_container(uppos, pos, "fuel")
			end
		end
        if sucked and action then action(pos) end
		return sucked
	end
end

function exchangeclone.drop_after_dig(lists)
    return function(pos, oldnode, oldmetadata, player)
        if exchangeclone.mcl then
            local meta = minetest.get_meta(pos)
            local meta2 = meta:to_table()
            meta:from_table(oldmetadata)
            local inv = meta:get_inventory()
            for _, listname in pairs(lists) do
                for i = 1, inv:get_size(listname) do
                    local stack = inv:get_stack(listname, i)
                    if not stack:is_empty() then
                        local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                        minetest.add_item(p, stack)
                    end
                end
            end
            meta:from_table(meta2)
        end
        if exchangeclone.pipeworks then
            pipeworks.after_dig(pos)
        end
    end
end

function exchangeclone.can_dig(pos)
    -- Always allow digging in MCL
    if exchangeclone.mcl then return true end
    -- Only allow digging of empty containers in MTG
    local inv = minetest.get_inventory({type="node", pos=pos})
    for listname, _ in pairs(inv:get_lists()) do
        if not inv:is_empty(listname) then
            return false
        end
    end
    return true
end