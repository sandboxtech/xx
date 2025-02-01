local force_manager = require("force_manager")
local ui = require("script.ui")
local level = require("level")

-- 创建主选择按钮
local create_team_buttons = ui.create_team_buttons

-- 销毁宗门界面(确认，取消)
local function show_destroy_team_dialog(player)
    if player.gui.center["destroy_team_frame"] then
        player.gui.center["destroy_team_frame"].destroy()
        return
    end

    local frame = player.gui.center.add {
        type = "frame",
        name = "destroy_team_frame",
        direction = "vertical"
    }

    -- 添加标题
    frame.add {
        type = "label",
        caption = "确认销毁宗门？",
        style = "frame_title"
    }

    -- 添加警告文本
    frame.add {
        type = "label",
        caption = "警告：此操作不可撤销！\n所有队员将被传送回出生点\n宗门领地将被重置",
        style = "bold_red_label"
    }

    local button_flow = frame.add {
        type = "flow",
        direction = "horizontal"
    }

    -- 确认按钮
    button_flow.add {
        type = "button",
        name = "confirm_destroy_team",
        caption = "确认销毁",
        style = "red_back_button" -- 使用红色按钮样式强调危险操作
    }

    -- 取消按钮
    button_flow.add {
        type = "button",
        name = "cancel_destroy_team",
        caption = "取消",
        style = "back_button"
    }
end

-- 已加入玩家界面
local function show_joined_player_ui(player)
    -- 删除已存在的界面
    if player.gui.left["joined_team_frame"] then
        player.gui.left["joined_team_frame"].destroy()
    end

    local frame = player.gui.left.add {
        type = "frame",
        name = "joined_team_frame",
        direction = "vertical"
    }


    -- 创建一个销毁宗门按钮
    frame.add {
        type = "button",
        name = "manage_team",
        caption = "宗门管理",
    }

    frame.add {
        type = "button",
        name = "level_up",
        caption = "境界提升",
    }

    -- 创建一个战力榜按钮
    frame.add {
        type = "button",
        name = "tech_tree_button",
        caption = "战力榜",
    }

    -- 创建一个神游榜按钮
    frame.add {
        type = "button",
        name = "speed_rank_button",
        caption = "神游榜",
    }

    -- -- 创建一个虫族挑战按钮
    -- frame.add{
    --     type = "button",
    --     name = "bug_challenge_button",
    --     caption = "虫族挑战",
    -- }

    -- 添加允许加入复选框
    frame.add {
        type = "checkbox",
        name = "allow_join_checkbox",
        caption = "允许他人加入宗门",
        state = storage.forceInfos[player.force.name].canJoin
    }
end

-- 宗门管理界面
local function show_team_manage(player)
    if player.gui.center["team_manage_frame"] then
        player.gui.center["team_manage_frame"].destroy()
        return
    end

    local frame = player.gui.center.add {
        type = "frame",
        name = "team_manage_frame",
        direction = "vertical"
    }

    -- 添加标题
    frame.add {
        type = "label",
        caption = "宗门管理",
        style = "frame_title"
    }



    -- 添加按钮流（纵向）
    local button_flow = frame.add {
        type = "flow",
        direction = "vertical"
    }

    -- 关闭按钮
    button_flow.add {
        type = "button",
        name = "close_team_manage",
        caption = "关闭",
        style = "confirm_button"
    }

    -- 传送到出生点
    button_flow.add {
        type = "button",
        name = "teleport_to_spawn",
        caption = "回到宗门",
        style = "confirm_button"
    }

    -- 回到仙舟内
    button_flow.add {
        type = "button",
        name = "enter_space_platform",
        caption = "进入仙舟",
        style = "confirm_button"
    }

    -- 离开宗门按钮
    button_flow.add {
        type = "button",
        name = "leave_team",
        caption = "退出宗门",
        style = "confirm_button"
    }

    -- 宗门改名按钮
    button_flow.add {
        type = "button",
        name = "rename_team",
        caption = "宗门改名",
        style = "confirm_button"
    }

    if player.admin then
        -- 销毁宗门按钮
        button_flow.add {
            type = "button",
            name = "destroy_team",
            caption = "销毁宗门",
            style = "red_button"
        }
    end
end

-- 境界提升确认界面
local function show_level_up_confirm(player)
    -- 检测是否到破碎星系
    if player.character == nil or
        player.character.surface.platform.space_location == nil or
        player.character.surface.platform.space_location.name ~= "shattered-planet" then
        -- player.surface.platform.space_location.name ~= "solar-system-edge" then
        player.print("你当前不在[space-location=shattered-planet],无法转生提升境界")
        return
    end

    local time = storage.speed_rank[player.name].curr_time;
    local speed = math.floor(4000000 / time * 100) / 100
    local index = level.get_index(player)
    local try_time = storage.speed_rank[player.name].try_time
    local min_speed = math.floor((index - try_time / 2 - 1) * 100)
    if speed < min_speed then
        player.print("当前平均速" .. speed .. "度低于" .. min_speed .. "km/s，无法转生提升境界")
        player.print("速度限制已降低50km/s，请返回星系边缘后重试")
        return
    end


    if player.gui.screen["level_up_frame"] then
        player.gui.screen["level_up_frame"].destroy()
    end

    local frame = player.gui.center.add {
        type = "frame",
        name = "level_up_confirm_frame",
        direction = "vertical"
    }

    frame.add {
        type = "label",
        caption = "确认转生提升境界？",
        style = "frame_title"
    }


    local button_flow = frame.add {
        type = "flow",
        direction = "horizontal"
    }

    button_flow.add {
        type = "button",
        name = "confirm_level_up",
        caption = "确认",
        style = "confirm_button"
    }

    button_flow.add {
        type = "button",
        name = "cancel_level_up",
        caption = "取消",
        style = "back_button"
    }
end

