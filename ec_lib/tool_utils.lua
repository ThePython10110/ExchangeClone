

---Update the charge level of an ExchangeClone tool
---@param itemstack core.ItemStack
---@param player core.Player
---@return core.ItemStack
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

---Returns the corners of a box defined by a specific range
---@param player core.Player
---@param range string
---@param charge integer
---@return vector.Vector?
---@return vector.Vector?
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

---Places a torch where a player is looking. Returns the EMC cost or nil.
---@param player core.Player
---@param pointed_thing core.PointedThing
---@return number?
function exchangeclone.place_torch(player, pointed_thing)
    local torch_cost = math.max(exchangeclone.get_item_emc(exchangeclone.itemstrings.torch) or 0, 8)
    if player:_get_emc() >= torch_cost then
        local torch_on_place = core.registered_items[exchangeclone.itemstrings.torch].on_place
        if torch_on_place then
            torch_on_place(ItemStack(exchangeclone.itemstrings.torch), player, pointed_thing)
            return -torch_cost
        end
    end
end