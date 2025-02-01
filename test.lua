for _, info in pairs(storage.forceInfos) do
    local force = info.force
    local min_offline_time = 0
    for _, player in pairs(force.players) do
        if not player.connected then
            local offline_time = (game.tick - player.last_online) / 60 / 60 / 60
            game.print(offline_time)
            if min_offline_time == 0 or min_offline_time > offline_time then
                min_offline_time = offline_time
            end
        else
            min_offline_time = 0
            break
        end
    end
end