-- A ton of functions with approximately zero organization. At least there are comments now.

local S = minetest.get_translator()
--local exchangeclone = exchangeclone

--- Rounds to the nearest integer
function exchangeclone.round(num)
    if num % 1 < 0.5 then
        return math.floor(num)
    else
        return math.ceil(num)
    end
end

exchangeclone.width = exchangeclone.mtg and 8 or 9

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

--- Gets the EMC value of an itemstring or ItemStack
--- Handles "group:group_name" syntax (although it goes through every item), returns cheapest item in group
function exchangeclone.get_item_emc(item)
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
                local emc_value = exchangeclone.get_item_emc(group_item)
                if emc_value then
                    if emc_value > 0 and ((not cheapest) or emc_value < cheapest) then
                        cheapest = emc_value
                    end
                end
            end
        end
        return cheapest
    end

    -- Only check metadata for ItemStacks
    if getmetatable(item) == getmetatable(ItemStack()) then
        local meta_emc_value = item:get_meta():get_string("exchangeclone_emc_value")
        if meta_emc_value == "none" then
            return 0
        elseif tonumber(meta_emc_value) then
            return math.max(0, tonumber(meta_emc_value))
        end
    end

    -- handle items/itemstacks
    item = ItemStack(item)
    if item == ItemStack("") then return end
    item:set_name(exchangeclone.handle_alias(item))

    local def = minetest.registered_items[item:get_name()]
    if not def then return end
    if minetest.get_item_group(item:get_name(), "klein_star") > 0 then
        if def.emc_value then
            return def.emc_value + item:_get_star_emc()
        end
    end
    if def.emc_value then
        return (def.emc_value) * item:get_count()
    end
end

function exchangeclone.set_item_meta_emc(item, value)
    if getmetatable(item) ~= getmetatable(ItemStack()) then
        return
    end
    item:get_meta():set_string("exchangeclone_emc_value", value)
end

function exchangeclone.add_item_meta_emc(item, value)
    if getmetatable(item) ~= getmetatable(ItemStack()) then
        return
    end
    local current_value = item:get_meta():get_string("exchangeclone_emc_value", value)
    if current_value == "" or current_value == "none" then
        current_value = 0
    else
        current_value = tonumber(current_value)
    end
    item:get_meta():set_string("exchangeclone_emc_value", current_value + value)
end

-- https://forum.unity.com/threads/re-map-a-number-from-one-range-to-another.119437/
-- Remaps a number from one range to another
function exchangeclone.map(input, min1, max1, min2, max2)
    return (input - min1) / (max1 - min1) * (max2 - min2) + min2
end

-- Gets the EMC stored in a specified Klein/Magnum Star itemstack.
function exchangeclone.get_star_itemstack_emc(itemstack)
    if not itemstack then return end
    if getmetatable(itemstack) ~= getmetatable(ItemStack()) then
        return
    end
    if minetest.get_item_group(itemstack:get_name(), "klein_star") < 1 then return end
    return math.max(itemstack:get_meta():get_float("stored_energy"), 0)
end

-- Gets the amount of EMC stored in a star in a specific inventory slot
function exchangeclone.get_star_emc(inventory, listname, index)
    if not inventory then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    return itemstack:get_star_emc()
end

function exchangeclone.set_star_itemstack_emc(itemstack, amount)
    if not itemstack or not amount then return end
    if minetest.get_item_group(itemstack:get_name(), "klein_star") < 1 then return end
    local old_emc = itemstack:get_star_emc()
    local max = exchangeclone.get_star_max(itemstack)
    if amount > old_emc and old_emc > max then return end -- don't allow more EMC to be put into an over-filled star

    local meta = itemstack:get_meta()
    meta:set_float("stored_energy", amount) -- Unfortunately, this is still "energy" not EMC
    meta:set_string("description", itemstack:get_definition()._mcl_generate_description(itemstack))
    local wear = math.max(1, math.min(65535, 65535 - 65535*amount/max))
    itemstack:set_wear(wear)
end

-- Sets the amount of EMC in a star in a specific inventory slot
function exchangeclone.set_star_emc(inventory, listname, index, amount)
    if not inventory or not amount or amount < 0 then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    itemstack:_set_star_emc(amount)
    inventory:set_stack(listname, index, itemstack)
