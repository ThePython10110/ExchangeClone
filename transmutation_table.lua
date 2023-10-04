local function get_transmutation_buttons(player, page, x, y)
    local pages = minetest.deserialize(player:get_meta():get_string("exchangeclone_transmutation")) or {}
    if page > #pages then page = #pages end
    if page < 1 then page = 1 end
    if not pages[page] and page == 1 then
        pages[page] = {}
    end
    local buttons = ""
    for i = 0, 15 do
        local itemstring = pages[page][i+1]
        local column = (i%4)
        local row = math.floor(i/4)
        if itemstring then
            buttons = buttons.."item_image_button["..tostring(x+column)..","..tostring(y+row)..";1,1;"..itemstring..";"..itemstring..";]"
        else
            buttons = buttons.."image_button["..tostring(x+column)..","..tostring(y+row)..";1,1;blank.png;empty_button"..tostring(i)..";]"
        end
    end
    buttons = buttons.."label[5.75,5.25;"..tostring(page).."/"..tostring(#pages).."]"
    player:get_meta():set_int("exchangeclone_transmutation_page", page)
    return buttons
end

--<copied from MineClone>
local function filter_item(name, description, lang, filter)
	local desc
	if not lang then
		desc = string.lower(description)
	else
		desc = string.lower(minetest.get_translated_string(lang, description))
	end
	return string.find(name, filter, nil, true) or string.find(desc, filter, nil, true)
end

function exchangeclone.reload_transmutation_list(player, search)
    local meta = player:get_meta()
    local player_energy = exchangeclone.get_player_energy(player)
    local items_to_show = minetest.deserialize(meta:get_string("exchangeclone_transmutation_learned_items")) or {}
	local lang = minetest.get_player_information(player:get_player_name()).lang_code
    local pages = {}
    local page_num
    local i = 0
    if not search or search == "" then search = player:get_meta():get_string("exchangeclone_transmutation_search") or "" end
    if search and search ~= "" then
        local filtered_items = {}
        for _,name in ipairs(items_to_show) do
            local def = minetest.registered_items[name]
            if def and (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0) and def.description and def.description ~= "" then
                if filter_item(string.lower(def.name), def.description, lang, search) then
                    table.insert(filtered_items, name)
                end
            end
            items_to_show = table.copy(filtered_items)
        end
    end
    for _, item in ipairs(items_to_show) do
        local energy_value = exchangeclone.get_item_energy(item)
        if energy_value <= player_energy and energy_value > 0 then
            page_num = math.floor(i/16) + 1
            if not pages[page_num] then pages[page_num] = {} end
            pages[page_num][(i % 16) + 1] = item
            i = i + 1
        end
    end
    player:get_meta():set_string("exchangeclone_transmutation", minetest.serialize(pages))
    return pages
end

local function add_to_output(player, amount, show)
    local item = player:get_meta():get_string("exchangeclone_transmutation_selection")
    if minetest.registered_items[item] then
        local energy_value = exchangeclone.get_item_energy(item)
        local player_energy = exchangeclone.get_player_energy(player)
        local stack_max = ItemStack(item):get_stack_max()
        if amount == true then amount = stack_max end
        local max_amount = math.min(amount, stack_max, math.floor(player_energy/energy_value))
        local inventory = minetest.get_inventory({type = "detached", name = "exchangeclone_transmutation_"..player:get_player_name()})
        local added_amount = max_amount - inventory:add_item("output", ItemStack(item.." "..max_amount)):get_count()
        exchangeclone.set_player_energy(player, player_energy - (energy_value * added_amount))
        if show then exchangeclone.show_transmutation_table_formspec(player) end
    end
end

local function handle_inventory(player, inventory, to_list, to_index, stack)
    if to_list == "learn" then
        local list = minetest.deserialize(player:get_meta():get_string("exchangeclone_transmutation_learned_items")) or {}
        if stack:get_name() == "exchangeclone:alchemical_tome" then
            list = {}
            local i = 0
            for name, def in pairs(minetest.registered_items) do
                if exchangeclone.get_item_energy(name) > 0 and not def.groups.not_in_creative_inventory then
                    i = i + 1
                    list[i] = name
                end
            end
            table.sort(list)
            player:get_meta():set_string("exchangeclone_transmutation_learned_items", minetest.serialize(list))
        else
            local individual_energy_value = exchangeclone.get_item_energy(stack:get_name())
            if individual_energy_value <= 0 then return end
            local energy_value = individual_energy_value * stack:get_count()
            if stack:get_name() == "exchangeclone:exchange_orb" then
                energy_value = energy_value + exchangeclone.get_orb_itemstack_energy(stack)
            end
            local player_energy = exchangeclone.get_player_energy(player)
            local result = player_energy + energy_value
            if result < 0 or result > 2147483647 then return end
            exchangeclone.set_player_energy(player, exchangeclone.get_player_energy(player) + energy_value)
            local item_index = table.indexof(list, stack:get_name())
            if item_index == -1 then
                list[#list+1] = stack:get_name()
                table.sort(list)
                player:get_meta():set_string("exchangeclone_transmutation_learned_items", minetest.serialize(list))
            end
        end
        inventory:set_stack(to_list, to_index, nil)
        exchangeclone.show_transmutation_table_formspec(player)
    elseif to_list == "forget" then
        return
    elseif to_list == "charge" then
        local player_energy = exchangeclone.get_player_energy(player)
        local orb_energy = exchangeclone.get_orb_itemstack_energy(stack)
        local charge_amount = math.min(exchangeclone.energy_max - orb_energy, player_energy)
        if charge_amount > 0 then
            exchangeclone.set_player_energy(player, player_energy - charge_amount)
            exchangeclone.set_orb_energy(inventory, to_list, to_index, orb_energy + charge_amount)
            exchangeclone.show_transmutation_table_formspec(player)
        end
    end
end

local function check_for_table(player, inv)
    if minetest.is_creative_enabled(player:get_player_name()) then return true end
    if inv and inv:get_location().name ~= "exchangeclone_transmutation_"..player:get_player_name() then return false end
    local def = player:get_wielded_item():get_definition()
    local range = def and def.range
    if not range then range = player:get_inventory():get_stack("hand", 1):get_definition().range end
    if range then range = range + 1 else range = 5 end
    if player:get_wielded_item():get_name() ~= "exchangeclone:transmutation_tablet"
    and not minetest.find_node_near(player:get_pos(), range, "exchangeclone:transmutation_table", true) then return false end
    return true
end

local function allow_inventory_action(player, stack, to_list, count, move, inventory)
    if not check_for_table(player, inventory) then return 0 end
    if to_list == "output" then
        return 0
    elseif to_list == "charge" and stack:get_name() ~= "exchangeclone:exchange_orb" then
        return 0
    elseif to_list == "learn" then
        if stack:get_name() == "exchangeclone:alchemical_tome" then return count end
        local name = stack:get_name()
        local energy_value = exchangeclone.get_item_energy(stack:get_name())
        local def = minetest.registered_items[name]
        if energy_value <= 0 or def.groups.not_in_creative_inventory == 1 then
            return 0
        else
            return count
        end
    elseif to_list == "forget" then
        -- Kind of a weird way of doing this, but I couldn't make it work in the "on_inventory_* functions"
        local list = minetest.deserialize(player:get_meta():get_string("exchangeclone_transmutation_learned_items")) or {}
        local item_index = table.indexof(list, stack:get_name())
        if item_index > -1 then
            list[item_index] = list[#list]
            list[#list] = nil
            table.sort(list)
            player:get_meta():set_string("exchangeclone_transmutation_learned_items", minetest.serialize(list))
            local selection = player:get_meta():get_string("exchangeclone_transmutation_selection")
            if selection == stack:get_name() then
                player:get_meta():set_string("exchangeclone_transmutation_selection", "")
            end
        end
        exchangeclone.show_transmutation_table_formspec(player)
        return 0
    else
        return count
    end
end

function exchangeclone.show_transmutation_table_formspec(player, data)
    exchangeclone.reload_transmutation_list(player, data and data.search)
    if not data then data = {} end
    local player_energy = exchangeclone.get_player_energy(player)
    local selection = data.selection or player:get_meta():get_string("exchangeclone_transmutation_selection")
    local player_name = player:get_player_name()
    local inventory_name = "detached:exchangeclone_transmutation_"..player_name
    local label = "Transmutation\n"..tostring(player_energy).." energy"

    local formspec =
    "size[9,11]"..
    "label[0,0;"..label.."]"..
    "list["..inventory_name..";charge;0,1;1,1]"..
    "label[0,2;Charge]"..
    "list["..inventory_name..";forget;1,1;1,1]"..
    "label[1,2;Forget]"..
    "list["..inventory_name..";learn;2,1;1,1]"..
    "label[2,2;Learn]"..
    "list["..inventory_name..";output;2,3.5;2,2]"..
    "label[2.5,3;Output]"..
    get_transmutation_buttons(player, (data.page or player:get_meta():get_int("exchangeclone_transmutation_page")), 4, 1)..
    "button[4,5;1,1;left_arrow;<]"..
    "button[7,5;1,1;right_arrow;>]"..
    "button[0,3.5;1,1;plus1;+1]"..
    "button[1,3.5;1,1;plus5;+5]"..
    "button[0,4.5;1,1;plus10;+10]"..
    "button[1,4.5;1,1;plusstack;+Stack]"..
    "field[4.25,0.25;4,1;search_box;;"..(data.search or player:get_meta():get_string("exchangeclone_transmutation_search") or "").."]"..
    "field_close_on_enter[search_box;false]"..
    "button[8,0;1,1;search_button;Search]"..
    exchangeclone.inventory_formspec(0,6.25)..
    "listring["..inventory_name..";output]"..
    "listring[current_player;main]"..
    "listring["..inventory_name..";learn]"..
    "listring[current_player;main]"

    if minetest.registered_items[selection] then
        formspec = formspec.."item_image[0.5,2.5;0.8,0.8;"..selection.."]"
    end

    if exchangeclone.mcl then
        formspec = formspec..
            mcl_formspec.get_itemslot_bg(0,1,1,1)..
            mcl_formspec.get_itemslot_bg(1,1,1,1)..
            mcl_formspec.get_itemslot_bg(2,1,1,1)..
            mcl_formspec.get_itemslot_bg(2,3.5,2,2)
    end

    minetest.show_formspec(player_name, "exchangeclone_transmutation_table", formspec)
end

minetest.register_on_joinplayer(function(ref, last_login)
    local playername = ref:get_player_name()
    minetest.create_detached_inventory("exchangeclone_transmutation_"..playername, {
        allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
            local stack = inv:get_stack(from_list, from_index)
            stack:set_count(count)
            return allow_inventory_action(player, stack, to_list, count, true, inv)
        end,
        on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
            local stack = inv:get_stack(to_list, to_index)
            handle_inventory(player, inv, to_list, to_index, stack)
        end,
        allow_put = function(inv, listname, index, stack, player)
            local count = stack:get_count()
            return allow_inventory_action(player, stack, listname, count, false, inv)
        end,
        on_put = function(inv, listname, index, stack, player)
            handle_inventory(player, inv, listname, index, stack)
        end
    }, playername)
    local inventory = minetest.get_inventory({type = "detached", name = "exchangeclone_transmutation_"..playername})
    inventory:set_size("charge", 1)
    inventory:set_size("output", 4)
    inventory:set_width("output", 2)
    inventory:set_size("learn", 1)
    inventory:set_size("forget", 1)
    exchangeclone.reload_transmutation_list(ref)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "exchangeclone_transmutation_table" then
        if not check_for_table(player) then return end
        for field, value in pairs(fields) do
            if field == "search_box" or field == "quit" then
                -- do nothing
            elseif field == "right_arrow" then
                exchangeclone.show_transmutation_table_formspec(player, {page = player:get_meta():get_int("exchangeclone_transmutation_page") + 1})
            elseif field == "left_arrow" then
                exchangeclone.show_transmutation_table_formspec(player, {page = player:get_meta():get_int("exchangeclone_transmutation_page") - 1})
            elseif field == "search_button" or (field == "key_enter_field" and value == "search_box") then
                local search = fields.search_box or ""
                player:get_meta():set_string("exchangeclone_transmutation_search", search)
                exchangeclone.show_transmutation_table_formspec(player)
            elseif field == "plus1" then
                add_to_output(player, 1, true)
            elseif field == "plus5" then
                add_to_output(player, 5, true)
            elseif field == "plus10" then
                add_to_output(player, 10, true)
            elseif field == "plusstack" then
                add_to_output(player, true, true)
            elseif minetest.registered_items[field] then
                player:get_meta():set_string("exchangeclone_transmutation_selection", field)
                exchangeclone.show_transmutation_table_formspec(player, {selection = field})
            end
        end
    end
end)

minetest.register_tool("exchangeclone:transmutation_tablet", {
    description = "Transmutation Tablet",
    groups = {disable_repair = 1, fire_immune = 1},
    wield_image = "exchangeclone_transmutation_table.png",
    inventory_image = "exchangeclone_transmutation_table.png",
    on_secondary_use = function(itemstack, player, pointed_thing)
        local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
        if click_test ~= false then
            return click_test
        end
        exchangeclone.show_transmutation_table_formspec(player)
    end,
    on_place = function(itemstack, player, pointed_thing)
        local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
        if click_test ~= false then
            return click_test
        end
        exchangeclone.show_transmutation_table_formspec(player)
    end
})

minetest.register_node("exchangeclone:transmutation_table", {
    description = "Transmutation Table",
    paramtype2 = "wallmounted",
    tiles = {"exchangeclone_transmutation_table.png", "exchangeclone_transmutation_table.png", "exchangeclone_transmutation_table_side.png"},
    groups = {oddly_breakable_by_hand = 3, handy = 1},
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},
    },
    sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        exchangeclone.show_transmutation_table_formspec(player)
    end,
    _mcl_hardness = 0.6,
    _mcl_blast_resistance = 6,
})

minetest.register_tool("exchangeclone:alchemical_tome", {
    description = "Alchemical Tome",
    inventory_image = "exchangeclone_alchemical_tome.png",
    wield_image = "exchangeclone_alchemical_tome.png",
    groups = {disable_repair = 1, fire_immune = 1}
})

local book = "default:book"
local obsidian = "default:obsidian"
local stone = "default:stone"
if exchangeclone.mcl then
    book = "mcl_books:book"
    obsidian = "mcl_core:obsidian"
    stone = "mcl_core:stone"
end

minetest.register_craft({
    output = "exchangeclone:transmutation_table",
    recipe = {
        {obsidian, stone, obsidian},
        {stone, "exchangeclone:philosophers_stone", stone},
        {obsidian, stone, obsidian}
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft({
    output = "exchangeclone:transmutation_tablet",
    recipe = {
        {"exchangeclone:dark_matter_block", stone, "exchangeclone:dark_matter_block"},
        {stone, "exchangeclone:transmutation_table", stone},
        {"exchangeclone:dark_matter_block", stone, "exchangeclone:dark_matter_block"}
    },
})

minetest.register_craft({
    output = "exchangeclone:alchemical_tome",
    recipe = {
        {"", book, ""},
        {"exchangeclone:exchange_orb", "exchangeclone:philosophers_stone", "exchangeclone:exchange_orb"},
        {"", "exchangeclone:red_matter", ""}
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
    if itemstack == ItemStack("exchangeclone:alchemical_tome") then
        if exchangeclone.get_orb_itemstack_energy(old_craft_grid[4]) >= exchangeclone.energy_max
        and exchangeclone.get_orb_itemstack_energy(old_craft_grid[6]) >= exchangeclone.energy_max then
            return
        else
            return ItemStack("")
        end
    end
end)