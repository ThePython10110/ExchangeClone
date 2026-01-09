core.register_chatcommand("add_player_emc", {
    params = "[player] <value>",
    description = "Add to a player's personal EMC (player is self if not included, value can be negative to subtract)",
    privs = {privs = true},
    func = function(name, param)
        local split_param = param:split(" ")
        local target_player
        local target_name
        local value
        if #split_param == 1 then
            target_name = name
            value = split_param[1]
        elseif #split_param == 2 then
            target_name = split_param[1]
            value = split_param[2]
        end
        target_player = core.get_player_by_name(target_name)
        if (not (target_player and value)) or not tonumber(value) then
            return false, "Bad command. Use /add_player_emc [player] [value] or /add_player_emc [value]"
        end
        local emc = target_player:_get_emc()
        if (emc + value > exchangeclone.emc_limit) or (emc + value < 0) then
            return false, "Out of bounds; personal EMC must be between 0 and 1 trillion."
        end
        target_player:_add_emc(tonumber(value))
        return true, "Added "..exchangeclone.format_number(value).." to "..target_name.."'s personal EMC."
    end
})

-- Chat commands:
core.register_chatcommand("get_player_emc", {
    params = "[player]",
    description = "Gets a player's personal EMC (player is self if not included).",
    privs = {privs = true},
    func = function(name, param)
        local target_player
        local target_name
        if param and param ~= "" then
            target_name = param
        else
            target_name = name
        end
        target_player = core.get_player_by_name(target_name)
        if not (target_player) then
            return false,"Bad command. Use /get_player_emc [player] or /get_player_emc"
        end
        local emc = target_player:_get_emc()
        return true, target_name.."'s personal EMC: "..exchangeclone.format_number(emc)
    end
})

core.register_chatcommand("set_player_emc", {
    params = "[player] <value>",
    description = "Set a player's personal EMC (player is self if not included; use 'limit' as value to set it to maximum)",
    privs = {privs = true},
    func = function(name, param)
        local split_param = param:split(" ")
        local target_player
        local target_name
        local value
        if #split_param == 1 then
            target_name = name
            value = split_param[1]
        end
        if #split_param == 2 then
            target_name = split_param[1]
            value = split_param[2]
        end
        target_player = core.get_player_by_name(name)
        if (not (target_player and value)) or (not (value == "limit" or tonumber(value))) then
            return false, "Bad command. Use /set_player_emc [player] [value] or /set_player_emc [value]"
        end
        if value:lower() == "limit" then
            value = exchangeclone.emc_limit
        elseif (tonumber(value) > exchangeclone.emc_limit) or (tonumber(value) < 0) then
            return false, "Failed to set EMC; must be between 0 and 1 trillion."
        end
        target_player:_set_emc(tonumber(value))
        return true, "Set "..target_name.."'s personal EMC to "..exchangeclone.format_number(value)
    end
})