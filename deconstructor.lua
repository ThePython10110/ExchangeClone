local sound_mod
if mcl_sounds then
    sound_mod = mcl_sounds
else
    sound_mod = default
end

--Renamed "fuel" inventory to "main" to (almost) work with hoppers

local function get_element_deconstructor_formspec()
    if not exchangeclone.mineclone then
        local formspec = {
            "size[8,9]",
            "label[2,1;Fuel]",
            "list[context;main;2,2;1,1;]",
            "label[5,1;Orb]",
            "list[context;dst;5,2;1,1;]",
            "list[current_player;main;0,5;8,4;]",
            "listring[current_player;main]",
            "listring[context;main]",
            "listring[current_player;main]",
            "listring[context;dst]",
        }
        return table.concat(formspec, "")
    else
        local formspec = {
            "size[9,10]",
            "label[2,1;Fuel]",
            "list[context;main;2,2;1,1;]",
            mcl_formspec.get_itemslot_bg(2,2,1,1),
            "label[5,1;Orb]",
            "list[context;dst;5,2;1,1;]",
            mcl_formspec.get_itemslot_bg(5,2,1,1),
            "list[current_player;main;0,5;9,3;9]",
            mcl_formspec.get_itemslot_bg(0,5,9,3),
            "list[current_player;main;0,8.5;9,1;]",
            mcl_formspec.get_itemslot_bg(0,8.5,9,1),
            "listring[current_player;main]",
            "listring[context;main]",
            "listring[current_player;main]",
            "listring[context;dst]"
        }
        return table.concat(formspec, "")
    end
end

local function can_dig(pos, player)
    if exchangeclone.mineclone then return true end
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    return inv:is_empty("main") and inv:is_empty("dst")
end

local function on_timer(pos, elapsed)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local update = true
    while elapsed > 0 and update do
        update = false
        if not inv:is_empty("dst") and not inv:is_empty("main") then
            -- remove one item from fuel inventory
            local fuel_stack = inv:get_stack("main", 1)
            local energy_value = 0
            if fuel_stack:get_name() == "exchangeclone:exchange_orb" then
                energy_value = (fuel_stack:get_meta():get_float("stored_charge") or 0) + 33792 --33792 = energy cost of orb
            else
                energy_value = exchangeclone.get_item_energy(fuel_stack:get_name())
            end
            if energy_value == 0 then
                break
            else
                local wear = fuel_stack:get_wear()
                if wear and wear > 1 then
                    energy_value = math.ceil(energy_value * (65536 / wear))
                end
                -- only get 1 orb as we can only use one
                local stored = exchangeclone.get_orb_energy(inv, "dst", 1)
                if stored + energy_value < stored then
                    return --will hopefully prevent overflow, not that overflow is likely
                end
                fuel_stack:set_count(fuel_stack:get_count() - 1)
                inv:set_stack("main", 1, fuel_stack)
                stored = stored + energy_value
                exchangeclone.set_orb_energy(inv, "dst", 1, stored)
            end
            update = true
        end
    end
    minetest.get_node_timer(pos):stop()
    return false
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 1)
    inv:set_size("dst", 1)
    meta:set_string("formspec", get_element_deconstructor_formspec())
    meta:set_string("infotext", "Element Deconstructor")
    on_timer(pos, 0)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "dst" then
        if stack:get_name() == "exchangeclone:exchange_orb" then
            return stack:get_count()
        else
            return 0
        end
    elseif listname == "main" then
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
    exchangeclone.get_inventory_drops(pos, "main", drops)
    exchangeclone.get_inventory_drops(pos, "dst", drops)
    drops[#drops+1] = "exchangeclone:element_deconstructor"
    minetest.remove_node(pos)
    return drops
end

minetest.register_node("exchangeclone:element_deconstructor", {
    description = "Element Deconstructor",
    tiles = {
        "exchangeclone_deconstructor_up.png",
        "exchangeclone_deconstructor_down.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png"
    },
    groups = {cracky = 2, container = 3, pickaxey = 2},
    _mcl_hardness = 3,
	_mcl_blast_resistance = 6,
    sounds = sound_mod.node_sound_metal_defaults(),
    is_ground_content = false,
    can_dig = can_dig,
    after_dig_node = function(pos, oldnode, oldmetadata, player)
        if exchangeclone.mineclone then
            local meta = minetest.get_meta(pos)
            local meta2 = meta:to_table()
            meta:from_table(oldmetadata)
            local inv = meta:get_inventory()
            for _, listname in ipairs({"main", "dst"}) do
                local stack = inv:get_stack(listname, 1)
                if not stack:is_empty() then
                    local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                    minetest.add_item(p, stack)
                end
            end
            meta:from_table(meta2)
        end
	end,
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

local recipe_ingredient = "default:furnace"

if exchangeclone.mineclone then
    recipe_ingredient = "mcl_furnaces:furnace"
end

minetest.register_craft({
    type = "shaped",
    output = "exchangeclone:element_deconstructor",
    recipe = {
        {"", "exchangeclone:exchange_orb",""},
        {"", recipe_ingredient, ""},
        {"", "exchangeclone:exchange_orb",  ""}
    }
})
