local force_manager = require("force_manager")

script.on_event(defines.events.on_research_finished, function(event)
    local research = event.research
    local force = research.force
    if not force then return end

    game.print(string.format(
        "宗门 [color=yellow]%s[/color] 掌握 [technology=%s]",
        force_manager.get_force_name(force), research.name))
end)
