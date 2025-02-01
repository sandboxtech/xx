local force_manager = require("force_manager")

script.on_event(defines.events.on_space_platform_changed_state, function(event)
    -- 平台上限
    local platform = event.platform
    if event.old_state == 0 then
        local force = platform.force
        if #force.platforms > storage.max_platform_count then
            platform.destroy(3)
            
            game.print(string.format("宗门 [color=yellow]%s[/color] 最多拥有 3 个太空平台", force_manager.get_force_name(force)))
        end
    end
end)
