---Checks if an item is fuel
---@param item core.ItemStack
---@return boolean
function exchangeclone.is_fuel(item)
	return core.get_craft_result({method = "fuel", width = 1, items = {item}}).time ~= 0
end

---Checks if an item is not fuel
---@param item core.ItemStack
---@return boolean
function exchangeclone.isnt_fuel(item)
	return not exchangeclone.is_fuel(item)
end

-- Copied from MCL2
--- Selects item stack to transfer from
--- @param src_inventory core.InvRef Source inventory to pull from
--- @param src_list string Name of source inventory list to pull from
--- @param dst_inventory core.InvRef Destination inventory to push to
--- @param dst_list string Name of destination inventory list to push to
--- @param condition? fun(stack: core.ItemStack) Condition which items are allowed to be transfered.
--- @return integer? Item stack number to be transfered
function exchangeclone.select_stack(src_inventory, src_list, dst_inventory, dst_list, condition)
	local src_size = src_inventory:get_size(src_list)
	local stack
	for i = 1, src_size do
		stack = src_inventory:get_stack(src_list, i)
		if not stack:is_empty() and dst_inventory:room_for_item(dst_list, stack) and ((condition == nil or condition(stack))) then
			return i
		end
	end
end

function exchangeclone.mcl2_hoppers_on_try_pull(dst_condition, fuel_condition)
    if not exchangeclone.mcl2 then return end
    return function(pos, hop_pos, hop_inv, hop_list)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        if exchangeclone.select_stack(inv, "dst", hop_inv, hop_list) then
            return inv, "dst", exchangeclone.select_stack(inv, "dst", hop_inv, hop_list, dst_condition)
        end
    end
end

function exchangeclone.mcl2_hoppers_on_try_push(src_condition, fuel_condition)
    if not exchangeclone.mcl2 then return end
    return function(pos, hop_pos, hop_inv, hop_list)
        local meta = core.get_meta(pos)
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
        local sinv = core.get_inventory({type="node", pos = pos})
        local dinv = core.get_inventory({type="node", pos = to_pos})
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
			local finv = core.get_inventory({type="node", pos=uppos})
			if finv and fuel_condition(finv:get_stack("fuel", 1)) then
				sucked = mcl_util.move_item_container(uppos, pos, "fuel")
			end
		end
        if sucked and action then action(pos) end
		return sucked
	end
end