-- 境界提升界面
local function show_level_up(player)
    if player.gui.screen["level_up_frame"] then
        player.gui.screen["level_up_frame"].destroy()
        return
    end

    if not level.is_confirm(player) and
        (
            player.character == nil or
            player.character.surface.platform == nil or
            player.character.surface.platform.space_location == nil or
            player.character.surface.platform.space_location.name ~= "solar-system-edge") then
        -- player.surface.platform.space_location.name ~= "nauvis") then
        player.print("你当前不在[space-location=solar-system-edge]")
        player.print("乘坐仙舟前往[space-location=solar-system-edge]获取境界提升的线索")
        return
    end


    -- 显示界面
    local frame = player.gui.screen.add {
        type = "frame",
        name = "level_up_frame",
        direction = "vertical",
        -- 宽度
    }


    -- 设置窗口位置在屏幕中间
    frame.force_auto_center()

    local items = level.get_items(player)


    -- 水平排列
    local flow = frame.add {
        type = "flow",
        direction = "horizontal",
    }

    -- 标题:所系道具
    flow.add {
        type = "label",
        caption = "所需道具",
        style = "frame_title"
    }

    -- 添加空白填充元素
    local filler = flow.add {
        type = "empty-widget",
        style = "draggable_space"
    }
    filler.style.horizontally_stretchable = true
    filler.style.minimal_width = 100
    filler.style.size = { 310, 24 }
    filler.drag_target = frame
    -- 添加一个关闭按钮(右侧)
    flow.add {
        type = "button",
        name = "close_level_up",
        caption = "关闭",
        style = "back_button",
    }

    -- 创建一个滚动面板
    local scroll_pane = frame.add {
        type = "scroll-pane",
        name = "level_up_scroll",
        -- 宽度
    }
    scroll_pane.style.maximal_height = 600 -- 限制最大高度，超出时显示滚动条
    scroll_pane.style.horizontally_stretchable = true
    scroll_pane.style.minimal_width = 100

    -- 道具供应情况
    local item_supply_count = {}
    if player.surface.platform then
        local inventory = player.surface.platform.hub.get_inventory(defines.inventory.hub_main)
        for name, count in pairs(items) do
            local have = inventory.get_item_count({ name = name, quality = "legendary" })
            if have > count then
                have = count
            end
            table.insert(item_supply_count, { name = name, count = count, have = have })
        end
    else
        for name, count in pairs(items) do
            table.insert(item_supply_count, { name = name, count = count, have = 0 })
        end
    end

    -- 按缺少数量排序
    table.sort(item_supply_count, function(a, b) return a.count - a.have > b.count - b.have end)

    local all_have = true
    for i, item in pairs(item_supply_count) do
        if all_have and item.have < item.count then
            all_have = false
        end
        scroll_pane.add {
            type = "label",
            caption = i .. "、[item=" .. item.name .. ",quality=legendary](" .. item.have .. "/" .. item.count .. ")",
        }
    end

    local index = level.get_index(player)

    -- 滚动板下方添加一行说明标签
    frame.add {
        type = "label",
        caption = "乘坐仙舟携带所需道具前往[space-location=shattered-planet]转生提升境界",
        style = "label"
    }

    local count = index
    if count > 10 then
        count = 10
    end
    frame.add {
        type = "label",
        caption = "提示:转生将献祭宗门，仙舟轨道投送区前" .. (count) .. "格物品会被转生者带走",
        style = "label"
    }

    if index > 1 then
        if storage.speed_rank[player.name].try_time == nil then
            storage.speed_rank[player.name].try_time = 0
        end

        local diff = 0
        if player.character and player.character.surface and
            player.character.surface.platform and
            player.character.surface.platform.space_location and
            player.character.surface.platform.space_location.name == "shattered-planet" then
            diff = 1
        end

        local try_time = storage.speed_rank[player.name].try_time - diff

        local min_speed = math.floor((index - try_time / 2 - 1) * 100)
        frame.add {
            type = "label",
            caption = "边缘到破碎平均速度低于" .. min_speed .. "km/s无法转生，到达后速度要求降低50km/s",
            style = "label"
        }
    end

    -- 添加一个转生按钮
    local all_have_str = "_no"
    if all_have then
        all_have_str = "_yes"
    end
    frame.add {
        type = "button",
        name = "level_up_confirm" .. all_have_str,
        caption = "转生提升境界",
        style = "confirm_button"
    }
end

