-- Cooldowns
exchangeclone.cooldowns = {}

core.register_on_joinplayer(function(player, last_login)
    exchangeclone.cooldowns[player:get_player_name()] = {}
end)

core.register_on_leaveplayer(function(player, timed_out)
    exchangeclone.cooldowns[player:get_player_name()] = nil
end)

---Start a <time>-second cooldown called <name> for <player>
---@param player core.Player
---@param name string
---@param time number
function exchangeclone.start_cooldown(player, name, time)
    if not (player and name and time and (time > 0)) then return end
    local player_name = player:get_player_name()
    exchangeclone.cooldowns[player_name][name] = time
    core.after(time, function()
        if exchangeclone.cooldowns[player_name] then
            exchangeclone.cooldowns[player_name][name] = nil
        end
    end)
end

---Returns the TOTAL time of a cooldown called <name> for <player> or nil if no matching cooldown is running.
---@param player core.Player
---@param name string
---@return number?
function exchangeclone.check_cooldown(player, name)
    local player_name = player:get_player_name()
    if exchangeclone.cooldowns[player_name] then
        return exchangeclone.cooldowns[player_name][name]
    end
end