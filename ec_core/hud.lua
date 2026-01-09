local S = core.get_translator()

-- HUD stuff (show EMC value in bottom right)
local hud_elements = {}

---Updates the "Personal EMC" HUD element
---@param player core.Player
function exchangeclone.update_hud(player)
    local hud_text = hud_elements[player:get_player_name()]
    player:hud_change(hud_text, "text", S("Personal EMC: @1", exchangeclone.format_number(exchangeclone.get_player_emc(player))))
end

core.register_on_joinplayer(function(player, last_login)
    hud_elements[player:get_player_name()] = player:hud_add({
        hud_elem_type = "text",
        position      = {x = 1, y = 1},
        offset        = {x = 0,   y = 0},
        text          = S("Personal EMC: @1", 0),
        alignment     = {x = -1, y = -1},
        scale         = {x = 100, y = 100},
        number = 0xDDDDDD
    })
    exchangeclone.update_hud(player)
end)

core.register_on_leaveplayer(function(player, timed_out)
    hud_elements[player:get_player_name()] = nil
end)