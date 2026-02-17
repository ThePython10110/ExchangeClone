---@class core.ItemStack
---@field _get_star_emc fun(itemstack: core.ItemStack) : number?
---@field _set_star_emc fun(itemstack: core.ItemStack, amount : number)
---@field _add_star_emc fun(itemstack: core.ItemStack, amount : number)
---@field _get_emc fun(item: string|core.ItemStack) : number?

---@class core.Player
---@field _get_emc fun(player: core.Player) : number
---@field _set_emc fun(itemstack: core.Player, amount : number)
---@field _add_emc fun(itemstack: core.Player, amount : number)

---Gets the EMC value of an itemstring or ItemStack
---Handles "group:group_name" syntax (although it goes through every item), returns cheapest item in group
---@param item string|core.ItemStack
---@return number?
function exchangeclone.get_item_emc(item)
    if (item == "") or not item then return end

    -- handle groups
    if type(item) == "string" and item:sub(1,6) == "group:" and exchangeclone.group_values then
        local item_group = item:sub(7,-1)
        for _, group in pairs(exchangeclone.group_values) do
            if item_group == group[1] then return group[2] end
        end
        local group_items = exchangeclone.get_group_items(item_group)
        if not group_items then return end
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
        ---@cast item core.ItemStack
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

    local def = core.registered_items[item:get_name()]
    if not def then return end
    if core.get_item_group(item:get_name(), "klein_star") > 0 then
        if def.emc_value then
            return def.emc_value + item:_get_star_emc()
        end
    end
    if def.emc_value then
        return (def.emc_value) * item:get_count()
    end
end