-- 战力榜界面
local function show_tech_rank(player)
    if player.gui.screen["tech_rank_frame"] then
        player.gui.screen["tech_rank_frame"].destroy()
        return
    end

    -- 主框架(显示在屏幕中间)
    local frame = player.gui.screen.add {
        type = "frame",
        name = "tech_rank_frame",
        direction = "vertical",
    }

    -- 设置窗口位置在屏幕中间
    frame.force_auto_center()

    -- 固定的标题行（水平流）
    local title_flow = frame.add {
        type = "flow",
        direction = "horizontal",
        style = "horizontal_flow"
    }

    -- 添加标题
    title_flow.add {
        type = "label",
        caption = "战力榜",
        style = "frame_title"
    }

    -- 添加空白填充元素(可拖动)
    local filler = title_flow.add {
        type = "empty-widget",
        style = "draggable_space"
    }
    filler.style.horizontally_stretchable = true
    filler.style.minimal_width = 100
    filler.style.size = { 400, 24 }
    filler.drag_target = frame

    -- 添加关闭按钮到标题行
    title_flow.add {
        type = "button",
        name = "close_tech_rank",
        caption = "关闭",
        style = "back_button"
    }

    -- 创建可滚动的内容面板
    local scroll_pane = frame.add {
        type = "scroll-pane",
        name = "tech_rank_scroll",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto-and-reserve-space"
    }
    scroll_pane.style.maximal_height = 400 -- 限制最大高度，超出时显示滚动条

    -- 在滚动面板中创建表格
    local table_item = scroll_pane.add {
        type = "table",
        name = "tech_rank_table",
        column_count = 6
    }


    -- 总人数
    local total_player_count = 0
    -- 在线人数
    local all_online_player_count = 0
    for _, player in pairs(game.players) do
        total_player_count = total_player_count + 1
        if player.connected then
            all_online_player_count = all_online_player_count + 1
        end
    end

    -- 添加表头
    table_item.add { type = "label", caption = "排名" }.style.minimal_width = 50
    table_item.add { type = "label", caption = "宗门" }.style.minimal_width = 80
    -- 最高境界
    table_item.add { type = "label", caption = "宗主境界" }.style.minimal_width = 80
    -- 战斗力
    table_item.add { type = "label", caption = "战斗力" }.style.minimal_width = 80
    -- 人数
    table_item.add { type = "label", caption = "人数(" .. all_online_player_count .. "/" .. total_player_count .. ")" }.style.minimal_width = 80
    -- 仙舟
    table_item.add { type = "label", caption = "仙舟" }.style.minimal_width = 80


    -- 获取所有宗门的战斗力数并排序
    local force_techs = {}
    for _, force_info in pairs(storage.forceInfos) do
        local force = force_info.force
        if force then
            local tech_count = 0
            for _, tech in pairs(prototypes.technology) do
                local tech_name = tech.name
                local f_tech = force.technologies[tech_name]
                if f_tech.researched or f_tech.level > tech.level then
                    if tech.max_level > 100 then
                        tech_count = tech_count + 1000 * f_tech.level * #f_tech.research_unit_ingredients
                    else
                        tech_count = tech_count + f_tech.research_unit_count * #f_tech.research_unit_ingredients
                    end
                end
            end
            -- 宗门人数
            local force_player_count = 0
            -- 在线人数
            local online_player_count = 0
            local max_level = 0
            for _, player2 in pairs(force.players) do
                local index = level.get_index(player2)
                if index > max_level then
                    max_level = index
                end
                force_player_count = force_player_count + 1
                if player2.connected then
                    online_player_count = online_player_count + 1
                end
            end
            tech_count = tech_count * (max_level + 1) / 2 * max_level

            table.insert(force_techs,
                {
                    name = force_info.name,
                    player_count = online_player_count .. "/" .. force_player_count,
                    count =
                        tech_count,
                    force = force,
                    index = force_info.index
                })
        end
    end

    -- 按战斗力数排序
    table.sort(force_techs, function(a, b) return a.count > b.count end)

    -- 添加排序后的数据
    for rank, force_data in ipairs(force_techs) do
        -- 排名
        table_item.add {
            type = "label",
            caption = "   " .. rank
        }

        -- 生成队员名单提示文本
        local force = force_data.force
        local tooltip = "宗门编号:" .. force_data.index .. "\n队员列表:"
        local player_list = {} -- 记录然后按离线时间排序
        for _, p in pairs(force.players) do
            -- 在线玩家
            if p.connected then
                table.insert(player_list, { name = p.name, time = 0 })
            else
                -- 离线时长
                local time_diff = game.tick - p.last_online
                table.insert(player_list, { name = p.name, time = time_diff })
            end
        end
        -- 按离线时间排序
        local max_level_info = { name = "", level = 0 }
        table.sort(player_list, function(a, b) return a.time < b.time end)
        for _, p in pairs(player_list) do
            local index = level.get_index(p)
            local name = level.get_name(p)
            if index > max_level_info.level then
                max_level_info.level = index
                max_level_info.name = name
            end
            if p.time > 0 then
                local hours = math.floor(p.time / 21600) / 10
                tooltip = tooltip .. "\n" .. "[离线" .. hours .. "小时]" .. p.name .. "[" .. name .. "]"
            else
                tooltip = tooltip .. "\n" .. "[在线]" .. p.name .. "[" .. name .. "]"
            end
        end

        -- 宗门名（带提示）点击打印宗门出生点位置
        table_item.add {
            type = "label",
            caption = force_data.name,
            tooltip = tooltip,
        }

        local value = (max_level_info.level + 1) / 2 * max_level_info.level
        local count = max_level_info.level
        local index = max_level_info.level
        if count > 10 then
            count = 10
        end
        -- 最高境界
        table_item.add {
            type = "label",
            caption = max_level_info.name,
            tooltip = "战力倍率:" 
            .. value .. "00%" 
            .. "\n制作速度:" 
            .. (100 + (index - 1) * 50) 
            .. "%\n挖掘速度:" 
            .. (100 + (index - 1) * 50) .. "%" 
            .. "\n转生所需传说道具数量:" .. value 
            .. "0\n转生时可携带道具格数:" .. count 
            .. "\n仙舟数量上限:" .. (index + 3) 
            .. "\n仙舟总吨位上限:" .. (((index + 3) * 1000) 
            .. "\n乘坐的仙舟可设置速度上限:" .. (index * 110) 
            .. "km/s" .. "\n火箭射速:+" .. ((index - 1) * 20) .. "%")
        }

        -- 战斗力
        table_item.add {
            type = "label",
            caption = force_data.count
        }

        -- 人数
        table_item.add {
            type = "label",
            caption = force_data.player_count
        }


        -- 该队仙舟按吨位排序
        local ship_list = {}
        for _, platform in pairs(force.platforms) do
            table.insert(ship_list, { name = platform.name, weight = platform.weight })
        end
        -- 按吨位排序
        table.sort(ship_list, function(a, b) return a.weight > b.weight end)

        local tooltip2 = "仙舟列表:"
        local total_weight = 0
        local ship_count = 0
        for _, ship in pairs(ship_list) do
            local weight_str = (ship.weight / 1000) .. "吨"
            if ship.weight == 0 then weight_str = "[已炸]" end
            tooltip2 = tooltip2 .. "\n" .. weight_str .. "☞" .. ship.name
            total_weight = total_weight + ship.weight / 1000
            ship_count = ship_count + 1
        end

        -- 仙舟
        table_item.add {
            type = "button",
            name = "show_ship_list_" .. force.name,
            caption = ship_count .. "艘" .. total_weight .. "吨",
            tooltip = tooltip2,
        }
    end
