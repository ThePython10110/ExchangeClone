-- I want to make this without a formspec.

local function on_rightclick(pos, node, player, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if player:get_player_control().sneak then
        local contained = inv:get_stack("star", 1)
        if minetest.get_item_group(itemstack:get_name(), "klein_star") > 0 then
            inv:set_stack("star", 1, itemstack)
            return contained
        elseif itemstack:is_empty() then
            inv:set_stack("star", 1, ItemStack(""))
            return contained
        end
    elseif not itemstack:is_empty() then
        local dealiased = exchangeclone.handle_alias(itemstack)
        local emc = exchangeclone.get_item_emc(dealiased)
        if emc and emc > 0 then
            minetest.chat_send_player(player:get_player_name(), "Target Item: "..ItemStack(dealiased):get_short_description())
            meta:set_string("target_item", dealiased)
        end
    end
end

minetest.register_node("exchangeclone:emc_link", {
    description = "EMC Link\nAllows automation with personal EMC",
    tiles = {"exchangeclone_emc_link.png"},
    on_rightclick = on_rightclick,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("star", 1)
        inv:set_size("input", 1)
        inv:set_size("output", 1)
        meta:set_string("infotext", "EMC Link")
    end,
    after_place_node = function(pos, player, itemstack, pointed_thing)
        local player_name = player:get_player_name()
        local meta = minetest.get_meta(pos)
        meta:set_string("exchangeclone_placer", player_name)
        meta:set_string("infotext", "EMC Link".."\n"..S("Owned by ")..player_name)
        if exchangeclone.pipeworks then
            pipeworks.after_place(pos, player, itemstack, pointed_thing)
        end
    end,
})