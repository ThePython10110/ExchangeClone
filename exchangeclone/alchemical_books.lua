local function extract_dimension(pos)
    if exchangeclone.mtg then
        if minetest.get_modpath("nether") then
            if pos.y >= nether.DEPTH_FLOOR and pos.y <= nether.DEPTH_CEILING then
                local report_y = pos.y - nether.DEPTH_FLOOR
                return "Nether", {x = pos.x, y = report_y, z = pos.z}
            else
                return "Overworld", pos
            end
        end
        return nil, pos
    end

    -- overworld
    if (pos.y >= mcl_vars.mg_overworld_min) and (pos.y <= mcl_vars.mg_overworld_max) then
        return "Overworld", pos
    end

    -- nether
    if (pos.y >= mcl_vars.mg_nether_min) and (pos.y <= mcl_vars.mg_nether_max) then
        local report_y = pos.y - mcl_vars.mg_nether_min
        return "Nether", {x = pos.x, y = report_y, z = pos.z}
    end

    -- end
    if (pos.y >= mcl_vars.mg_end_min) and (pos.y <= mcl_vars.mg_end_max) then
        local report_y = pos.y - mcl_vars.mg_end_min
        return "End", {x = pos.x, y = report_y, z = pos.z}
    end

    -- outside of scoped bounds.
    return "Void", pos
end

local function add_dimension(dimension, pos)
    dimension = dimension:lower()
    if exchangeclone.mtg then
        if dimension == "nether" then
            if minetest.get_modpath("nether") then
                local report_y = pos.y + nether.DEPTH_FLOOR
                return {x = pos.x, y = report_y, z = pos.z}
            end
        end
        return pos
    end

    if dimension == "nether" then
        local report_y = pos.y + mcl_vars.mg_nether_min
        return {x = pos.x, y = report_y, z = pos.z}
    end

    if dimension == "end" then
        local report_y = pos.y + mcl_vars.mg_end_min
        return {x = pos.x, y = report_y, z = pos.z}
    end

    return pos
end

local base_formspec = {
    "formspec_version[3]",
    "size[13,10]",
    "textarea[8.5,0.5;3,0.7;name;;Location Name]",
    "button[11.5,0.5;1,0.7;add;Add]",
    "button[8.5,1.5;4,1;teleport;Teleport]",
    "button[8.5,2.75;4,1;rename;Rename]",
    "button[8.5,4;4,1;up;Move Up]",
    "button[8.5,5.25;4,1;down;Move Down]",
    "button[8.5,6.5;4,1;delete;Delete]",
    "field_close_on_enter[name;false]",
    "field_enter_after_edit[name;false]"
}

local using_stack_data = {}

-- player: The player to be shown the formspec
-- index: The index of the location the player is currently selecting
-- use_stack_data: Whether to use locations stored with the book or the player.
local function show_formspec(player, index, use_stack_data)
    local stack = player:get_wielded_item()
    if minetest.get_item_group(stack:get_name(), "exchangeclone_alchemical_book") < 1 then
        return
    end
    using_stack_data[player:get_player_name()] = use_stack_data
    local book_data = stack:get_definition().alchemical_book_data
    local data = minetest.deserialize((use_stack_data and stack or player):get_meta():get_string("exchangeclone_alchemical_book"))
    local formspec = table.copy(base_formspec)
    local player_pos = player:get_pos()
    if type(data) ~= "table" then
        data = {}
    end
    if not data.locations then
        data.locations = {}
    end
    if #data.locations > 0 then
        formspec[#formspec+1] = "textlist[0.5,0.5;7,7;location_list;"
        for _, location in ipairs(data.locations) do
            formspec[#formspec+1] = minetest.formspec_escape(location.name)..";"
        end
        formspec[#formspec+1] = "]"
    end
    if index then
        local selected = data.locations[index]
        if selected then
            local dimension, pos = extract_dimension(selected.pos)
            local dimension_string = dimension and (" ("..dimension..")") or ""
            local distance = vector.distance(pos, player_pos)
            local cost = book_data.emc_per_node*distance
            local info = minetest.formspec_escape(string.format([[%s
Position: %s, %s, %s%s
Distance: %s
Cost: %s EMC]], selected.name, pos.x, pos.y, pos.z, dimension_string, distance, cost))
            formspec[#formspec+1] = "textarea[0.5,8;4,4;;;"..info.."]"
        end
    end
    minetest.show_formspec(player:get_player_name(), "exchangeclone_alchemical_book", table.concat(formspec))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "exchangeclone_alchemical_book" then return end
    if fields.quit == "true" then return end
    local use_stack_data = using_stack_data[player:get_player_name()]
    local stack = player:get_wielded_item()
    local data = minetest.deserialize((use_stack_data and stack or player):get_meta():get_string("exchangeclone_alchemical_book"))
    if type(data) ~= "table" then
        data = {}
    end
    if not data.locations then
        data.locations = {}
    end
    minetest.log(dump(fields))
end)

minetest.register_tool("exchangeclone:basic_alchemical_book", {
    description = "Basic Alchemical Book",
    groups = {exchangeclone_alchemical_book = 1},
    alchemical_book_data = {emc_per_node = 1000},
    on_secondary_use = function(itemstack, player, pointed_thing)
        show_formspec(player)
    end
})