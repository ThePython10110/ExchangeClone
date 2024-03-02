-- There's a lot of duplicated code in this file, but removing it means adding more duplicated code... so I'm just going to leave it.

local function extract_dimension(pos)
    if exchangeclone.mtg then
        if minetest.get_modpath("nether") then
            if pos.y >= nether.DEPTH_FLOOR and pos.y <= nether.DEPTH_CEILING then
                local report_y = pos.y - nether.DEPTH_FLOOR
                minetest.log(report_y)
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
    "button[11.5,0.5;1,0.7;add;Add]",
    "button[8.5,1.5;4,1;teleport;Teleport]",
    "button[8.5,2.75;4,1;rename;Rename]",
    "button[8.5,4;4,1;up;Move Up]",
    "button[8.5,5.25;4,1;down;Move Down]",
    "button[8.5,6.5;4,1;delete;Delete]",
    "field_close_on_enter[name;false]",
    "field_enter_after_edit[name;false]"
}

local context = {}

-- player: The player to be shown the formspec
-- index: The index of the location the player is currently selecting
-- use_stack_data: Whether to use locations stored with the book or the player.
local function show_formspec(player, index, text, use_stack_data, confirmation)
    local stack = player:get_wielded_item()
    if minetest.get_item_group(stack:get_name(), "exchangeclone_alchemical_book") < 1 then
        return
    end
    context[player:get_player_name()] = context[player:get_player_name()] or {}
    context[player:get_player_name()].using_stack_data = use_stack_data
    local book_data = stack:get_definition().alchemical_book_data
    local data = minetest.deserialize((use_stack_data and stack or player):get_meta():get_string("exchangeclone_alchemical_book"))
    local formspec = table.copy(base_formspec)
    formspec[#formspec+1] = "field[8.5,0.5;3,0.7;name;;"..minetest.formspec_escape(text or "").."]"
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
            formspec[#formspec+1] = minetest.formspec_escape(location.name)..","
        end
        if index then
            formspec[#formspec+1] = ";"..index
        end
        formspec[#formspec+1] = "]"
    end
    if index then
        local selected = data.locations[index]
        if selected then
            local dimension, adjusted_pos = extract_dimension(selected.pos)
            local _, player_adjusted_pos = extract_dimension(player_pos)
            local dimension_string = dimension and (" ("..dimension..")") or ""
            local distance = vector.distance(adjusted_pos, player_adjusted_pos)
            local cost = math.floor(book_data.emc_per_node*distance*20)/20
            local info = minetest.formspec_escape(string.format(
                "%s\nPosition: %.1f, %.1f, %.1f%s\nDistance: %.1f\nCost: %s EMC",
                 selected.name,
                 adjusted_pos.x,
                 adjusted_pos.y,
                 adjusted_pos.z,
                 dimension_string,
                 distance,
                 exchangeclone.format_number(cost)
            ))
            formspec[#formspec+1] = "textarea[0.5,8;4,4;;;"..info.."]"
        end
    end
    if confirmation then
        formspec[#formspec+1] = "label[8.5,8;Delete?]button[10,8;1.25,1;cancel;Cancel]button[11.25,8;1.25,1;confirm;Delete]"
    end
    minetest.show_formspec(player:get_player_name(), "exchangeclone_alchemical_book", table.concat(formspec))
end

minetest.register_on_joinplayer(function(player)
    context[player:get_player_name()] = nil
end)

minetest.register_on_leaveplayer(function(player)
    context[player:get_player_name()] = nil
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "exchangeclone_alchemical_book" then return end
    if fields.quit then
        context[player:get_player_name()] = nil
        return
    end
    local use_stack_data = context[player:get_player_name()].using_stack_data
    local stack = player:get_wielded_item()
    if minetest.get_item_group(stack:get_name(), "exchangeclone_alchemical_book") < 1 then
        return
    end
    local meta = (use_stack_data and stack or player):get_meta()
    local data = minetest.deserialize(meta:get_string("exchangeclone_alchemical_book"))
    local index = context[player:get_player_name()].index
    if type(data) ~= "table" then
        data = {}
    end
    if not data.locations then
        data.locations = {}
    end
    if fields.key_enter_field == "name" or fields.add or fields.rename then
        local name = fields.name
        if name == "" then return end
        for _, location in pairs(data.locations) do
            if location.name == name then
                minetest.chat_send_player(player:get_player_name(), "There is already a location called '"..location.name.."'")
                return
            end
        end
        if fields.rename then
            data.locations[index].name = name
        else
            data.locations[#data.locations+1] = {name = name, pos = player:get_pos()}
        end
        meta:set_string("exchangeclone_alchemical_book", minetest.serialize(data))
        if use_stack_data then player:set_wielded_item(stack) end
        show_formspec(player, index, "", use_stack_data)
    elseif fields.teleport then
        if not data.locations[index] then return end
        local pos = data.locations[index].pos
        local _, adjusted_pos = extract_dimension(pos)
        local _, adjusted_player_pos = extract_dimension(player:get_pos())
        local distance = vector.distance(adjusted_player_pos, adjusted_pos)
        local emc_per_node = stack:get_definition().alchemical_book_data.emc_per_node
        local cost = distance*emc_per_node
        local player_emc = exchangeclone.get_player_emc(player)
        if player_emc < cost then
            minetest.chat_send_player(player:get_player_name(), "Not enough EMC to teleport.")
        else
            player:set_pos(pos)
            exchangeclone.add_player_emc(-cost)
        end
        show_formspec(player, index, fields.name, use_stack_data)
    elseif fields.location_list then
        local exploded = minetest.explode_textlist_event(fields.location_list)
        index = math.min(exploded.index, #data.locations)
        if not context[player:get_player_name()] then context[player:get_player_name()] = {} end
        context[player:get_player_name()].index = index
        if exploded.type == "DCL" then
            local pos = data.locations[index].pos
            local _, adjusted_pos = extract_dimension(pos)
            local _, adjusted_player_pos = extract_dimension(player:get_pos())
            local distance = vector.distance(adjusted_player_pos, adjusted_pos)
            local emc_per_node = stack:get_definition().alchemical_book_data.emc_per_node
            local cost = distance*emc_per_node
            local player_emc = exchangeclone.get_player_emc(player)
            if player_emc < cost then
                minetest.chat_send_player(player:get_player_name(), "Not enough EMC to teleport.")
            else
                player:set_pos(pos)
                exchangeclone.add_player_emc(-cost)
            end
        end
        show_formspec(player, index, fields.name, use_stack_data)
    elseif fields.up then
        if not data.locations[index] then return end
        if index > 1 then
            data.locations[index], data.locations[index-1] = data.locations[index-1], data.locations[index]
            meta:set_string("exchangeclone_alchemical_book", minetest.serialize(data))
            if use_stack_data then player:set_wielded_item(stack) end
            index = index - 1
            if not context[player:get_player_name()] then context[player:get_player_name()] = {} end
            context[player:get_player_name()].index = index
            show_formspec(player, index, fields.name, use_stack_data)
        end
    elseif fields.down then
        if not data.locations[index] then return end
        if index < #data.locations then
            data.locations[index], data.locations[index+1] = data.locations[index+1], data.locations[index]
            meta:set_string("exchangeclone_alchemical_book", minetest.serialize(data))
            if use_stack_data then player:set_wielded_item(stack) end
            index = index + 1
            if not context[player:get_player_name()] then context[player:get_player_name()] = {} end
            context[player:get_player_name()].index = index
            show_formspec(player, index, fields.name, use_stack_data)
        end
    elseif fields.delete then
        if not data.locations[index] then return end
        show_formspec(player, index, fields.name, use_stack_data, true)
    elseif fields.cancel then
        if not data.locations[index] then return end
        show_formspec(player, index, fields.name, use_stack_data)
    elseif fields.confirm then
        if not data.locations[index] then return end
        for i = index,#data.locations - 1 do
            data.locations[i] = data.locations[i+1]
        end
        data.locations[#data.locations] = nil
        index = math.min(index, #data.locations)
        if not context[player:get_player_name()] then context[player:get_player_name()] = {} end
        context[player:get_player_name()].index = index
        meta:set_string("exchangeclone_alchemical_book", minetest.serialize(data))
        if use_stack_data then player:set_wielded_item(stack) end
        show_formspec(player, index, fields.name, use_stack_data)
    end
end)

local function alchemical_book_function(itemstack, player, pointed_thing)
    local use_stack_data = itemstack:get_meta():get_int("exchangeclone_use_stack_data")
    if use_stack_data == 0 then
        use_stack_data = nil
    end
    if player:get_player_control().sneak then
        if use_stack_data then
            minetest.chat_send_player(player:get_player_name(), "Using player data")
            itemstack:get_meta():set_int("exchangeclone_use_stack_data", 0)
        else
            minetest.chat_send_player(player:get_player_name(), "Using book data")
            itemstack:get_meta():set_int("exchangeclone_use_stack_data", 1)
        end
        return itemstack
    else
        show_formspec(player, nil, "", use_stack_data)
    end
end

minetest.register_tool("exchangeclone:basic_alchemical_book", {
    description = "Basic Alchemical Book",
    groups = {exchangeclone_alchemical_book = 1},
    alchemical_book_data = {emc_per_node = 1000},
    on_secondary_use = alchemical_book_function,
    on_place = alchemical_book_function
})