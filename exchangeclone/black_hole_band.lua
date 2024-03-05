-- Some of this is copied from `sneak_drop` by Krunegan because I was too lazy to do it myself
local function pickup_items(player)
    local pos = player:get_pos()
    local objs = minetest.get_objects_inside_radius(pos, 3)
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
                exchangeclone.play_sound(player, "exchangeclone_pickup")
            end
        end
    end
end

minetest.register_tool("exchangeclone:black_hole_band", {
    description = "Black Hole Band",
    inventory_image = "exchangeclone_black_hole_band.png",
    groups = {disable_repair = 1, fire_immune = 1},
    _exchangeclone_passive = {
        func = pickup_items,
        hotbar = true,
        active_image = "exchangeclone_life_stone_active.png",
        exclude = {"exchangeclone:void_ring"}
    },
})