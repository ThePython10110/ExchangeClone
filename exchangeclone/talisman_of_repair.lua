local function repair_items(inv, listname)
    local list = inv:get_list(listname)
    for i = 1, #list do
        local stack = inv:get_stack(listname, i)
        if not stack:is_empty() then
            local def = stack:get_definition()
            if def
            and def.type == "tool"
            and (not def.wear_represents or def.wear_represents == "mechanical_wear")
            and stack:get_wear() > 0 then
                local uses
                if exchangeclone.mcl then
                    local armor_uses = minetest.get_item_group(stack:get_name(), "mcl_armor_uses")
                    if def._mcl_uses then
                        uses = def._mcl_uses
                    elseif armor_uses > 0 then
                        uses = armor_uses
                    elseif def._mcl_diggroups then
                        for name, data in pairs(def._mcl_diggroups) do
                            uses = data.uses
                            break -- Just the simplest way to do it...
                        end
                    end
                else
                    if def.tool_capabilities and def.tool_capabilities.groupcaps then
                        local groupcaps
                        for name, data in pairs(def.tool_capabilities.groupcaps) do
                            groupcaps = data
                            break -- Just the simplest way to do it...
                        end
                        uses = groupcaps.uses*math.pow(3, groupcaps.maxlevel-1)
                    elseif def.groups.armor_use then
                        uses = 65535/def.groups.armor_use
                    end
                end
                if uses and uses > 0 then
                    stack:set_wear(math.max(0, stack:get_wear() - 65535/uses))
                    inv:set_stack(listname, i, stack)
                end
            end
        end
    end
end

minetest.register_tool("exchangeclone:talisman_of_repair", {
    description = "Talisman of Repair",
    inventory_image = "exchangeclone_talisman_of_repair.png",
    _exchangeclone_passive = {
        func = function(player)
            local inv = player:get_inventory()
            repair_items(inv, "main")
            if exchangeclone.mcl then
                repair_items(inv, "offhand")
                repair_items(inv, "armor")
            elseif minetest.get_modpath("3d_armor") then
                local _, armor_inv = armor:get_valid_player(player, "3d_armor")
                repair_items(armor_inv, "armor")
            end
        end,
        always_active = true
    },
    groups = {exchangeclone_passive = 1, disable_repair = 1}
})

local string = exchangeclone.mcl and "mcl_mobitems:string" or "farming:string"

minetest.register_craft({
    output = "exchangeclone:talisman_of_repair",
    recipe = {
        {"exchangeclone:low_covalence_dust", "exchangeclone:medium_covalence_dust", "exchangeclone:high_covalence_dust"},
        {string, exchangeclone.mcl and "mcl_core:paper" or "default:paper", string},
        {"exchangeclone:high_covalence_dust", "exchangeclone:medium_covalence_dust", "exchangeclone:low_covalence_dust"}
    }
})