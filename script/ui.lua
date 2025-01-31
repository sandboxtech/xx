local ui = {}


-- 创建主选择按钮
ui.create_team_buttons = function(player)
    if player.gui.center["team_buttons_frame"] then
        player.gui.center["team_buttons_frame"].destroy()
    end

    local frame = player.gui.center.add {
        type = "frame",
        name = "team_buttons_frame",
        direction = "vertical"
    }

    frame.add {
        type = "label",
        caption = { "", "宗门选择" },
        style = "frame_title"
    }

    local flow = frame.add {
        type = "flow",
        direction = "vertical"
    }

    -- 创建新宗门按钮
    flow.add {
        type = "button",
        name = "create_team",
        caption = "创建新宗门",
        style = "confirm_button"
    }

    -- 加入现有宗门按钮
    flow.add {
        type = "button",
        name = "join_team",
        caption = "加入老宗门",
        style = "confirm_button"
    }

    -- 战力榜按钮
    flow.add {
        type = "button",
        name = "tech_tree_button",
        caption = "查看战力榜",
        style = "confirm_button"
    }

    -- 神游榜按钮
    flow.add {
        type = "button",
        name = "speed_rank_button",
        caption = "查看神游榜",
        style = "confirm_button"
    }
end


return ui
