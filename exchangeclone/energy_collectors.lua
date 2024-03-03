local S = minetest.get_translator()

local formspec =
    "size["..(exchangeclone.mcl and 9 or 8)..",9]"..
    "label[3,2;"..S("Star").."]"..
    "list[context;main;4,2;1,1;]"..
    exchangeclone.inventory_formspec(0,5)..
    "listring[current_player;main]"..
    "listring[context;main]"..
    (exchangeclone.mcl and mcl_formspec.get_itemslot_bg(4,2,1,1) or "")

minetest.register_alias("exchangeclone:energy_collector", "exchangeclone:basic_collector")

local function check_for_furnaces(pos, set_furnace, start)
	local found = false
	for _, check_pos in pairs(exchangeclone.neighbors) do
		local new_pos = vector.add(pos, check_pos)
		local node = minetest.get_node(new_pos)
        local furnace = minetest.get_item_group(node.name, "exchangeclone_furnace")
		if furnace > 0 then
            found = true
            if start then
                local timer = minetest.get_node_timer(new_pos)
                if not timer:is_started() then
                    if furnace == 1 then -- Dark Matter
                        timer:start(0.45)
                    elseif furnace == 2 then -- Red Matter
                        timer:start(0.16)
                    end
                end
            end
			if set_furnace ~= nil then
                local meta = minetest.get_meta(new_pos)
                meta:set_int("using_collector", set_furnace)
			end
		end
	end
	return found
end

local function on_timer(pos, elapsed)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    -- get node above
    local above = vector.add({x=0,y=1,z=0}, pos)

    local using_star = true
    if inv:is_empty("main") then
        using_star = false
    end

    local light = minetest.get_natural_light(above)

    if light and light >= 14 then
        if check_for_furnaces(pos, 1, true) then
            -- do nothing, emc is being used for the furnace.
            return true
        end
        local amount = meta:get_int("collector_amount")
        if using_star then
            local max = exchangeclone.get_star_max(inv:get_stack("main", 1))
            local stored = exchangeclone.get_star_emc(inv, "main", 1)
            if stored + amount <= max then
                stored = stored + amount
            else
                stored = math.max(stored, max)
            end
            exchangeclone.set_star_emc(inv, "main", 1, stored)
        else
            local placer = meta:get_string("exchangeclone_placer")
            if placer and placer ~= "" then
                local player = minetest.get_player_by_name(placer)
                if player then
                    exchangeclone.add_player_emc(player, amount)
                end
            end
        end
    else
        check_for_furnaces(pos, 0)
    end
    return true
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 1)
    meta:set_string("formspec", formspec)
    minetest.get_node_timer(pos):start(1)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    if listname == "main" then
        if minetest.get_item_group(stack:get_name(), "klein_star") > 0 then
            return stack:get_count()
        else
            return 0
        end
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

function exchangeclone.register_energy_collector(itemstring, name, amount, texture, recipe, glow)
    minetest.register_node(itemstring, {
        description = name.."\nGenerates "..exchangeclone.format_number(amount).." EMC/second",
        tiles = {texture},
        groups = {
            cracky = 2,
            pickaxey = 1,
            handy = 1,
            oddly_breakable_by_hand = 2,
            material_glass = 1,
            energy_collector = 1,
            container = 2,
            tubedevice = 1,
            tubedevice_receiver = 1,
        },
        light_source = glow,
        _mcl_hardness = 1,
        _mcl_blast_resistance = 1,
        sounds = exchangeclone.sound_mod.node_sound_glass_defaults(),
        is_ground_content = false,
        can_dig = exchangeclone.can_dig,
        on_timer = on_timer,
        on_construct = on_construct,
        after_dig_node = exchangeclone.drop_after_dig({"main"}),
        on_metadata_inventory_move = function(pos)
            minetest.get_node_timer(pos):start(1)
        end,
        on_metadata_inventory_put = function(pos)
            minetest.get_node_timer(pos):start(1)
        end,
        on_metadata_inventory_take = function(pos)
            minetest.get_node_timer(pos):start(1)
        end,
        on_destruct = function(pos, large)
            check_for_furnaces(pos, 0)
        end,
        after_place_node = function(pos, player, itemstack, pointed_thing)
            local player_name = player:get_player_name()
            local meta = minetest.get_meta(pos)
            meta:set_int("collector_amount", amount)
            meta:set_string("exchangeclone_placer", player_name)
            meta:set_string("infotext", name.."\n"..S("Owned by ")..player_name)
            if exchangeclone.pipeworks then
                pipeworks.after_place(pos, player, itemstack, pointed_thing)
            end
        end,
        on_blast = exchangeclone.on_blast({"main"}),
        allow_metadata_inventory_put = allow_metadata_inventory_put,
        allow_metadata_inventory_move = allow_metadata_inventory_move,
        allow_metadata_inventory_take = allow_metadata_inventory_take,
    })
    minetest.log(dump(recipe))
    minetest.register_craft({
        output = itemstring,
        type = recipe[2] or "shaped",
        recipe = recipe[1]
    })

    if exchangeclone.pipeworks then
        minetest.override_item(itemstring, {
            tube = {
                input_inventory = "main",
                connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1},
                insert_object = function(pos, node, stack, direction)
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()
                    return inv:add_item("main", stack)
                end,
                can_insert = function(pos, node, stack, direction)
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()
                    if minetest.get_item_group(stack:get_name(), "klein_star") > 0 then
                        return inv:room_for_item("main", stack)
                    end
                end,
            },
            on_rotate = pipeworks.on_rotate,
        })
    end
end

local collectors = {
    "Basic",
    "Dark",
    "Red",
    "Magenta",
    "Pink",
    "Purple",
    "Violet",
    "Blue",
    "Cyan",
    "Green",
    "Lime",
    "Yellow",
    "Orange",
    "White",
}

local ingredient = exchangeclone.mcl and "mcl_nether:glowstone" or "default:gold_ingot"

exchangeclone.register_energy_collector(
    "exchangeclone:basic_collector",
    S("Basic Collector [MK 1]"),
    4,
    "exchangeclone_basic_collector.png",
    {{
        {ingredient, exchangeclone.itemstrings.glass, ingredient},
        {ingredient, "exchangeclone:aeternalis_fuel_block", ingredient},
        {ingredient, (exchangeclone.mcl and "mcl_furnaces:furnace" or "default:furnace"), ingredient},

    }},
    5
)

minetest.register_alias("exchangeclone:energy_collector_mk1", "exchangeclone:basic_collector")

for i = 2, #collectors do
    local collector = collectors[i]
    local codified = collector:lower().."_collector"
    local previous = "exchangeclone:"..collectors[i-1]:lower().."_collector"
    exchangeclone.register_energy_collector(
        "exchangeclone:"..codified,
        S(collector.." Energy Collector [MK"..i.."]"),
        4*math.pow(6,i-1),
        "exchangeclone_"..codified..".png",
        {
            {
                previous,
                "exchangeclone:"..collector:lower().."_matter"
            },
            "shapeless"
        },
        5+i
    )
    minetest.register_alias("exchangeclone:energy_collector_mk"..i, "exchangeclone:"..codified)
end