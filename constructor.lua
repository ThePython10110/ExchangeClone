

function get_element_constructor_formspec()
    if not exchangeclone.mineclone then
        local formspec = {
            "size[8,9]",
            "label[2,1;Orb]",
            "list[context;fuel;2,2;1,1;]",
            "label[3,1;Source]",
            "list[context;src;3,2;1,1;]",
            "label[5,1;Output]",
            "list[context;dst;5,2;1,1;]",
            "list[current_player;main;0,5;8,4;]",
            "listring[context;fuel]",
            "listring[current_player;main]",
            "listring[context;src]",
            "listring[current_player;main]",
            "listring[context;dst]",
            "listring[current_player;main]"
        }
        return table.concat(formspec, "")
    else
        local formspec = {
            "size[9,9]",
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
            "list[current_player;main;0,6;9,1;]",
            mcl_formspec.get_itemslot_bg(0,6,9,1),
            "listring[context;fuel]",
            "listring[current_player;main]",
            "listring[context;src]",
            "listring[current_player;main]",
            "listring[context;dst]",
            "listring[current_player;main]"
        }
    end
end

local function can_dig(pos, player)
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    return inv:is_empty("fuel") and inv:is_empty("src") and inv:is_empty("dst")
end

local function on_timer(pos, elapsed)
    local inv = minetest.get_meta(pos):get_inventory()
    local update = true
    while elapsed > 0 and update do
        update = false
        local fuel_stack = inv:get_stack("fuel", 1)
        local src_stack = inv:get_stack("src", 1)
        local dst_stack = inv:get_stack("dst", 1)

        if not inv:is_empty("fuel") and not inv:is_empty("src") then
            -- make sure the stack at dst is same as the src
            if not inv:is_empty("dst") then
                if not(src_stack:get_name() == dst_stack:get_name()) then
                    break
                end
            end
            -- make sure orb has enough charge
            local orb_charge = fuel_stack:get_meta():get_int("stored_charge") or 0
            orb_charge = orb_charge - get_item_energy(src_stack:get_name())
            if orb_charge < 0 then
                break
            end
            -- give orb new charge value
            fuel_stack:get_meta():set_int("stored_charge", orb_charge)
            inv:set_stack("fuel", 1, fuel_stack)
            -- "convert" charge into a node at dst
            if dst_stack:is_empty() then
                -- create a new stack
                dst_stack = ItemStack(src_stack:get_name())
            elseif dst_stack:get_count() >= 64 then
                -- the max item count is limited to 64
                break
            else
                -- add one node into stack
                dst_stack:set_count(dst_stack:get_count() + 1)
            end
            inv:set_stack("dst", 1, dst_stack)
            update = true
        end
    end
    minetest.get_node_timer(pos):stop()
    return false
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    meta:set_string("formspec", get_element_constructor_formspec())
    meta:set_string("infotext", "Element Constructor")
    on_timer(pos, 0)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "fuel" then
        if stack:get_name() == "exchangeclone:exchange_orb" then
            return stack:get_count()
        else
            return 0
        end
    elseif listname == "src" or listname == "dst" then
        return stack:get_count()
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
    default.get_inventory_drops(pos, "fuel", drops)
    default.get_inventory_drops(pos, "src", drops)
    default.get_inventory_drops(pos, "dst", drops)
    drops[#drops+1] = "exchangeclone:element_constructor"
    minetest.remove_node(pos)
    return drops
end

minetest.register_node("exchangeclone:element_constructor", {
    description = "Element Constructor",
    tiles = {
        "ee_constructor_up.png",
        "ee_constructor_down.png",
        "ee_constructor_right.png",
        "ee_constructor_right.png",
        "ee_constructor_right.png",
        "ee_constructor_right.png"
    },
    groups = {cracky = 2},
    is_ground_content = false,
    can_dig=can_dig,
    on_timer = on_timer,
    on_construct = on_construct,
    on_metadata_inventory_move = function(pos)
        minetest.get_node_timer(pos):start(1.0)
    end,
    on_metadata_inventory_put = function(pos)
        minetest.get_node_timer(pos):start(1.0)
    end,
    on_metadata_inventory_take = function(pos)
        minetest.get_node_timer(pos):start(1.0)
    end,
    on_blast = on_blast,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})

local recipe_ingredient = "default:pick_diamond"

if exchangeclone.mineclone then
    recipe_ingredient = "mcl_tools:pick_diamond"
end
minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:element_constructor",
    recipe = {
        {"", "exchangeclone:exchange_orb",""},
        {"exchangeclone:exchange_orb", recipe_ingredient, "exchangeclone:exchange_orb"},
        {"", "exchangeclone:exchange_orb",  ""}
    }
})