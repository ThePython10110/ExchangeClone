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
                exchangeclone.play_sound(player, "exchangeclone_pickup")
            else
                obj:set_pos(vector.offset(player:get_pos(), 0, 1, 0))
            end
        end
    end
end

minetest.register_tool("exchangeclone:black_hole_band", {
    description = "Black Hole Band",
    inventory_image = "exchangeclone_black_hole_band.png",
    on_secondary_use = exchangeclone.toggle_active,
    on_place = exchangeclone.toggle_active,
    groups = {exchangeclone_passive = 1, disable_repair = 1},
    _exchangeclone_passive = {
        func = pickup_items,
        hotbar = true,
        active_image = "exchangeclone_black_hole_band_active.png",
        exclude = {"exchangeclone:void_ring"}
    },
})