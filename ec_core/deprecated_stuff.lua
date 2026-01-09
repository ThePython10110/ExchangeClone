local S = core.get_translator()

local c_formspec =
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
    c_formspec = c_formspec..
        mcl_formspec.get_itemslot_bg(2,2,1,1)..
        mcl_formspec.get_itemslot_bg(3,2,1,1)..
        mcl_formspec.get_itemslot_bg(5,2,1,1)
end

core.register_alias("exchangeclone:element_constructor", "exchangeclone:constructor")

local function c_on_construct(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    meta:set_string("formspec", c_formspec)
    meta:set_string("infotext", "Cheater")
end

local function nope() return 0 end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    if core.is_protected(pos, player:get_player_name()) then
        return 0
    end
    return stack:get_count()
end

core.register_node(":exchangeclone:constructor", {
    description = "Constructor (DEPRECATED)\nUse the new EMC Link instead. This will be removed in a future version.",
    tiles = {
        "exchangeclone_constructor_up.png",
        "exchangeclone_constructor_down.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
        "exchangeclone_constructor_right.png",
    },
    groups = {cracky = 2, pickaxey = 2, not_in_creative_inventory = 1, not_in_craft_guide = 1},
    _mcl_hardness = 3,
	_mcl_blast_resistance = 6,
    sounds = exchangeclone.sound_mod.node_sound_metal_defaults(),
    is_ground_content = false,
    can_dig = exchangeclone.can_dig,
    after_dig_node = exchangeclone.drop_after_dig({"src", "fuel", "dst"}),
    on_construct = c_on_construct,
    on_blast = exchangeclone.on_blast({"src", "fuel", "dst"}),
    allow_metadata_inventory_put = nope,
    allow_metadata_inventory_move = nope,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
    exchangeclone_custom_emc = 811012,
})

local d_formspec =
    "size["..(exchangeclone.mcl and 9 or 8)..",9]"..
    "label[2,1;"..S("Input").."]"..
    "list[context;src;2,2;1,1;]"..
    "label[5,1;"..S("Star").."]"..
    "list[context;fuel;5,2;1,1;]"..
    exchangeclone.inventory_formspec(0,5)..
    "listring[current_player;main]"..
    "listring[context;src]"..
    "listring[current_player;main]"..
    "listring[context;fuel]"..
    "listring[current_player;main]"..
    "listring[context;dst]"
if exchangeclone.mcl then
    d_formspec = d_formspec..
        mcl_formspec.get_itemslot_bg(2,2,1,1)..
        mcl_formspec.get_itemslot_bg(5,2,1,1)
end

core.register_alias("exchangeclone:element_deconstructor", "exchangeclone:deconstructor")

local function d_on_construct(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("src", 1)
    inv:set_size("fuel", 1)
    meta:set_string("formspec", d_formspec)
    meta:set_string("infotext", "I thought I made this unplaceable")
end

core.register_node(":exchangeclone:deconstructor", {
    description = S("Deconstructor (DEPRECATED)\nUse the new EMC Link instead. This will be removed in a future version."),
    tiles = {
        "exchangeclone_deconstructor_up.png",
        "exchangeclone_deconstructor_down.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png",
        "exchangeclone_deconstructor_right.png",
    },
    groups = {cracky = 2, pickaxey = 2, not_in_creative_inventory = 1, not_in_craft_guide = 1},
    _mcl_hardness = 3,
	_mcl_blast_resistance = 6,
    sounds = exchangeclone.sound_mod.node_sound_metal_defaults(),
    is_ground_content = false,
    can_dig = exchangeclone.can_dig,
    after_dig_node = exchangeclone.drop_after_dig({"src", "fuel"}),
    on_construct = d_on_construct,
    on_blast = exchangeclone.on_blast({"src", "fuel"}),
    on_secondary_use = function() return end,
    on_place = function() return end,
    allow_metadata_inventory_put = nope,
    allow_metadata_inventory_move = nope,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
    exchangeclone_custom_emc = 786440,
})

if exchangeclone.mtg and core.get_modpath("ec_armor") then
    core.register_tool(":exchangeclone:shield_dark_matter", {
        description =
        "Dark Matter Shield (deprecated)\nYou only still have this so you can turn it into EMC.\nAnd no, it's not supposed to have a texture.",
        groups = { disable_repair = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1 },
    })
    -- Not a real recipe, only for EMC
    exchangeclone.register_craft({
        output = "exchangeclone:shield_dark_matter",
        type = "shapeless",
        recipe = {
            "ec_matter:dark_matter",
            "ec_matter:dark_matter",
            "ec_matter:dark_matter",
            "ec_matter:dark_matter",
            "ec_matter:dark_matter",
            "ec_matter:dark_matter",
            "ec_matter:dark_matter",
        }
    })

    core.register_tool(":exchangeclone:shield_red_matter", {
        description =
        "Red Matter Shield (deprecated)\nYou only still have this so you can turn it into EMC.\nAnd no, it's not supposed to have a texture.",
        groups = { disable_repair = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1 }
    })
    -- Not a real recipe, only for EMC
    exchangeclone.register_craft({
        output = "exchangeclone:shield_red_matter",
        type = "shapeless",
        recipe = {
            "exchangeclone:shield_dark_matter",
            "ec_matter:red_matter",
            "ec_matter:red_matter",
            "ec_matter:red_matter",
            "ec_matter:red_matter",
            "ec_matter:red_matter",
            "ec_matter:red_matter",
        }
    })
end