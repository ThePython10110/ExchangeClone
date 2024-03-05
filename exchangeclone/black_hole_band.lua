-- Some of this is copied from `sneak_drop` by Krunegan because I was too lazy to do it myself
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
                minetest.sound_play("sneak_drop_pickup", {
                    pos = pos,
                    max_hear_distance = 16,
                    gain = 0.4,
                })
            end
        end
    end
end