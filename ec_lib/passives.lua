-- Apply passive effects every second
do
    local timer = 0
    core.register_globalstep(function(dtime)
        timer = timer + dtime
        if timer >= 1 then
            timer = 0
            for _, player in pairs(core.get_connected_players()) do
                local hb_max = player:hud_get_hotbar_itemcount()
                local inv = player:get_inventory()
                local processed_already = {}
                for i, stack in ipairs(inv:get_list("main")) do
                    if core.get_item_group(stack:get_name(), "exchangeclone_passive") then
                        local passive_data = stack:get_definition()._exchangeclone_passive
                        if passive_data
                        and not processed_already[stack:get_name()]
                        and (stack:get_meta():get_string("exchangeclone_active") == "true" or passive_data.always_active)
                        and (not passive_data.hotbar or (passive_data.hotbar and i <= hb_max)) then
                            local found
                            if passive_data.exclude then
                                for _, itemstring in pairs(passive_data.exclude) do
                                    if processed_already[itemstring] then
                                        found = true
                                        break
                                    end
                                end
                            end
                            if not found then
                                processed_already[stack:get_name()] = true
                                local result = passive_data.func(player, stack)
                                if result then inv:set_stack("main", i, result) end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function exchangeclone.toggle_active(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    local meta = itemstack:get_meta()
    local def = itemstack:get_definition()
    if meta:get_string("exchangeclone_active") ~= "true" then
        exchangeclone.play_sound(player, "exchangeclone_enable")
        meta:set_string("exchangeclone_active", "true")
        local active_image = def._exchangeclone_passive.active_image
        if active_image then
            meta:set_string("inventory_image", active_image)
        end
    else
        exchangeclone.play_sound(player, "exchangeclone_charge_down")
        meta:set_string("exchangeclone_active", "")
        meta:set_string("inventory_image", "")
    end
    return itemstack
end