end

-- 神游榜界面
local function show_speed_rank(player)
    if player.gui.screen["speed_rank_frame"] then
        player.gui.screen["speed_rank_frame"].destroy()
        return
    end

    if storage.speed_rank == nil then
        storage.speed_rank = {}
    end

    if storage.speed_rank[player.name] == nil then
        storage.speed_rank[player.name] = {}
    end

    if storage.speed_rank[player.name].rank_type == nil then
        storage.speed_rank[player.name].rank_type = "score"
    end

    if storage.speed_rank[player.name].rank_planet == nil then
        storage.speed_rank[player.name].rank_planet = "shattered-planet"
    end

    local rank_type = storage.speed_rank[player.name].rank_type
    local rank_planet = storage.speed_rank[player.name].rank_planet


    local frame = player.gui.screen.add {
        type = "frame",
        name = "speed_rank_frame",
        direction = "vertical",
    }

    -- 设置窗口位置在屏幕中间
    frame.force_auto_center()

    -- 固定的标题行（水平流）
    local title_flow = frame.add {
        type = "flow",
        direction = "horizontal",
        style = "horizontal_flow"
    }

    -- 添加标题
    title_flow.add {
        type = "label",
        caption = "神游榜",
        style = "frame_title"
    }

    -- 添加选择星球按钮
    local button1 = title_flow.add {
        type = "button",
        name = "select_planet_shattered-planet",
        caption = "[space-location=shattered-planet]",
    }

    local button2 = title_flow.add {
        type = "button",
        name = "select_planet_solar-system-edge",
        caption = "[space-location=solar-system-edge]",
    }

    local button3 = title_flow.add {
        type = "button",
        name = "select_planet_aquilo",
        caption = "[space-location=aquilo]",
    }

    local button4 = title_flow.add {
        type = "button",
        name = "select_planet_nauvis",
        caption = "[space-location=nauvis]",
    }

    button1.style.minimal_width = 32
    button2.style.minimal_width = 32
    button3.style.minimal_width = 32
    button4.style.minimal_width = 32


    -- 添加空白填充元素(可拖动)
    local filler = title_flow.add {
        type = "empty-widget",
        style = "draggable_space"
    }
    filler.style.horizontally_stretchable = true
    filler.style.minimal_width = 100
    filler.style.size = { 154, 24 }
    filler.drag_target = frame


    -- 添加关闭按钮到标题行
    title_flow.add {
        type = "button",
        name = "close_speed_rank",
        caption = "关闭",
        style = "back_button"
    }

    -- 创建可滚动的内容面板
    local scroll_pane = frame.add {
        type = "scroll-pane",
        name = "speed_rank_scroll",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto-and-reserve-space"
    }

    -- 在滚动面板中创建表格
    local table_item = scroll_pane.add {
        type = "table",
        name = "speed_rank_table",
        column_count = 6
    }

    -- 添加表头
    table_item.add { type = "label", caption = "排名" }.style.minimal_width = 40
    table_item.add { type = "label", caption = "星球" }.style.minimal_width = 40
    table_item.add { type = "label", caption = "玩家" }.style.minimal_width = 120
    table_item.add { type = "button", caption = "分数", name = "speed_rank_score" }.style.minimal_width = 80
    table_item.add { type = "button", caption = "速度", name = "speed_rank_speed" }.style.minimal_width = 120
    table_item.add { type = "button", caption = "重量", name = "speed_rank_weight" }.style.minimal_width = 80

    -- 获取神游榜数据
    local speed_rank = storage.speed_rank
    if speed_rank == nil then
        return
    end

    local data_list = {}

    for player_name, rank_data in pairs(speed_rank) do
        for planet_name, planet_data in pairs(rank_data) do
            -- 如果planet_datas是table
            if type(planet_data) == "table" and planet_data.socre ~= nil then
                if planet_name == rank_planet and rank_type == "score" then
                    table.insert(data_list,
                        { player_name = player_name, planet_name = planet_name, planet_data = planet_data })
                end
                if planet_name == rank_planet and rank_type == "speed" then
                    local data = planet_data.min_time
                    if data == nil or data.time > planet_data.time then data = planet_data end
                    table.insert(data_list, { player_name = player_name, planet_name = planet_name, planet_data = data })
                end
                if planet_name == rank_planet and rank_type == "weight" then
                    local data = planet_data.min_weight
                    if data == nil or data.weight > planet_data.weight then data = planet_data end
                    table.insert(data_list, { player_name = player_name, planet_name = planet_name, planet_data = data })
                end
            end
        end
    end

    -- 按分数排序
    if rank_type == "speed" then
        table.sort(data_list, function(a, b)
            if a.planet_data.distance / a.planet_data.time == b.planet_data.distance / b.planet_data.time then
                return a.planet_data.weight < b.planet_data.weight
            end
            return a.planet_data.distance / a.planet_data.time > b.planet_data.distance / b.planet_data.time
        end)
    elseif rank_type == "weight" then
        table.sort(data_list, function(a, b)
            if a.planet_data.weight == b.planet_data.weight then
                return a.planet_data.distance / a.planet_data.time > b.planet_data.distance / b.planet_data.time
            end
            return a.planet_data.weight < b.planet_data.weight
        end)
    else
        table.sort(data_list, function(a, b) return a.planet_data.socre > b.planet_data.socre end)
    end


    for rank, data in ipairs(data_list) do
        local player2 = game.players[data.player_name]
        local socre = data.planet_data.socre
        local distance = data.planet_data.distance
        local weight = data.planet_data.weight
        local time = data.planet_data.time
        table_item.add { type = "label", caption = rank }
        table_item.add { type = "label", caption = "[space-location=" .. data.planet_name .. "]" }
        table_item.add { type = "label", caption = player2.name .. player2.tag }
        table_item.add { type = "label", caption = math.floor(socre) }
        table_item.add { type = "label", caption = (math.floor(distance / time * 100) / 100) .. "km/s" }
        table_item.add { type = "label", caption = weight .. "吨" }
    end
