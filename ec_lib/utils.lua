---Returns a player's inventory formspec with the correct width and hotbar position for the current game
---@param x number
---@param y number
---@return string
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

---Check the clicked node for a right-click function.
---@param itemstack core.ItemStack
---@param player core.Player
---@param pointed_thing table
---@return core.ItemStack|false
function exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if pointed_thing.type ~= "node" then return false end
    if player:get_player_control().sneak then return false end
    local node = core.get_node(pointed_thing.under)
    if player and not player:get_player_control().sneak then
        if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
            return core.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
        end
    end
    return false
end

---Plays a sound in a certain way (not really necessary, but looks nice)
---@param player core.Player
---@param sound string
---@param pitch number?
function exchangeclone.play_sound(player, sound, pitch)
    if not player then return end
    core.sound_play(sound, {pitch = pitch or 1, pos = player:get_pos(), max_hear_distance = 20, })
end

---From https://stackoverflow.com/questions/10989788/format-integer-in-lua
---Formats an integer with commas, accounting for decimal points.
---@param number number|string
---@return string
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

---Returns a table of all items in the specified group(s). Slow.
---@param groups string[]|string
---@param allow_duplicates boolean?
---@param include_no_group boolean?
---@return table?
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
    for name in pairs(core.registered_items) do
        in_group = false
        for i = 1, num_groups do
            local grp = groups[i]
            local subgroups = grp:split(",")
            local success = true
            for _, subgroup in pairs(subgroups) do
                local group_info = subgroup:split("=")
                if #group_info == 1 then
                    if core.get_item_group(name, subgroup) <= 0 then
                        success = false
                        break
                    end
                elseif #group_info == 2 then
                    if core.get_item_group(name, group_info[1]) ~= tonumber(group_info[2]) then
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

---Get the direction a player is facing (rounded to -1, 0, and 1 for each axis)
---@param player core.Player
---@return vector.Vector
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