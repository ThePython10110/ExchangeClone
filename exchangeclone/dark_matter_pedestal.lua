local function pedestal_action(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack("main", 1)
    if stack:is_empty() then
        minetest.log("empty")
        minetest.get_node_timer(pos):stop()
        return
    end
    local def = stack:get_definition()
    if not def then
        minetest.log("no def")
        minetest.get_node_timer(pos):stop()
        return
    end
    local func = def._exchangeclone_pedestal
    if func then
        minetest.log("Running function")
        inv:set_stack("main", 1, func(pos, stack) or stack)
        local new_stack = inv:get_stack("main", 1)
        if not (new_stack:get_definition() and new_stack:get_definition()._exchangeclone_pedestal) then
            minetest.log("fail 2")
            minetest.get_node_timer(pos):stop()
        end
    else
        minetest.log("no func")
        minetest.get_node_timer(pos):stop()
    end
end

minetest.register_node("exchangeclone:dark_matter_pedestal", {
    "Dark Matter Pedestal",
    drawtype = "nodebox",
    tiles = {"exchangeclone_dark_matter_block.png"},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.3125, -0.5000, -0.3125, 0.3125, -0.3750, 0.3125},
            {-0.1250, -0.3750, -0.1250, 0.1250, 0.06250, 0.1250},
            {-0.1875, 0.06250, -0.1875, 0.1875, 0.1250, 0.1875}
        }
    },
    on_punch = function(pos, node, player, pointed_thing)
        local wielded_item = player:get_wielded_item()
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        if not inv:is_empty("main") and wielded_item:is_empty() then
            minetest.log("Should be an item")
            minetest.add_item(vector.offset(pos,0,0.5,0), inv:get_stack("main", 1))
            inv:set_stack("main", 1, ItemStack(""))
        else
            minetest.log("Nothing happened (punch)")
        end
    end,
    on_rightclick = function(pos, node, player, pointed_thing)
        local wielded_item = player:get_wielded_item()
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        if not inv:is_empty("main") and wielded_item:is_empty() then
            local stack = inv:get_stack("main", 1)
            local pedestal_data = stack:get_definition()._exchangeclone_pedestal
            if pedestal_data then
                if minetest.get_node_timer(pos):is_started() then
                    minetest.log("Off")
                    minetest.sound_play("exchangeclone_charge_down", {pos = pos, max_hear_distance = 20})
                    minetest.get_node_timer(pos):stop()
                else
                    minetest.log("On")
                    minetest.sound_play("exchangeclone_enable", {pos = pos, max_hear_distance = 20})
                    minetest.get_node_timer(pos):start(1,0)
                end
            else
                minetest.log("No pedestal data")
            end
        elseif inv:is_empty("main") and not wielded_item:is_empty() and wielded_item:get_stack_max() == 1 then
            minetest.log(wielded_item:get_name())
            inv:set_stack("main", 1, wielded_item:take_item())
            --wielded_item:set_count(wielded_item:get_count() - 1)
            if wielded_item:get_count() <= 0 then wielded_item = ItemStack("") end
            minetest.log(tostring(wielded_item))
            return wielded_item
        else
            minetest.log("Nothing happened (rightclick)")
        end
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 1)
    end,
    on_timer = pedestal_action,
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = exchangeclone.mtg and 4 or 0},
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 12,
})