end

-- 虫族挑战界面
local function show_bug_challenge(player)
    if player.gui.screen["bug_challenge_frame"] then
        player.gui.screen["bug_challenge_frame"].destroy()
        return
    end

    local frame = player.gui.screen.add {
        type = "frame",
        name = "bug_challenge_frame",
        direction = "vertical",
    }

    -- 设置窗口位置在屏幕中间
    frame.force_auto_center()

    -- 固定的标题行（水平流）
    local title_flow = frame.add {
        type = "flow",
        direction = "horizontal",
        style = "horizontal_flow"
    }

    -- 添加标题
    title_flow.add {
        type = "label",
        caption = "虫族挑战",
        style = "frame_title"
    }

    -- 添加开始挑战按钮
    local button = title_flow.add {
        type = "button",
        name = "start_bug_challenge",
        caption = "开始挑战",
        style = "confirm_button"
    }
    button.style.minimal_width = 64

    -- 添加空白填充元素(可拖动)
    local filler = title_flow.add {
        type = "empty-widget",
        style = "draggable_space"
    }
    filler.style.horizontally_stretchable = true
    filler.style.minimal_width = 100
    filler.style.size = { 154, 24 }
    filler.drag_target = frame

    -- 添加关闭按钮到标题行
    title_flow.add {
        type = "button",
        name = "close_bug_challenge",
        caption = "关闭",
        style = "back_button"
    }

    -- 创建可滚动的内容面板
    local scroll_pane = frame.add {
        type = "scroll-pane",
        name = "bug_challenge_scroll",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto-and-reserve-space"
    }

    -- 在滚动面板中创建表格
    local table_item = scroll_pane.add {
        type = "table",
        name = "bug_challenge_table",
        column_count = 7
    }

    -- 添加表头
    table_item.add { type = "label", caption = "排名" }.style.minimal_width = 40
    table_item.add { type = "label", caption = "玩家" }.style.minimal_width = 120
    table_item.add { type = "button", caption = "单局击杀", name = "bug_challenge_single_kill" }.style.minimal_width = 120
    table_item.add { type = "button", caption = "累计击杀", name = "bug_challenge_total_kill" }.style.minimal_width = 80
    table_item.add { type = "button", caption = "境界", name = "bug_challenge_level" }.style.minimal_width = 80
    table_item.add { type = "button", caption = "状态", name = "bug_challenge_online" }.style.minimal_width = 80
    table_item.add { type = "button", caption = "观战", name = "bug_challenge_watch" }.style.minimal_width = 80
end

-- 创建新宗门界面
local function show_create_team_dialog(player)
    if player.gui.center["create_team_frame"] then
        player.gui.center["create_team_frame"].destroy()
    end

    local frame = player.gui.center.add {
        type = "frame",
        name = "create_team_frame",
        direction = "vertical"
    }

    frame.add {
        type = "label",
        caption = "输入新宗门名称",
        style = "frame_title"
    }

    frame.add {
        type = "textfield",
        name = "team_name_input"
    }

    local button_flow = frame.add {
        type = "flow",
        direction = "horizontal"
    }

    button_flow.add {
        type = "button",
        name = "confirm_create_team",
        caption = "确认",
        style = "confirm_button"
    }

    button_flow.add {
        type = "button",
        name = "cancel_create_team",
        caption = "取消",
        style = "back_button"
    }
end

-- 显示宗门列表界面
local function show_team_list(player)
    if player.gui.center["team_list_frame"] then
        player.gui.center["team_list_frame"].destroy()
    end

    local frame = player.gui.center.add {
        type = "frame",
        name = "team_list_frame",
        direction = "vertical"
    }

    local title = frame.add {
        type = "label",
        caption = "选择要加入的宗门",
        style = "frame_title"
    }

    local list_flow = frame.add {
        type = "flow",
        direction = "vertical"
    }

    -- 添加现有宗门按钮
    local canAddCount = 0;
    for force_name, force_info in pairs(storage.forceInfos) do
        if force_info.canJoin then
            canAddCount = canAddCount + 1;
            list_flow.add {
                type = "button",
                name = "join_force_" .. force_name,
                caption = force_info.name,
                style = "confirm_button"
            }
        end
    end

    if canAddCount == 0 then
        title.caption = "没有可加入的宗门"
    end

    frame.add {
        type = "button",
        name = "cancel_join_team",
        caption = "返回",
        style = "back_button"
    }
end

-- 创建新宗门
local function create_new_team(player, team_name)
    if player.character == nil then
        player.print("此处没有玩家角色，无法创建宗门")
        return false
    end

    -- 名字长度不超过40个字符
    if #team_name > 40 then
        player.print("你的宗门名太长了", { r = 1 })
        return false
    end

    if force_manager.is_force_name_exist(team_name) then
        player.print("宗门名称已存在，请重新输入", { r = 1 })
        return false
    end

    -- 创建新的势力
    local force = force_manager.create_force(team_name, player.surface.name)

    -- 将玩家加入新宗门
    player.force = force
    game.print(player.name .. " 创建并加入了宗门: " .. team_name)


    -- 火箭射速增加
    local rocket_speed = force.get_gun_speed_modifier("rocket")
    if rocket_speed == nil then
        rocket_speed = 0
    end
    local index = level.get_index(player)
    rocket_speed = rocket_speed + (index - 1) * 0.2
    force.set_gun_speed_modifier("rocket", rocket_speed)
    player.print("火箭射速增加" .. ((index - 1) * 20) .. "%")
    storage.speed_rank[player.name].add = true;

    -- 设置科技等级
    level.set_tech_level(player)

    -- 传送到宗门出生点
    player.character.teleport(force.get_spawn_position(player.surface))

    local index = level.get_index(player)
    player.character_crafting_speed_modifier = (index - 1) * 0.5
    player.character_mining_speed_modifier = (index - 1) * 0.5

    -- 插入100木头
    player.insert { name = "wood", count = 100 }
    player.insert { name = "modular-armor", count = 1 }
    player.insert { name = "personal-roboport-equipment", count = 1 }
    player.insert { name = "solar-panel-equipment", count = 2 }
    player.insert { name = "construction-robot", count = 10 }

    show_joined_player_ui(player)

    return true