end

function exchangeclone.add_star_itemstack_emc(itemstack, amount)
    if itemstack and amount then
        local emc = itemstack:get_star_emc() + amount
        if not emc or emc < 0 or emc > exchangeclone.get_star_max(itemstack) then return end
        itemstack:_set_star_emc(itemstack, emc)
    end
end

-- Adds to the amount of EMC in a star in a specific inventory slot
function exchangeclone.add_star_emc(inventory, listname, index, amount)
    if not (inventory and listname and index and amount) then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    exchangeclone.add_star_itemstack_emc(itemstack, amount)
    inventory:set_stack(listname, index, itemstack)
end

function exchangeclone.get_star_max(item)
    item = ItemStack(item)
    return item:get_definition().max_capacity or 0
end

-- HUD stuff (show EMC value in bottom right)
local hud_elements = {}

function exchangeclone.update_hud(player)
    local hud_text = hud_elements[player:get_player_name()]
    player:hud_change(hud_text, "text", S("Personal EMC: @1", exchangeclone.format_number(exchangeclone.get_player_emc(player))))
end

minetest.register_on_joinplayer(function(player, last_login)
    hud_elements[player:get_player_name()] = player:hud_add({
        hud_elem_type = "text",
        position      = {x = 1, y = 1},
        offset        = {x = 0,   y = 0},
        text          = S("Personal EMC: @1", 0),
        alignment     = {x = -1, y = -1},
        scale         = {x = 100, y = 100},
        number = 0xDDDDDD
    })
    exchangeclone.update_hud(player)
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    hud_elements[player:get_player_name()] = nil
end)

-- Get a player's personal EMC
function exchangeclone.get_player_emc(player)
    -- Can't really change it to "EMC" without everyone losing everything
    return tonumber(player:get_meta():get_string("exchangeclone_stored_energy")) or 0
end

-- Set a player's personal EMC
function exchangeclone.set_player_emc(player, amount)
    amount = tonumber(amount)
    if not (player and amount) then return end
    if amount < 0 or amount > exchangeclone.limit then return end
    player:get_meta():set_string("exchangeclone_stored_energy", tonumber(amount))
    exchangeclone.update_hud(player)
end

-- Add to a player's personal EMC (amount can be negative)
function exchangeclone.add_player_emc(player, amount)
    if not (player and amount) then return end
    player:_set_emc((player:_get_emc() or 0) + amount)
end

-- Through trial and error, I have found that this number (1 trillion) works the best.
-- When a player has any more EMC (as in ANY more), precision-based exploits such as creating infinite glass panes are possible.
-- I temporarily considered finding some Lua library that allowed for arbitrary precision (and therefore infinite maximum EMC)
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
    -- copied from... somewhere
    for name, def in pairs(minetest.registered_items) do
        in_group = false
        for i = 1, num_groups do
            local grp = groups[i]
            local subgroups = grp:split(",")
            local success = true
            for _, subgroup in pairs(subgroups) do
                local group_info = subgroup:split("=")
                if #group_info == 1 then
                    if minetest.get_item_group(name, subgroup) <= 0 then
                        success = false
                        break
                    end
                elseif #group_info == 2 then
                    if minetest.get_item_group(name, group_info[1]) ~= tonumber(group_info[2]) then
                        success = false
                        break
                    end
                else
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
function exchangeclone.play_sound(player, sound, pitch)
    if not player then return end
    minetest.sound_play(sound, {pitch = pitch or 1, pos = player:get_pos(), max_hear_distance = 20, })
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

-- Update the charge level of an ExchangeClone tool
function exchangeclone.charge_update(itemstack, player)
    itemstack = ItemStack(itemstack) -- don't affect original
    local charge_type = exchangeclone.charge_types[itemstack:get_name()]
    local max_charge = exchangeclone.tool_levels.count[charge_type]
    if not max_charge then return itemstack end
    local charge = math.max(itemstack:get_meta():get_int("exchangeclone_tool_charge"), 1)
    local new_pitch = 0.5 + ((0.5 / (max_charge - 1)) * (charge-1))
    if player:get_player_control().sneak then
        if charge > 1 then
            exchangeclone.play_sound(player, "exchangeclone_charge_down", new_pitch)
            charge = charge - 1
        end
    elseif charge < max_charge then
        exchangeclone.play_sound(player, "exchangeclone_charge_up", new_pitch)
        charge = charge + 1
    end
    itemstack:get_meta():set_int("exchangeclone_tool_charge", charge)
    itemstack:set_wear(math.max(1, math.min(65535, 65535-(65535/(max_charge-1))*(charge-1))))
    itemstack = exchangeclone.update_tool_capabilities(itemstack)
    return itemstack
