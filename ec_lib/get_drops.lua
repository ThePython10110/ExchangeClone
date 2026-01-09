-- Modified from MineClone2, basically helps drop items on the player

local doTileDrops = core.settings:get_bool("mcl_doTileDrops", true)

---Gets drops based on fortune level
---@param fortune_drops table[]
---@param fortune_level integer
---@return table
local function get_fortune_drops(fortune_drops, fortune_level)
    local drop
    local i = fortune_level
    repeat
        drop = fortune_drops[i]
        i = i - 1
    until drop or i < 1
    return drop or {}
end

---Don't even remember what this does :D
---@param drops table[]
---@param min_count integer
---@param max_count integer
---@param cap integer
---@return table[]
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

---Gets drops based on toolname
---@param drop table|string
---@param toolname string
---@param param2 integer
---@param paramtype2 string
---@return table
local function get_drops(drop, toolname, param2, paramtype2)
    tmp_id = tmp_id + 1
    local tmp_node_name = "mcl_item_entity:" .. tmp_id
    core.registered_nodes[tmp_node_name] = {
        name = tmp_node_name,
        drop = drop,
        paramtype2 = paramtype2
    }
    local drops = core.get_node_drops({ name = tmp_node_name, param2 = param2 }, toolname)
    core.registered_nodes[tmp_node_name] = nil
    return drops
end

---This function gets the drops from a node and drops them at the player's position
---@param pos vector.Vector
---@param drops table<core.ItemStack|string>
---@param player core.Player
function exchangeclone.drop_items_on_player(pos, drops, player) -- modified from MineClone's code
    if exchangeclone.mtg then
        return core.handle_node_drops(pos, drops, player)
    end
    -- NOTE: This function override allows player to be nil.
    -- This means there is no player. This is a special case which allows this function to be called
    -- by hand. Creative Mode is intentionally ignored in this case.
    if player and player:is_player() and core.is_creative_enabled(player:get_player_name()) then
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
    local dug_node = core.get_node(pos)
    local tooldef
    local tool
    if player then
        tool = player:get_wielded_item()
        tooldef = core.registered_items[tool:get_name()]

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
    local node_name = dug_node.name
    local nodedef = core.registered_nodes[node_name]
    if not nodedef then return end

    if shearsy_level and shearsy_level > 0 and nodedef._mcl_shears_drop then
        if nodedef._mcl_shears_drop == true then
            drops = { node_name }
        else
            drops = nodedef._mcl_shears_drop
        end
    elseif tool and enchantments.silk_touch and nodedef._mcl_silk_touch_drop then
        silk_touch_drop = true
        if nodedef._mcl_silk_touch_drop == true then
            drops = { node_name }
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
        local experience_amount = core.get_item_group(dug_node.name, "xp")
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
            local obj = core.add_item(player:get_pos(), drop_item)
            if obj then
                -- set the velocity multiplier to the stored amount or if the game dug this node, apply a bigger velocity
                obj:get_luaentity().age = 0.65
                obj:get_luaentity()._insta_collect = true
            end
        end
    end
end