end

-- 添加宗门改名对话框
local function show_rename_team_dialog(player)
    if player.gui.center["rename_team_frame"] then
        player.gui.center["rename_team_frame"].destroy()
    end

    local frame = player.gui.center.add {
        type = "frame",
        name = "rename_team_frame",
        direction = "vertical"
    }

    frame.add {
        type = "label",
        caption = "输入新的宗门名称",
        style = "frame_title"
    }

    frame.add {
        type = "textfield",
        name = "team_new_name_input"
    }

    local button_flow = frame.add {
        type = "flow",
        direction = "horizontal"
    }

    button_flow.add {
        type = "button",
        name = "confirm_rename_team",
        caption = "确认",
        style = "confirm_button"
    }

    button_flow.add {
        type = "button",
        name = "cancel_rename_team",
        caption = "取消",
        style = "back_button"
    }
end

-- 处理按钮点击事件
local function on_gui_click(event)
    local element = event.element
    local player = game.players[event.player_index]

    -- 仙舟列表
    if element.name:sub(1, #"show_ship_list_") == "show_ship_list_" then
        local force_name = element.name:sub(#"show_ship_list_" + 1)
        local force = game.forces[force_name]
        if not force then
            player.print(force_name .. "宗门不存在", { r = 1 })
            return
        end

        local ship_list = {}
        for _, platform in pairs(force.platforms) do
            if (platform.surface) then
                table.insert(ship_list,
                    { name = platform.name, weight = platform.weight, surrface_name = platform.surface.name })
            end
        end
        -- 按吨位排序
        table.sort(ship_list, function(a, b) return a.weight > b.weight end)

        player.print(force_manager.get_force_name(force) .. "的仙舟列表:")
        local total_weight = 0
        local ship_count = 0
        for _, ship in pairs(ship_list) do
            player.print((ship.weight / 1000) .. "吨☞[gps=0,0," .. ship.surrface_name .. "]")
            total_weight = total_weight + ship.weight / 1000
            ship_count = ship_count + 1
        end
        player.print("共" .. ship_count .. "艘" .. total_weight .. "吨")
    elseif element.name == "create_team" then
        show_create_team_dialog(player)
        element.parent.parent.destroy()
    elseif element.name == "join_team" then
        show_team_list(player)
        element.parent.parent.destroy()
    elseif element.name == "confirm_create_team" then
        local team_name = element.parent.parent["team_name_input"].text
        if team_name and team_name ~= "" then
            if create_new_team(player, team_name) then
                element.parent.parent.destroy()
            end
        else
            player.print("请输入宗门名称", { r = 1 })
        end
    elseif element.name == "cancel_create_team" then
        element.parent.parent.destroy()
        create_team_buttons(player)
    elseif element.name == "cancel_join_team" then
        element.parent.destroy()
        create_team_buttons(player)
    elseif element.name:sub(1, 11) == "join_force_" then
        if player.character == nil then
            player.print("此处没有玩家角色，无法加入宗门")
            return
        end

        local force_name = element.name:sub(12)
        local force_info = storage.forceInfos[force_name]
        game.print(player.name .. " 加入了宗门: " .. force_info.name)

        player.force = storage.forceInfos[force_name].force

        -- 传送到宗门出生点
        local surface = "nauvis"
        if force_info.spawn_surface then
            surface = force_info.spawn_surface
        end
        player.teleport(player.force.get_spawn_position(game.surfaces[surface]))

        local index = level.get_index(player)
        player.character_crafting_speed_modifier = (index - 1) * 0.5
        player.character_mining_speed_modifier = (index - 1) * 0.5

        show_joined_player_ui(player)
        element.parent.parent.destroy()

        -- 添加战力榜按钮处理
    elseif element.name == "tech_tree_button" then
        if (player.force.name == "player") then
            player.gui.center["team_buttons_frame"].destroy() -- 销毁宗门按钮
        end
        show_tech_rank(player)
    elseif element.name == "close_tech_rank" then
        if player.gui.screen["tech_rank_frame"] then
            player.gui.screen["tech_rank_frame"].destroy()
        end
        if (player.force.name == "player") then
            -- 显示宗门按钮
            create_team_buttons(player)
        end
    elseif element.name == "speed_rank_button" then           -- 神游榜
        if (player.force.name == "player") then
            player.gui.center["team_buttons_frame"].destroy() -- 销毁宗门按钮
        end
        show_speed_rank(player)
    elseif element.name == "bug_challenge_button" then        -- 虫族挑战
        if (player.force.name == "player") then
            player.gui.center["team_buttons_frame"].destroy() -- 销毁宗门按钮
        end
        show_bug_challenge(player)
    elseif element.name == "close_bug_challenge" then
        if player.gui.screen["bug_challenge_frame"] then
            player.gui.screen["bug_challenge_frame"].destroy()
        end
    elseif element.name == "close_speed_rank" then
        if player.gui.screen["speed_rank_frame"] then
            player.gui.screen["speed_rank_frame"].destroy()
        end
        if (player.force.name == "player") then
            -- 显示宗门按钮
            create_team_buttons(player)
        end
    elseif element.name == "teleport_to_spawn" then
        if player.character == nil then
            player.print("此处没有玩家角色，无法传送到出生点")
            return
        end
        player.teleport(player.force.get_spawn_position(player.surface))
        element.parent.parent.destroy()
    elseif element.name == "enter_space_platform" then
        if player.character == nil then
            player.print("此处没有玩家角色，无法进入仙舟")
            return
        end

        if player.character.surface.platform ~= nil then
            player.enter_space_platform(player.character.surface.platform)
        else
            player.print("宗门此处没有仙舟，无法进入仙舟")
        end
        element.parent.parent.destroy()
    elseif element.name == "close_team_manage" then
        element.parent.parent.destroy()

        -- 添加销毁宗门相关的处理
    elseif element.name == "destroy_team" then
        show_destroy_team_dialog(player)
        element.parent.parent.destroy()
    elseif element.name == "confirm_destroy_team" then
        local force = player.force
        force_manager.destroy_force(force) -- 调用 force_manager 中的销毁函数
        create_team_buttons(player)        -- 显示创建宗门界面
        element.parent.parent.destroy()    -- 关闭确认对话框
    elseif element.name == "cancel_destroy_team" then
        element.parent.parent.destroy()    -- 关闭确认对话框
        show_team_manage(player)           -- 返回宗门管理界面
    elseif element.name == "manage_team" then
        show_team_manage(player)
    elseif element.name == "level_up" then -- 境界提升
        show_level_up(player)
    elseif element.name == "leave_team" then
        if player.character == nil then
            player.print("此处没有玩家角色，无法离开宗门")
            return
        end

        -- 离开宗门
        local force_info = storage.forceInfos[player.force.name]

        force_info.canJoin = true -- 宗门允许加入
        -- 同步所有同宗门玩家的复选框状态
        for _, p in pairs(force_info.force.players) do
            if p.gui.left["joined_team_frame"] then
                p.gui.left["joined_team_frame"]["allow_join_checkbox"].state = true
            end
        end
        if force_info.canJoin then
            game.print(string.format("宗门 [color=yellow]%s[/color] 开始招收弟子", force_manager.get_force_name(force)))
        else
            game.print(string.format("宗门 [color=yellow]%s[/color] 停止招收弟子", force_manager.get_force_name(force)))
        end


        element.parent.parent.destroy()
        player.gui.left["joined_team_frame"].destroy()

        -- 传送回出生点
        -- 传送到宗门出生点
        local surface = "nauvis"
        if force_info.spawn_surface then
            surface = force_info.spawn_surface
        end
        player.teleport(player.force.get_spawn_position(game.surfaces[surface]))

        -- player.character.damage(100000000, "enemy")
        player.character.die()
        game.print(player.name .. "自刎离开了宗门: " .. force_manager.get_force_name(player.force))

        player.force = game.forces.player
    elseif element.name == "rename_team" then
        -- 显示改名对话框
        show_rename_team_dialog(player)
        element.parent.parent.destroy()
        -- 在 on_gui_click 中添加改名相关处理
    elseif element.name == "confirm_rename_team" then
        local new_name = element.parent.parent["team_new_name_input"].text
        if new_name and new_name ~= "" then
            local old_name = storage.forceInfos[player.force.name].name
            -- 检查新名称是否已存在
            if #new_name > 40 then
                player.print("宗门名号过长，恐难载于三生石", { r = 1 })
                return
            elseif force_manager.is_force_name_exist(new_name) then
                player.print("宗门名号已载于三生石，请另择仙缘", { r = 1 })
                return
            end
            -- 更新宗门名称
            storage.forceInfos[player.force.name].name = new_name
            game.print(string.format("宗门 [color=yellow]%s[/color] 改名为 [color=yellow]%s[/color]", old_name, new_name))
            element.parent.parent.destroy()
            show_joined_player_ui(player)
        else
            player.print("请输入新的宗门名称", { r = 1 })
        end
    elseif element.name == "cancel_rename_team" then
        element.parent.parent.destroy()
        show_team_manage(player)
    elseif element.name == "level_up_confirm_no" then
        player.print("所在仙舟仓库缺少境界提升所需道具", { r = 1 })
    elseif element.name == "level_up_confirm_yes" then
        -- 打开境界提升确认界面
        show_level_up_confirm(player)
    elseif element.name == "cancel_level_up" then
        player.gui.center["level_up_confirm_frame"].destroy()
        show_level_up(player)
    elseif element.name == "confirm_level_up" then
        if player.character == nil or player.character.surface.platform == nil then
            player.print("此处没有玩家角色，无法提升境界")
            return
        end
        player.gui.center["level_up_confirm_frame"].destroy()
        local force = player.force
        level.up(player)
        force_manager.destroy_force(force) -- 调用 force_manager 中的销毁函数
        if player.gui.left["joined_team_frame"] then player.gui.left["joined_team_frame"].destroy() end
        create_team_buttons(player)        -- 显示创建宗门界面
    elseif element.name == "close_level_up" then
        player.gui.screen["level_up_frame"].destroy()
    elseif element.name == "speed_rank_score" then
        player.gui.screen["speed_rank_frame"].destroy()
        storage.speed_rank[player.name].rank_type = "score"
        show_speed_rank(player)
    elseif element.name == "speed_rank_speed" then
        player.gui.screen["speed_rank_frame"].destroy()
        storage.speed_rank[player.name].rank_type = "speed"
        show_speed_rank(player)
    elseif element.name == "speed_rank_weight" then
        player.gui.screen["speed_rank_frame"].destroy()
        storage.speed_rank[player.name].rank_type = "weight"
        show_speed_rank(player)
    elseif element.name == "select_planet_nauvis" then
        player.gui.screen["speed_rank_frame"].destroy()
        storage.speed_rank[player.name].rank_planet = "nauvis"
        show_speed_rank(player)
    elseif element.name == "select_planet_aquilo" then
        player.gui.screen["speed_rank_frame"].destroy()
        storage.speed_rank[player.name].rank_planet = "aquilo"
        show_speed_rank(player)
    elseif element.name == "select_planet_solar-system-edge" then
        player.gui.screen["speed_rank_frame"].destroy()
        storage.speed_rank[player.name].rank_planet = "solar-system-edge"
        show_speed_rank(player)
    elseif element.name == "select_planet_shattered-planet" then
        player.gui.screen["speed_rank_frame"].destroy()
        storage.speed_rank[player.name].rank_planet = "shattered-planet"
        show_speed_rank(player)
    end
end

local get_time_str = function (ke)
    local k = ke % 4

end

-- 当玩家加入游戏时显示按钮
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    player.tag = level.get_name(player, true)

    -- local canBluePrint = false
    -- -- game.permissions.get_group("Default").set_allows_action(defines.input_action.import_blueprint_string, canBluePrint)
    -- game.permissions.get_group("Default").set_allows_action(defines.input_action.grab_blueprint_record, canBluePrint)
    -- game.permissions.get_group("Default").set_allows_action(defines.input_action.import_blueprint, canBluePrint)
    -- game.permissions.get_group('Default').set_allows_action(defines.input_action.open_blueprint_library_gui, canBluePrint)
    -- game.permissions.get_group('Default').set_allows_action(defines.input_action.activate_paste, canBluePrint)

    local player = game.get_player(event.player_index)

    local hour_to_tick = 15 * 60 * 60 -- 54000
    if player.online_time > 0 then
        local last_delta = math.max(0, math.floor((game.tick - player.last_online) / hour_to_tick))
        local total_time = math.max(0, math.floor(player.online_time / hour_to_tick))
        game.print(string.format("欢迎 %s 道友重临星域！\n在线时长 %i 刻\n距离上次登录 %i 刻", player.name, total_time, last_delta))

        -- 当前星域时辰：卯时三刻 在线修士：427/500
        player.print(string.format("当前星域时辰 %i 刻", math.floor(game.tick % hour_to_tick)))
    else
        game.print(string.format("欢迎 %s 道友光临星域", player.name))
        player.print("▶ 输入「修仙」阅读〖星域修仙录〗")
    end

    -- 火箭射速增加
    if storage.speed_rank == nil then
        storage.speed_rank = {}
    end
    if storage.speed_rank[player.name] == nil then
        storage.speed_rank[player.name] = {}
    end
    if storage.speed_rank[player.name].add == nil then
        local force = player.force
        local rocket_speed = force.get_gun_speed_modifier("rocket")
        if rocket_speed == nil then
            rocket_speed = 0
        end
        local index = level.get_index(player)
        if index > 1 then
            rocket_speed = rocket_speed + (index - 1) * 0.2
            force.set_gun_speed_modifier("rocket", rocket_speed)
            player.print("火箭射速增加" .. ((index - 1) * 20) .. "%")
            storage.speed_rank[player.name].add = true;
        end
    end

    if player.force.name == "player" then
        create_team_buttons(player)
    else
        show_joined_player_ui(player)
    end
end)

-- 当玩家退出
script.on_event(defines.events.on_player_left_game, function(event)
    local player = game.players[event.player_index]
    player.tag = level.get_name(player, true)

    game.print(string.format("%s%s 开始闭关修炼",
        player.name, player.tag, name, weight))

    local surface_names = { "nauvis", "fulgora", "vulcanus", "gleba", "aquilo" }
    for _, surface_name in pairs(surface_names) do
        -- unchart
    end
end)

-- 注册GUI点击事件
script.on_event(defines.events.on_gui_click, on_gui_click)

-- 场景创建时触发
script.on_event(defines.events.on_game_created_from_scenario, function()
    storage.forceInfos = storage.forceInfos or {}

    game.forces.player.share_chart = true
end)

-- 添加复选框状态改变事件处理
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    local element = event.element
    local player = game.players[event.player_index]

    if element.name == "allow_join_checkbox" then
        storage.forceInfos[player.force.name].canJoin = element.state
        if element.state then
            game.print(string.format("宗门 [color=yellow]%s[/color] 开始招收弟子", force_manager.get_force_name(player.force)))
        else
            game.print(string.format("宗门 [color=yellow]%s[/color] 停止招收弟子", force_manager.get_force_name(player.force)))
        end

        -- 同步所有同宗门玩家的复选框状态
        for _, p in pairs(player.force.players) do
            if p.gui.left["joined_team_frame"] then
                p.gui.left["joined_team_frame"]["allow_join_checkbox"].state = element.state
            end
        end
    end
end)