end

exchangeclone.int_limit = 2147483647
exchangeclone.fuel_limit = 2147483583 -- no idea why...

-- Itemstrings for various items used in crafting recipes.
if exchangeclone.mcl then
    exchangeclone.itemstrings = {
        cobble = "mcl_core:cobble",
        stone = "mcl_core:stone",
        redstoneworth = "mesecons:redstone",
        obsidian = "mcl_core:obsidian",
        glowstoneworth = "mcl_nether:glowstone_dust",
        lapisworth = "mcl_core:lapis",
        coal = "mcl_core:coal_lump",
        iron = "mcl_core:iron_ingot",
        copper = "mcl_copper:copper_ingot",
        gold = "mcl_core:gold_ingot",
        emeraldworth = "mcl_core:emerald",
        diamond = "mcl_core:diamond",
        diamondblock = "mcl_core:diamondblock",
        gravel = "mcl_core:gravel",
        dirt = "mcl_core:dirt",
        clay = "mcl_core:clay",
        sand = "mcl_core:sand",
        torch = "mcl_torches:torch",
        book = "mcl_books:book",
        glass = "mcl_core:glass",
        water = "mcl_core:water_source",
        lava = "mcl_core:lava_source",
        water_bucket = "mcl_buckets:bucket_water",
        lava_bucket = "mcl_buckets:bucket_lava",
        empty_bucket = "mcl_buckets:bucket_empty",
        snow = "mcl_core:snow",
        fire = "mcl_fire:fire",
        ice = "mcl_core:ice",
        ender_pearl = "mcl_throwing:ender_pearl",
        chest = "mcl_chests:chest",
        dye_prefix = "mcl_dye:",
        wool_prefix = "mcl_wool:",
    }
elseif exchangeclone.exile then
    exchangeclone.itemstrings = {
        cobble = "nodes_nature:limestone_boulder",
        stone = "nodes_nature:limestone_block",
        redstoneworth = "nodes_nature:jade_boulder",
        obsidian = "nodes_nature:basalt_boulder",
        glowstoneworth = "tech:iron_ingot",
        lapisworth = "tech:green_glass_ingot",
        coal = "tech:charcoal",
        iron = "tech:iron_ingot",
        copper = "tech:clear_glass_ingot",
        gold = "artifacts:moon_glass",
        emeraldworth = "artifacts:antiquorium",
        diamond = "artifacts:moon_stone",
        diamondblock = "artifacts:sun_stone",
        gravel = "nodes_nature:gravel",
        dirt = "nodes_nature:loam",
        clay = "nodes_nature:clay",
        sand = "nodes_nature:sand",
        torch = "tech:torch",
        book = "nodes_nature:reshedaar",
        glass = "tech:green_glass_ingot",
        water = "nodes_nature:freshwater_source",
        lava = "nodes_nature:lava_source",
        water_bucket = "tech:clay_water_pot_freshwater",
        lava_bucket = "artifacts:sun_stone",
        empty_bucket = "tech:clay_water_pot",
        snow = "nodes_nature:snow",
        fire = "inferno:basic_flame",
        ice = "nodes_nature:ice",
        ender_pearl = "nodes_nature:mahal",
        chest = "tech:primitive_wooden_chest",
        dye_prefix = "ncrafting:dye_",
        wool_prefix = "ncrafting:dye_", -- there isn't really dyable blocks
    }
