local function get_constructor_formspec()
    if not exchangeclone.mcl then
        local formspec = {
            "size[8,9]",
            "label[2,1;Orb]",
            "list[context;fuel;2,2;1,1;]",
            "label[3,1;Source]",
            "list[context;src;3,2;1,1;]",
            "label[5,1;Output]",
            "list[context;dst;5,2;1,1;]",
            "list[current_player;main;0,5;8,4;]",
            "listring[current_player;main]",
            "listring[context;src]",
            "listring[current_player;main]",
            "listring[context;fuel]",
            "listring[current_player;main]",
            "listring[context;dst]",
        }
        return table.concat(formspec, "")
    else
        local formspec = {
            "size[9,10]",
            "label[2,1;Orb]",
            "list[context;fuel;2,2;1,1;]",
            mcl_formspec.get_itemslot_bg(2,2,1,1),
            "label[3,1;Source]",
            "list[context;src;3,2;1,1;]",
            mcl_formspec.get_itemslot_bg(3,2,1,1),
            "label[5,1;Output]",
            "list[context;dst;5,2;1,1;]",
            mcl_formspec.get_itemslot_bg(5,2,1,1),
            "list[current_player;main;0,5;9,3;9]",
            mcl_formspec.get_itemslot_bg(0,5,9,3),
            "list[current_player;main;0,8.5;9,1;]",
            mcl_formspec.get_itemslot_bg(0,8.5,9,1),
            "listring[current_player;main]",
            "listring[context;src]",
            "listring[current_player;main]",
            "listring[context;fuel]",
            "listring[current_player;main]",
            "listring[context;dst]",
        }
        return table.concat(formspec, "")
    end
end

-- Register LBM to update constructors
minetest.register_lbm({
    name = "exchangeclone:constructor_alert",
    nodenames = {"exchangeclone:constructor"},
    run_at_every_load = true,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", "size[3,1]label[0,0;BREAK AND REPLACE]")
    end,
})

local function can_dig(pos, player)
    if exchangeclone.mcl then return true end
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    return inv:is_empty("fuel") and inv:is_empty("src") and inv:is_empty("dst")
end

local function constructor_action(pos)
    local inv = minetest.get_meta(pos):get_inventory()
    local src_stack = inv:get_stack("src", 1)
    local dst_stack = inv:get_stack("dst", 1)

    if not inv:is_empty("fuel") and not inv:is_empty("src") then
        -- make sure the stack at dst is same as the src (including enchantments)
        if not inv:is_empty("dst") then
            if src_stack:get_name() ~= dst_stack:get_name() then
                if exchangeclone.mcl then
                    if not(string.sub(src_stack:get_name(), -10, -1) == "_enchanted"
                    and string.sub(src_stack:get_name(), 1, -11) == dst_stack:get_name()
                    and src_stack:get_name() ~= "mcl_core:apple_gold_enchanted") then
                        return
                    end
                else
                    return
                end
            end
        end
        local result = src_stack:get_name()
        if exchangeclone.mcl
        and string.sub(result, -10, -1) == "_enchanted"
        and result ~= "mcl_core:apple_gold_enchanted" then
            result = string.sub(src_stack:get_name(), 1, -11)
        end
        -- make sure orb has enough charge
        local orb_charge = exchangeclone.get_orb_energy(inv, "fuel", 1)
        local energy_value = exchangeclone.get_item_energy(src_stack:get_name())
        if energy_value > 0 then
            local max_amount = math.min(src_stack:get_stack_max(), math.floor(orb_charge/energy_value))
            local added_amount = max_amount - inv:add_item("dst", ItemStack(result.." "..max_amount)):get_count()
            exchangeclone.set_orb_energy(inv, "fuel", 1, math.min(orb_charge, orb_charge - (energy_value * added_amount))) -- not sure if "math.min()" is necessary
        end
    end
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    meta:set_string("formspec", get_constructor_formspec())
    meta:set_string("infotext", "Constructor")
    constructor_action(pos)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    if listname == "fuel" then
        if stack:get_name() == "exchangeclone:exchange_orb" then
            return stack:get_count()
        else
            return 0
        end
    elseif listname == "src" then
        return stack:get_count()

    elseif listname == "dst" then
        return 0
    end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack(from_list, from_index)
    return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    return stack:get_count()
end

local function on_blast(pos)
    local drops = {}
    exchangeclone.get_inventory_drops(pos, "fuel", drops)
    exchangeclone.get_inventory_drops(pos, "src", drops)
    exchangeclone.get_inventory_drops(pos, "dst", drops)
    drops[#drops+1] = "exchangeclone:constructor"
    minetest.remove_node(pos)
    return drops
end

minetest.register_node("exchangeclone:constructor", {
    description = "Constructor",
    tiles = {
        "exchangeclone_constructor_up.png",
        "exchangeclone_constructor_down.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png"
    },
    groups = {cracky = 2, container = 4, pickaxey = 2},
    _mcl_hardness = 3,
	_mcl_blast_resistance = 6,
    sounds = exchangeclone.sound_mod.node_sound_metal_defaults(),
    is_ground_content = false,
    can_dig = can_dig,
    after_dig_node = function(pos, oldnode, oldmetadata, player)
        if exchangeclone.mcl then
            local meta = minetest.get_meta(pos)
            local meta2 = meta:to_table()
            meta:from_table(oldmetadata)
            local inv = meta:get_inventory()
            for _, listname in ipairs({"src", "dst", "fuel"}) do
                local stack = inv:get_stack(listname, 1)
                if not stack:is_empty() then
                    local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                    minetest.add_item(p, stack)
                end
            end
            meta:from_table(meta2)
        end
	end,
    on_timer = constructor_action,
    on_construct = on_construct,
    on_metadata_inventory_move = constructor_action,
    on_metadata_inventory_put = constructor_action,
    on_metadata_inventory_take = constructor_action,
    on_blast = on_blast,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})

local recipe_ingredient = "default:pick_diamond"

if exchangeclone.mcl then
    recipe_ingredient = "mcl_tools:pick_diamond"
end
minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:constructor",
    recipe = {
        {"", "exchangeclone:exchange_orb",""},
        {"", recipe_ingredient, ""},
        {"", "exchangeclone:exchange_orb",  ""}
    }
})