-- 玩家复活时触发
script.on_event(defines.events.on_player_respawned, function(event)
    local player = game.players[event.player_index]
    if player.force.name == "player" then
        create_team_buttons(player)
    end
end)

-- 仙舟建造地板时触发
script.on_event(defines.events.on_space_platform_built_tile, function(event)
    local platform = event.platform
    local surface = platform.surface

    local max_level = 0
    for _, player in pairs(platform.force.players) do
        local level = level.get_index(player)
        if level > max_level then
            max_level = level
        end
    end

    local weight_sum = 0;
    for _, platform in pairs(platform.force.platforms) do
        weight_sum = weight_sum + platform.weight
    end

    if weight_sum > (max_level + 3) * 1000 * 1000 then
        game.print("▣ 仙舟总重量不能超过" .. ((max_level + 3) * 1000) .. "吨")
        for _, info in pairs(event.tiles) do
            surface.set_tiles({ {
                name = info.old_tile,
                position = info.position,
            } })
        end
    end

    if #platform.force.platforms > max_level + 3 then
        game.print("▣ 仙舟不能超过" .. (max_level + 3) .. "艘")
        local platform = platform.force.platforms[max_level + 4]
        if platform then
            local hub = platform.hub
            if hub then
                hub.damage(100000000, "enemy")
            end
        end
    end
end)