else
    assert(exchangeclone.mtg)
    exchangeclone.itemstrings = {
        cobble = "default:cobble",
        stone = "default:stone",
        redstoneworth = "default:obsidian",
        obsidian = "default:obsidian",
        glowstoneworth = "default:tin_ingot",
        lapisworth = "bucket:bucket_lava",
        coal = "default:coal_lump",
        iron = "default:steel_ingot",
        copper = "default:copper_ingot",
        gold = "default:gold_ingot",
        emeraldworth = "default:mese_crystal",
        diamond = "default:diamond",
        gravel = "default:gravel",
        dirt = "default:dirt",
        clay = "default:clay",
        sand = "default:sand",
        torch = "default:torch",
        book = "default:book",
        glass = "default:glass",
        water = "default:water_source",
        lava = "default:lava_source",
        water_bucket = "bucket:bucket_water",
        lava_bucket = "bucket:bucket_lava",
        empty_bucket = "bucket:bucket_empty",
        snow = "default:snow",
        fire = "fire:fire",
        ice = "default:ice",
        ender_pearl = "default:mese_crystal",
        chest = "default:chest",
        dye_prefix = "dye:",
        wool_prefix = "wool:",
    }
end

exchangeclone.emc_aliases = {}

-- <itemstring> will be treated as <alias> in Deconstructors, Constructors, Transmutation Table(t)s, etc.
-- When you put <itemstring> into a TT, you will learn <alias> instead.
function exchangeclone.register_alias_force(alias, itemstring)
    if alias == itemstring then return end
    exchangeclone.emc_aliases[itemstring] = alias
end

function exchangeclone.register_alias(alias, itemstring)
    if not exchangeclone.emc_aliases[alias] then
        exchangeclone.register_alias_force(alias, itemstring)
    end
end

-- Returns the correct itemstring, handling both Minetest and Exchangeclone aliases.
function exchangeclone.handle_alias(item)
    item = ItemStack(item)
    if not item:is_empty() then
        local de_aliased = exchangeclone.emc_aliases[item:get_name()] or item:get_name() -- Resolve ExchangeClone aliases
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
    if exchangeclone.mtg then
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
    if not (player and name and time and (time > 0)) then return end
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
minetest.register_chatcommand("add_player_emc", {
    params = "[player] <value>",
    description = "Add to a player's personal EMC (player is self if not included, value can be negative to subtract)",
    privs = {privs = true},
    func = function(name, param)
        local split_param = param:split(" ")
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
            minetest.chat_send_player(name, "Bad command. Use /add_player_emc [player] [value] or /add_player_emc [value]")
            return
        end
        local emc = target_player:_get_emc()
        if (emc + value > exchangeclone.limit) or (emc + value < 0) then
            minetest.chat_send_player(name, "Out of bounds; personal EMC must be between 0 and 1 trillion.")
            return
        end
        target_player:_add_emc(tonumber(value))
        minetest.chat_send_player(name, "Added "..exchangeclone.format_number(value).." to "..target_name.."'s personal EMC.")
    end
})

-- Chat commands:
minetest.register_chatcommand("get_player_emc", {
    params = "[player]",
    description = "Gets a player's personal EMC (player is self if not included).",
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
            minetest.chat_send_player(name, "Bad command. Use /get_player_emc [player] or /get_player_emc")
            return
        end
        local emc = target_player:_get_emc()
        minetest.chat_send_player(name, target_name.."'s personal EMC: "..exchangeclone.format_number(emc))
    end
})

minetest.register_chatcommand("set_player_emc", {
    params = "[player] <value>",
    description = "Set a player's personal EMC (player is self if not included; use 'limit' as value to set it to maximum)",
    privs = {privs = true},
    func = function(name, param)
        local split_param = param:split(" ")
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
            minetest.chat_send_player(name, "Bad command. Use /set_player_emc [player] [value] or /set_player_emc [value]")
            return
        end
        if value:lower() == "limit" then
            value = exchangeclone.limit
        elseif (tonumber(value) > exchangeclone.limit) or (tonumber(value) < 0) then
            minetest.chat_send_player(name, "Failed to set EMC; must be between 0 and 1 trillion.")
            return
        end
        target_player:_set_emc(tonumber(value))
        minetest.chat_send_player(name, "Set "..target_name.."'s personal EMC to "..exchangeclone.format_number(value))
    end
})

