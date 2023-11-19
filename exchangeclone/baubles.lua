local S = minetest.get_translator()

local storage = minetest.get_mod_storage()
exchangeclone.bauble_data = minetest.deserialize(storage:get_string("bauble_data"))

--[[

Bauble data format:
{
    action_name = {
        player = {
            player_name = true,
            player_name = true,
        }
        detached = {
            detached_name = true,
            detached_name = true,
        }
        node = {
            pos_string = true,
            pos_string = true,
        }
    }
}
For example:
{
    repair = {
        player = {
            "singleplayer",
            "ThePython"
        },
        detached = {
            "exchangeclone_transmutation_ThePython",
        }
        node = {
            ["(0,0,0)"] = true,
            ["(0,999,0)"] = true,
        }
    }
    density = {
        player = {
            "singleplayer"
        }
    }
}

What is done with these values must be handled by the actions themselves.

--]]

local time = 0
local saving_time = 0

function exchangeclone.run_bauble_actions()
    for _, data in ipairs(exchangeclone.bauble_data) do
        for _, action in ipairs(data[2]) do
            local func = exchangeclone.bauble_actions[action]
            if func then func(data) end
        end
    end
end

minetest.register_on_globalstep(function(dtime)
    time = time + dtime
    saving_time = saving_time + dtime
    if time >= 1 then
        exchangeclone.run_bauble_actions()
        time = 0
    end
end)

function exchangeclone.show_baubles(player)
    local formspec
    minetest.show_formspec(player:get_name(), "exchangeclone_baubles", formspec)
end

minetest.register_tool("exchangeclone:bauble_accessor", {
    description = S("Bauble Accessor"),
    groups = {disable_repair = 1},
})

minetest.register_tool("exchangeclone:repair_talisman", {
    description = S("Repair Talisman"),
    groups = {disable_repair = 1, bauble = 1},
    bauble_info = {
        action = "repair",
        hotbar = true
    },
})

minetest.register_tool("exchangeclone:gem_of_eternal_density", {
    description = S("Gem of Eternal Density"),
    groups = {disable_repair = 1, bauble = 1},
    bauble_info = {
        action = "density",
        hotbar = true
    }
})

function exchangeclone.check_baubles(inv, list)
    if not inv then return end
    list = list or "main"
end

minetest.register_on_player_inventory_action(function(player, action, inventory, info)
    -- Make sure that it's the player owning the inventory, not just the player editing the inventory
    player = minetest.get_player_by_name(inventory:get_location().name)
    if not player then return end
    if action == "move" then
        local stack = inventory:get_stack(info.to_list, info.to_index)
        if stack:is_empty() then return end
        local def = minetest.registered_items[stack:get_name()]
        if not (def and def.groups.bauble) then return end
        
    end
end)

local function repair_item(stack)
    if not stack:is_empty() then
        local def = minetest.registered_items[stack:get_name()]
        if def
        and def.type == "tool"
        and (not def.wear_represents or def.wear_represents == "mechanical_wear")
        and stack:get_wear() ~= 0
        and ((exchangeclone.mcl and def.durability > 0) or exchangeclone.mtg) then
            local uses
            if exchangeclone.mcl then
                if def.durability then
                    uses = def.durability
                elseif def._mcl_diggroups then
                    uses = def._mcl_diggroups[1].uses
                end
            else
                if def.tool_capabilities and def.tool_capabilities.groupcaps then
                    local groupcaps = def.tool_capabilities.groupcaps[1]
                    uses = groupcaps.uses*math.pow(3, groupcaps.max_level)
                elseif def.groups.armor_use then
                    uses = def.groups.armor_use
                end
            end
            if not uses then uses = 1000 end
            if uses then
                stack:set_wear(stack:get_wear() + 65535/uses)
            end
        end
    end

    return stack
end

exchangeclone.bauble_actions = {
    repair = function(data)
        for _, player in ipairs(data.player) do
            local inv = player:get_inventory()
            for i = 1, inv:get_size("main") do
                inv:set_stack("main", i, repair_item(inv:get_stack("main", i)))
            end
        end
    end
}