---Sets an ItemStack's metadata EMC value
---@param item core.ItemStack
---@param value number
function exchangeclone.set_item_meta_emc(item, value)
    if getmetatable(item) ~= getmetatable(ItemStack()) then
        return
    end
    item:get_meta():set_string("exchangeclone_emc_value", value)

    local description = item:get_description()

    -- Override EMC value in description
    local existing_emc_value = description:find("EMC: ([%d%.,]+)")
    if existing_emc_value then
        description = description:gsub("EMC: ([%d%.,]+)", "EMC: "..exchangeclone.format_number(value))
    else
        if description[#description] ~= "\n" then
            description = description.."\n"
        end
        description = description.."EMC: "..exchangeclone.format_number(value)
    end
    item:get_meta():set_string("description", description)
end

---Adds to an ItemStack's metadata EMC value
---@param item core.ItemStack
---@param value number
function exchangeclone.add_item_meta_emc(item, value)
    if getmetatable(item) ~= getmetatable(ItemStack()) then
        return
    end
    local current_value = item:get_meta():get_string("exchangeclone_emc_value")
    if current_value == "" or current_value == "none" then
---@diagnostic disable-next-line: cast-local-type
        current_value = 0
    else
---@diagnostic disable-next-line: cast-local-type
        current_value = tonumber(current_value)
    end
    item:get_meta():set_string("exchangeclone_emc_value", current_value + value)
end

---Remaps a number from one range to another
---See https://forum.unity.com/threads/re-map-a-number-from-one-range-to-another.119437/
---@param input number
---@param min1 number
---@param max1 number
---@param min2 number
---@param max2 number
---@return number
function exchangeclone.map(input, min1, max1, min2, max2)
    return (input - min1) / (max1 - min1) * (max2 - min2) + min2
end

--- Gets the EMC stored in a specified Klein/Magnum Star itemstack.
---@param itemstack core.ItemStack
---@return number?
function exchangeclone.get_star_itemstack_emc(itemstack)
    if not itemstack then return end
    if getmetatable(itemstack) ~= getmetatable(ItemStack()) then
        return
    end
    if core.get_item_group(itemstack:get_name(), "klein_star") < 1 then return end
    return math.max(itemstack:get_meta():get_float("stored_energy"), 0)
end

---Gets the amount of EMC stored in a star in a specific inventory slot
---@param inventory core.InvRef
---@param listname string
---@param index integer
---@return number?
function exchangeclone.get_star_emc(inventory, listname, index)
    if not inventory then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    return itemstack:_get_star_emc()
end

---Sets the EMC stored in a specified Klein/Magnum Star itemstack.
---@param itemstack core.ItemStack
---@param amount number
function exchangeclone.set_star_itemstack_emc(itemstack, amount)
    if not itemstack or not amount then return end
    if core.get_item_group(itemstack:get_name(), "klein_star") < 1 then return end
    local old_emc = itemstack:_get_star_emc()
    local max = exchangeclone.get_star_max(itemstack)
    if amount > old_emc and old_emc > max then return end -- don't allow more EMC to be put into an over-filled star

    local meta = itemstack:get_meta()
    meta:set_float("stored_energy", amount) -- Unfortunately, this is still "energy" not EMC
    meta:set_string("description", itemstack:get_definition()._mcl_generate_description(itemstack))
    local wear = math.max(1, math.min(65535, 65535 - 65535*amount/max))
    itemstack:set_wear(wear)
end

---Sets the amount of EMC stored in a star in a specific inventory slot
---@param inventory core.InvRef
---@param listname string
---@param index integer
---@param amount number
function exchangeclone.set_star_emc(inventory, listname, index, amount)
    if not inventory or not amount or amount < 0 then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    itemstack:_set_star_emc(amount)
    inventory:set_stack(listname, index, itemstack)
end

---Adds to the amount of EMC stored in a specified Klein/Magnum Star itemstack.
---@param itemstack core.ItemStack
---@param amount number
function exchangeclone.add_star_itemstack_emc(itemstack, amount)
    if itemstack and amount then
        local emc = itemstack:_get_star_emc() + amount
        if not emc or emc < 0 or emc > exchangeclone.get_star_max(itemstack) then return end
        itemstack:_set_star_emc(emc)
    end
end

---Adds to the amount of EMC in a star in a specific inventory slot
---@param inventory core.InvRef
---@param listname string
---@param index integer
---@param amount number
function exchangeclone.add_star_emc(inventory, listname, index, amount)
    if not (inventory and listname and index and amount) then return end
    if not listname then listname = "main" end
    if not index then index = 1 end
    local itemstack = inventory:get_stack(listname, index)
    exchangeclone.add_star_itemstack_emc(itemstack, amount)
    inventory:set_stack(listname, index, itemstack)
end

---Gets the maximum capacity of a star.
---@param item core.ItemStack|string
---@return number
function exchangeclone.get_star_max(item)
    item = ItemStack(item)
    return item:get_definition().max_capacity or 0
end

---Get a player's personal EMC
---@param player core.Player
---@return number
function exchangeclone.get_player_emc(player)
    -- Can't really change it to "EMC" without everyone losing everything
    return tonumber(player:get_meta():get_string("exchangeclone_stored_energy")) or 0
end

---Set a player's personal EMC
---@param player core.Player
---@param amount number
function exchangeclone.set_player_emc(player, amount)
---@diagnostic disable-next-line: cast-local-type
    amount = tonumber(amount)
    if not (player and amount) then return end
    if amount < 0 or amount > exchangeclone.emc_limit then return end
    player:get_meta():set_string("exchangeclone_stored_energy", tonumber(amount))
    exchangeclone.update_hud(player)
end

---Add to a player's personal EMC (amount can be negative)
---@param player core.Player
---@param amount number
function exchangeclone.add_player_emc(player, amount)
    if not (player and amount) then return end
    player:_set_emc((player:_get_emc() or 0) + amount)
end

local item_metatable = getmetatable(ItemStack())
item_metatable._get_emc = exchangeclone.get_item_emc
item_metatable._set_emc = exchangeclone.set_item_meta_emc
item_metatable._add_emc = exchangeclone.add_item_meta_emc

item_metatable._get_star_emc = exchangeclone.get_star_itemstack_emc
item_metatable._set_star_emc = exchangeclone.set_star_itemstack_emc
item_metatable._add_star_emc = exchangeclone.add_star_itemstack_emc
item_metatable._get_star_max = exchangeclone.get_star_max

-- Metatable only needs to be updated once per load, but can only be updated when a player exists
local updated_metatable = false

core.register_on_joinplayer(function(player)
    if updated_metatable then return end

    local player_metatable = getmetatable(player)
    player_metatable._get_emc = exchangeclone.get_player_emc
    player_metatable._set_emc = exchangeclone.set_player_emc
    player_metatable._add_emc = exchangeclone.add_player_emc
    updated_metatable = true
end)
