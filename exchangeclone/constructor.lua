local S = minetest.get_translator()

local formspec =
    "size["..(exchangeclone.mcl and 9 or 8)..",9]"..
    "label[2,1;"..S("Star").."]"..
    "list[context;fuel;2,2;1,1;]"..
    "label[3,1;"..S("Source").."]"..
    "list[context;src;3,2;1,1;]"..
    "label[5,1;"..S("Output").."]"..
    "list[context;dst;5,2;1,1;]"..
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
        mcl_formspec.get_itemslot_bg(3,2,1,1)..
        mcl_formspec.get_itemslot_bg(5,2,1,1)
end

minetest.register_alias("exchangeclone:element_constructor", "exchangeclone:constructor")

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    meta:set_string("formspec", formspec)
    meta:set_string("infotext", S("Constructor"))
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    return 0
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    return stack:get_count()
end

minetest.register_node("exchangeclone:constructor", {
    description = "Constructor (DEPRECATED)\nUse the EMC Link instead. This will be removed in a future version.",
    tiles = {
        "exchangeclone_constructor_up.png",
        "exchangeclone_constructor_down.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
    },
    groups = {cracky = 2, container = exchangeclone.mcl2 and 2 or 4, pickaxey = 2, not_in_creative_inventory = 1, not_in_craft_guide = 1},
    _mcl_hardness = 3,
	_mcl_blast_resistance = 6,
    sounds = exchangeclone.sound_mod.node_sound_metal_defaults(),
    is_ground_content = false,
    can_dig = exchangeclone.can_dig,
    after_dig_node = exchangeclone.drop_after_dig({"src", "fuel", "dst"}),
    on_construct = on_construct,
    on_blast = exchangeclone.on_blast({"src", "fuel", "dst"}),
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
        {"exchangeclone:klein_star_drei"},
        {recipe_ingredient},
        {"exchangeclone:klein_star_drei"}
    }
})