exchangeclone.neighbors = {
    {x=0, y=-1, z=0},
    {x=0, y=1, z=0},
    {x=-1, y=0, z=0},
    {x=1, y=0, z=0},
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
        if pos then
            exchangeclone.check_nearby_falling(pos)
        end
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

exchangeclone.pickaxe_group = exchangeclone.mcl and "pickaxey" or "cracky"

exchangeclone.shovel_group = exchangeclone.mcl and "shovely" or "crumbly"

exchangeclone.multidig_data = {tools = {}, players = {}}

function exchangeclone.register_multidig_tool(itemstring, nodes)
    exchangeclone.multidig_data.tools[itemstring] = nodes
end

function exchangeclone.multidig(pos, node, player, mode, nodes)
    if not player then return end
    local player_rotation = exchangeclone.get_face_direction(player)

    if mode == "3x3" then
        local dir1
        local dir2
        local unused_dir -- this variable is necessary because vectors get mad when it doesn't exist

        if player_rotation.y ~= 0 then
            dir1 = "x"
            dir2 = "z"
            unused_dir = "y"
        elseif player_rotation.x ~= 0 then
            dir1 = "y"
            dir2 = "z"
            unused_dir = "x"
        elseif player_rotation.z ~= 0 then
            dir1 = "x"
            dir2 = "y"
            unused_dir = "z"
        end

        local pos1 = vector.add(pos, {[dir1] = -1, [dir2] = -1, [unused_dir] = 0})
        local pos2 = vector.add(pos, {[dir1] = 1, [dir2] = 1, [unused_dir] = 0})
        local found_nodes = minetest.find_nodes_in_area(pos1, pos2, nodes)
        for _, node_pos in pairs(found_nodes) do
            minetest.node_dig(node_pos, minetest.get_node(node_pos), player)
        end
    elseif mode == "3x1_long" then
        local dir
        if player_rotation.y ~= 0 then
            dir = "y"
        elseif player_rotation.z ~= 0 then
            dir = "z"
        else
            dir = "x"
        end
        local added_vector = vector.zero()
        added_vector[dir] = player_rotation[dir]*2
        local pos2 = vector.add(pos, added_vector)
        local found_nodes = minetest.find_nodes_in_area(pos, pos2, nodes)
        for _, node_pos in pairs(found_nodes) do
            minetest.node_dig(node_pos, minetest.get_node(node_pos), player)
        end
    elseif mode == "3x1_tall" or mode == "3x1_wide" then
        local dir
        if mode == "3x1_tall" then
            if player_rotation.y ~= 0 then
                if player_rotation.x ~= 0 then
                    dir = "x"
                else
                    dir = "z"
                end
            else
                dir = "y"
            end
        else
            if player_rotation.x ~= 0 then
                dir = "z"
            else
                dir = "x"
            end
        end
        local vector1, vector2 = vector.zero(), vector.zero()
        vector1[dir] = -1
        vector2[dir] = 1
        local pos1 = vector.add(pos, vector1)
        local pos2 = vector.add(pos, vector2)
        local found_nodes = minetest.find_nodes_in_area(pos1, pos2, nodes)
        for _, node_pos in pairs(found_nodes) do
            minetest.node_dig(node_pos, minetest.get_node(node_pos), player)
        end
    end
end

minetest.register_on_dignode(function(pos, node, player)
    if not player then return end
    local player_name = player:get_player_name()
    if exchangeclone.multidig_data.players[player_name] then return end

    local wielded_item = player:get_wielded_item()
    local nodes = exchangeclone.multidig_data.tools[wielded_item:get_name()]
    if nodes then
        exchangeclone.multidig_data.players[player_name] = true
        local mode = wielded_item:get_meta():get_string("exchangeclone_multidig_mode")
        exchangeclone.multidig(pos, node, player, mode, nodes)
        exchangeclone.multidig_data.players[player_name] = nil
    end
end)

minetest.register_on_joinplayer(function(player)
    exchangeclone.multidig_data.players[player:get_player_name()] = nil
end)

exchangeclone.tool_levels = {
    count = {dark_matter = 3, red_matter = 4, red_multi = 5, phil = 5},
    efficiency = {
        dark_matter = {nil, 3, 5},
        red_matter = {nil, 3.5, 5, 7},
        red_multi = {nil, 3.5, 5, 7, 7.5}
    },
    range = {
        hammer = { -- hammer
            type = "front",
            ranges = {
                -- horizontal, vertical, depth (relative to look direction)
                -- horizontal/vertical are radii (1,1 = 3x3, 2,2 = 5,5)
                -- depth does NOT include starting position (1,1,1 mines 3x3x2 area)
                nil,
                {1,1,1},
                {2,2,2},
                {3,3,3},
                {4,4,4}
            }
        },
        flat = {
            type = "radius", -- shovel (dirt/sand), hoe
            ranges = {
                nil,
                vector.new(1,0,1),
                vector.new(2,0,2),
                vector.new(3,0,3),
                vector.new(4,0,4),
            }
        },
        basic_radius = { -- Philosopher's Stone
            type = "radius",
            ranges = {
                nil,
                vector.new(1,1,1),
                vector.new(2,2,2),
                vector.new(3,3,3),
                vector.new(4,4,4),
            }
        },
        large_radius = { -- shears, axe
            type = "radius",
            ranges = {
                nil,
                vector.new(4,4,4),
                vector.new(9,9,9),
                vector.new(14,14,14),
                vector.new(19,19,19),
            }
        },
    }
}

exchangeclone.charge_types = {}

function exchangeclone.set_charge_type(itemstring, type)
    exchangeclone.charge_types[itemstring] = type
end

function exchangeclone.add_range_setting(name, data)
    if not (name and data.type and data.ranges) then return end
    exchangeclone.tool_levels.range[name] = data
end

-- A table of estimated hardness values for MTG
-- Calculated by finding MTG nodes with the right group, then looking up the Minecraft hardness for them
local hacky_workaround = {
    snappy = {1.5, 0.8, 0.2},
    cracky = {5, 3, 2},
    choppy = {5, 3, 2},
    crumbly = {2, 0.6, 0.5}
}

function exchangeclone.get_mtg_times(speed, efficiency, group)
    if efficiency then speed = speed + efficiency*efficiency + 1 end
    local times = {}
    for i, hardness in ipairs(hacky_workaround[group]) do
        times[i] = math.ceil(30/(speed/hardness))/20
    end
    return times
end

-- Given an item and effiency level, return the groupcaps of the item with that efficiency level.
function exchangeclone.get_groupcaps(item, efficiency)
    item = ItemStack(item)
    if exchangeclone.mcl then
        local groupcaps = mcl_autogroup.get_groupcaps(item:get_name(), efficiency)
        return groupcaps
    else -- This only works if the tool is the same speed for every group.
        local groupcaps = table.copy(minetest.registered_items[item:get_name()].tool_capabilities.groupcaps)
        local next, mcl_diggroups = pairs(item:get_definition()._mcl_diggroups)
        local _, mcl_group_def = next(mcl_diggroups)
        local speed = mcl_group_def.speed

        if not groupcaps then return end
        for group, def in pairs(groupcaps) do
            local test_group = group
            if test_group == "exchangeclone_dirt" then test_group = "crumbly" end
            groupcaps[group].times = exchangeclone.get_mtg_times(speed, efficiency, test_group)
        end
        return groupcaps
    end
end

function exchangeclone.update_tool_capabilities(itemstack)
    itemstack = ItemStack(itemstack) -- don't affect original
    local charge_type = exchangeclone.charge_types[itemstack:get_name()]
    if not exchangeclone.tool_levels.efficiency[charge_type] then return itemstack end
    local meta = itemstack:get_meta()
    local charge_level = math.max(1, meta:get_int("exchangeclone_tool_charge"))
    local efficiency = exchangeclone.tool_levels.efficiency[charge_type][charge_level]
    local tool_capabilities = table.copy(minetest.registered_items[itemstack:get_name()].tool_capabilities)
    tool_capabilities.groupcaps = exchangeclone.get_groupcaps(itemstack, efficiency)
    meta:set_tool_capabilities(tool_capabilities)
    return itemstack
end

function exchangeclone.process_range(player, range, charge)
    if not (player and range and charge) then return end
    local range_data = exchangeclone.tool_levels.range[range]
    local range_amounts = range_data.ranges[charge]
    if not range_amounts then return end
    if range_data.type == "radius" then
        return range_amounts, -range_amounts
    elseif range_data.type == "front" then
        local player_rotation = exchangeclone.get_face_direction(player)
        -- relative to player look direction
        local vertical
        local horizontal
        local depth

        if player_rotation.y ~= 0 then
            horizontal = (player_rotation.x ~= 0) and "z" or "x"
            vertical = (player_rotation.x ~= 0) and "x" or "z"
            depth = "y"
        elseif player_rotation.x ~= 0 then
            horizontal = "z"
            vertical = "y"
            depth = "x"
        elseif player_rotation.z ~= 0 then
            horizontal = "x"
            vertical = "y"
            depth = "z"
        end
        return {
            [horizontal] = range_amounts[1],
            [vertical] = range_amounts[2],
            [depth] = 0
        }, {
            [horizontal] = -range_amounts[1],
            [vertical] = -range_amounts[2],
            [depth] = player_rotation[depth]*range_amounts[3]
        }
    end
end

function exchangeclone.add_transmutation_loop(itemstrings)
    for i, itemstring in ipairs(itemstrings) do
        exchangeclone.node_transmutations[1][itemstring] = itemstrings[i+1] or itemstrings[1]
        exchangeclone.node_transmutations[2][itemstring] = itemstrings[i-1] or itemstrings[#itemstrings]
    end
end

function exchangeclone.place_torch(player, pointed_thing)
    local torch_cost = math.max(exchangeclone.get_item_emc(exchangeclone.itemstrings.torch) or 0, 8)
    if player:_get_emc() >= torch_cost then
        local torch_on_place = minetest.registered_items[exchangeclone.itemstrings.torch].on_place
        if torch_on_place then
            torch_on_place(ItemStack(exchangeclone.itemstrings.torch), player, pointed_thing)
            return -torch_cost
        end
    end
end

do
    local timer = 0
    minetest.register_globalstep(function(dtime)
        timer = timer + dtime
        if timer >= 1 then
            timer = 0
            for _, player in pairs(minetest.get_connected_players()) do
                local hb_max = player:hud_get_hotbar_itemcount()
                local inv = player:get_inventory()
                local processed_already = {}
                for i, stack in ipairs(inv:get_list("main")) do
                    if minetest.get_item_group(stack:get_name(), "exchangeclone_passive") then
                        local passive_data = stack:get_definition()._exchangeclone_passive
                        if passive_data
                        and not processed_already[stack:get_name()]
                        and (stack:get_meta():get_string("exchangeclone_active") == "true" or passive_data.always_active)
                        and (not passive_data.hotbar or (passive_data.hotbar and i <= hb_max)) then
                            local found
                            if passive_data.exclude then
                                for _, itemstring in pairs(passive_data.exclude) do
                                    if processed_already[itemstring] then
                                        found = true
                                        break
                                    end
                                end
                            end
                            if not found then
                                processed_already[stack:get_name()] = true
                                local result = passive_data.func(player, stack)
                                if result then inv:set_stack("main", i, result) end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function exchangeclone.toggle_active(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    local meta = itemstack:get_meta()
    local def = itemstack:get_definition()
    if meta:get_string("exchangeclone_active") ~= "true" then
        exchangeclone.play_sound(player, "exchangeclone_enable")
        meta:set_string("exchangeclone_active", "true")
        local active_image = def._exchangeclone_passive.active_image
        if active_image then
            meta:set_string("inventory_image", active_image)
        end
    else
        exchangeclone.play_sound(player, "exchangeclone_charge_down")
        meta:set_string("exchangeclone_active", "")
        meta:set_string("inventory_image", "")
    end
    return itemstack
end

local item_metatable = getmetatable(ItemStack())
item_metatable._get_emc = exchangeclone.get_item_emc
item_metatable._set_emc = exchangeclone.set_item_meta_emc
item_metatable._add_emc = exchangeclone.add_item_meta_emc

item_metatable._get_star_emc = exchangeclone.get_star_itemstack_emc
item_metatable._set_star_emc = exchangeclone.set_star_itemstack_emc
item_metatable._add_star_emc = exchangeclone.add_star_itemstack_emc
item_metatable._get_star_max = exchangeclone.get_star_max

local updated_metatable = false

minetest.register_on_joinplayer(function(player)
    if not updated_metatable then
        local player_metatable = getmetatable(player)
        player_metatable._get_emc = exchangeclone.get_player_emc
        player_metatable._set_emc = exchangeclone.set_player_emc
        player_metatable._add_emc = exchangeclone.add_player_emc
        updated_metatable = true
    end
end)