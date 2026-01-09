---Adds all items in a certain inventory list to a table.
---@param pos vector.Vector
---@param listname string
---@param drops table[]
function exchangeclone.get_inventory_drops(pos, listname, drops)
    local inv = core.get_meta(pos):get_inventory()
    local n = #drops
    for i = 1, inv:get_size(listname) do
        local stack = inv:get_stack(listname, i)
        if stack:get_count() > 0 then
            drops[n+1] = stack:to_table()
            n = n + 1
        end
    end
end

---Drops items when exploded
---@param lists string[]
---@return function(pos: vector.Vector): table[]
function exchangeclone.on_blast(lists)
    return function(pos)
        local drops = {}
        for _, list in pairs(lists) do
            exchangeclone.get_inventory_drops(pos, list, drops)
        end
        table.insert(drops, core.get_node(pos).name)
        core.remove_node(pos)
        if exchangeclone.mcl then
            for _, drop in pairs(drops) do
                local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                core.add_item(p, drop)
            end
        end
        return drops
    end
end

function exchangeclone.can_dig(pos)
    -- Always allow digging in MCL
    if exchangeclone.mcl then return true end
    -- Only allow digging of empty containers in MTG
    local inv = core.get_inventory({type="node", pos=pos})
    for listname, _ in pairs(inv:get_lists()) do
        if not inv:is_empty(listname) then
            return false
        end
    end
    return true
end