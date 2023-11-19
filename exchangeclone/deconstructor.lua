local S = minetest.get_translator()

local formspec =
    "size["..(exchangeclone.mcl and 9 or 8)..",9]"..
    "label[2,1;"..S("Input").."]"..
    "list[context;src;2,2;1,1;]"..
    "label[5,1;"..S("Orb").."]"..
    "list[context;fuel;5,2;1,1;]"..
    exchangeclone.inventory_formspec(0,5)..
    "listring[current_player;main]"..
    "listring[context;src]"..
    "listring[current_player;main]"..
    "listring[context;fuel]"..
    "listring[current_player;main]"..
    "listring[context;dst]"
if exchangeclone.mcl then
    formspec = formspec..
        mcl_formspec.get_itemslot_bg(2,2,1,1)..
        mcl_formspec.get_itemslot_bg(5,2,1,1)
end

minetest.register_alias("exchangeclone:element_deconstructor", "exchangeclone:deconstructor")

-- Register LBM to update deconstructors
minetest.register_lbm({
    name = "exchangeclone:deconstructor_alert",
    nodenames = {"exchangeclone:deconstructor"},
    run_at_every_load = false,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", "size[3,1]label[0,0;"..S("Break and replace.").."\n"..S("Nothing will be lost.").."]")
    end,
})

local function can_dig(pos, player)
    if exchangeclone.mcl then return true end
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    return inv:is_empty("src") and inv:is_empty("fuel") and inv:is_empty("main")
end

local function deconstructor_action(pos, elapsed)
    local limit = exchangeclone.orb_max
    local using_orb = true
    local player
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    if inv:get_stack("fuel", 1):get_name() ~= "exchangeclone:exchange_orb" then
        limit = exchangeclone.limit
        using_orb = false
        player = minetest.get_player_by_name(meta:get_string("exchangeclone_placer"))
        if not (player and player ~= "") then return end
    end

    local stack = inv:get_stack("src", 1)
    local individual_energy_value = exchangeclone.get_item_energy(stack:get_name())
    if not (individual_energy_value and individual_energy_value > 0) then return end
    local wear = stack:get_wear()
    if wear and wear > 1 then
        individual_energy_value = math.floor(individual_energy_value * (65536 / wear))
    end
    if stack:get_name() == "exchangeclone:exchange_orb" then
        individual_energy_value = individual_energy_value + exchangeclone.get_orb_itemstack_energy(stack)
    end

    local current_energy
    if using_orb then
        current_energy = exchangeclone.get_orb_energy(inv, "fuel", 1)
    else
        current_energy = exchangeclone.get_player_energy(player)
    end
    local max_count = math.floor((limit - current_energy)/individual_energy_value)
    local add_count = math.min(max_count, stack:get_count())
    local energy_value = individual_energy_value * add_count
    local result = current_energy + energy_value
    if result < 0 or result > limit then return end

    if using_orb then
        exchangeclone.set_orb_energy(inv, "fuel", 1, result)
    else
        exchangeclone.set_player_energy(player, result)
    end
    stack:set_count(stack:get_count() - add_count)
    if stack:get_count() == 0 then stack = ItemStack("") end
    inv:set_stack("src", 1, stack)

    local timer = minetest.get_node_timer(pos)
    if inv:get_stack("src", 1):is_empty() then
        timer:stop()
    else
        if not timer:is_started() then
            timer:start(1) -- keep trying to deconstruct if there are items in the src stack
        end
    end
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("src", 1)
    inv:set_size("fuel", 1)
    meta:set_string("formspec", formspec)
    meta:set_string("infotext", S("Deconstructor"))
    deconstructor_action(pos, 0)
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
    else
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
    exchangeclone.get_inventory_drops(pos, "src", drops)
    exchangeclone.get_inventory_drops(pos, "fuel", drops)
    drops[#drops+1] = "exchangeclone:deconstructor"
    minetest.remove_node(pos)
    return drops
end

minetest.register_node("exchangeclone:deconstructor", {
    description = S("Deconstructor"),
    tiles = {
        "exchangeclone_deconstructor_up.png",
        "exchangeclone_deconstructor_down.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png"
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
            for _, listname in ipairs({"src", "fuel"}) do
                local stack = inv:get_stack(listname, 1)
                if not stack:is_empty() then
                    local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
                    minetest.add_item(p, stack)
                end
            end
            meta:from_table(meta2)
        end
	end,
    after_place_node = function(pos, player, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        meta:set_string("exchangeclone_placer", player:get_player_name())
    end,
    on_timer = deconstructor_action,
    on_construct = on_construct,
    on_metadata_inventory_move = deconstructor_action,
    on_metadata_inventory_put = deconstructor_action,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        if listname == "fuel" then return end
        deconstructor_action(pos)
    end,
    on_blast = on_blast,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})

local recipe_ingredient = "default:furnace"

if exchangeclone.mcl then
    recipe_ingredient = "mcl_furnaces:furnace"
end

minetest.register_craft({
    output = "exchangeclone:deconstructor",
    recipe = {
        {"exchangeclone:exchange_orb"},
        {recipe_ingredient},
        {"exchangeclone:exchange_orb"}
    }
})