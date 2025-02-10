local map_info = require("script.map_generator")
local ui = require("script.ui")
local level = require("level")


local force_manager = {}

-- 获取宗门出生点
force_manager.get_force_spawn_point = function(index)
    -- 在第几圈
    local circle = 1;
    local count = 0; -- 这一圈出生点数量
    while true do
        count = (circle + 1) * 4;
        if index <= count then
            break;
        end
        index = index - count;
        circle = circle + 1;
    end

    local pos = { x = 0, y = 0 };
    if index <= count / 4 then
        pos.x = -circle - 1 + index;
        pos.y = -circle;
    elseif index <= count / 2 then
        pos.x = circle;
        pos.y = -circle - 1 + index - count / 4;
    elseif index <= count / 4 * 3 then
        pos.x = circle + 1 - (index - count / 4 * 2);
        pos.y = circle;
    else
        pos.x = -circle;
        pos.y = circle + 1 - (index - count / 4 * 3);
    end
    pos.x = pos.x * map_info.size;
    pos.y = pos.y * map_info.size;
    return pos;
end

-- 宗门名是否存在
force_manager.is_force_name_exist = function(name)
    for _, forceInfo in pairs(storage.forceInfos) do
        if forceInfo.name == name then
            return true
        end
    end
    return false
end

-- 获取宗门名称
force_manager.get_force_name = function(force)
    if storage.forceInfos[force.name] then
        return storage.forceInfos[force.name].name
    end
    return force.name
end


-- 增加团队force
SetForceDistance = function(force)
    if storage.force_distance == nil then
        storage.force_distance = 20
    end
    force.character_build_distance_bonus = storage.force_distance
    force.character_item_drop_distance_bonus = storage.force_distance
    force.character_reach_distance_bonus = storage.force_distance
    force.character_resource_reach_distance_bonus = storage.force_distance
    force.character_item_pickup_distance_bonus = storage.force_distance
    force.character_loot_pickup_distance_bonus = storage.force_distance
end


-- 打印离线团队
PrintForce = function()
    local list = {}
    for _, info in pairs(storage.forceInfos) do
        local force = info.force
        local min_offline_m = 0
        for _, player in pairs(force.players) do
            if not player.connected then
                local offline_time = (game.tick - player.last_online) / 60 / 60 / 60
                if min_offline_m == 0 or min_offline_m > offline_time then
                    min_offline_m = offline_time
                end
            else
                min_offline_m = 0
                break
            end
        end
        if min_offline_m > 0 then
            table.insert(list, { info = info, offline_time = min_offline_m })
        end
    end
    table.sort(list, function(a, b) return a.offline_time < b.offline_time end)
    for _, info in pairs(list) do
        game.print(string.format("编号:%d 宗门:%s 离线时间: %.2f小时", info.info.index, info.info.name, info.offline_time))
    end
end

-- 清理空团队
ClearEmptyForce = function()
    for _, force in pairs(game.forces) do
        if storage.forceInfos[force.name] == nil and force.name ~= "player" then
            -- 如果团队名以player_开头，则合并到player
            if force.name:sub(1, 6) == "player" then
                -- 重置并删除该团队
                force.reset()
                game.merge_forces(force, game.forces.player)
                game.print('cleared' .. force.name)
            end
        end
    end
end

-- 创建宗门
force_manager.create_force = function(name, spawn_surface)
    local n = 1
    while true do
        local force_name = "player" .. n
        if game.forces[force_name] == nil then
            break
        end
        n = n + 1
    end

    local force_name = "player" .. n
    local force = game.create_force(force_name)

    -- 禁用重炮
    force.technologies["artillery"].enabled = false
    force.technologies["artillery-shell-damage-1"].enabled = false
    force.technologies["artillery-shell-range-1"].enabled = false
    -- force.technologies["logistic-system"].enabled = false
    -- force.technologies["logistic-system"].visible_when_disabled = true

    force.technologies["atomic-bomb"].enabled = false

    if spawn_surface ~= "nauvis" then
        force.technologies["oil-processing"].researched = true
        force.technologies["advanced-oil-processing"].enabled = true
        force.technologies["space-platform-thruster"].researched = true
    end

    if spawn_surface == "fulgora" then
        force.technologies["planet-discovery-fulgora"].researched = true  -- 发现星球
        force.technologies["advanced-oil-processing"].researched = true   -- 高级石油处理
        force.technologies["electronics"].researched = true               -- 电子学
    elseif spawn_surface == "vulcanus" then
        force.technologies["planet-discovery-vulcanus"].researched = true -- 发现星球
        force.technologies["steel-processing"].researched = true          -- 钢铁冶炼
        force.technologies["oil-gathering"].researched = true             -- 石油采集
        force.technologies["solar-energy"].researched = true              -- 太阳能
        force.technologies["lubricant"].researched = true                 -- 润滑油
        force.technologies["concrete"].researched = true                  -- 混凝土
        force.technologies["advanced-oil-processing"].researched = true   -- 高级石油处理
    elseif spawn_surface == "gleba" then
        force.technologies["planet-discovery-gleba"].researched = true    -- 发现星球
    end

    -- 和player共享图表
    force.share_chart = true
    force.set_friend(game.forces.player, true)
    game.forces.player.set_friend(force, true)
    force.set_cease_fire(game.forces.player, true)
    game.forces.player.set_cease_fire(force, true)


    for _, force_info in pairs(storage.forceInfos) do
        force.set_friend(force_info.force, true)
        force_info.force.set_friend(force, true)
        force.set_cease_fire(force_info.force, true)
        force_info.force.set_cease_fire(force, true)
    end

    local index = 1

    while true do
        local isIndexUsed = false
        for _, forceInfo in pairs(storage.forceInfos) do
            if forceInfo.index == index then
                index = index + 1
                isIndexUsed = true
                break
            end
        end
        if not isIndexUsed then
            break
        end
    end

    local pos = force_manager.get_force_spawn_point(index)

    storage.forceInfos[force_name] = {
        index = index,
        force = force,
        spawn_position = pos,
        technology = 0,
        canJoin = false,
        name = name,
        spawn_surface = spawn_surface,
    }

    force.set_spawn_position(pos, game.surfaces.nauvis)

    if (game.surfaces.fulgora) then
        force.set_spawn_position(pos, game.surfaces.fulgora)
    end

    if (game.surfaces.vulcanus) then
        force.set_spawn_position(pos, game.surfaces.vulcanus)
    end

    if (game.surfaces.gleba) then
        force.set_spawn_position(pos, game.surfaces.gleba)
    end

    if (game.surfaces.aquilo) then
        force.set_spawn_position(pos, game.surfaces.aquilo)
    end

    return force
end

-- 销毁宗门
DF = function(index, no_clear_inside)
    for _, forceInfo in pairs(storage.forceInfos) do
        if forceInfo.index == index then
            force_manager.destroy_force(forceInfo.force, no_clear_inside)
            return
        end
    end
    game.print("宗门编号:" .. index .. " 不存在")
end

-- 销毁宗门
force_manager.destroy_force = function(force, no_clear_inside)
    local name = force_manager.get_force_name(force)
    game.print("宗门 [color=#ffff00]" .. name .. "[/color] 湮灭于 [color=#ff00ff]归墟[/color]")
    -- 宗门玩家改为player宗门
    for _, player in pairs(force.players) do
        -- 关闭已加入玩家界面
        if player.gui.left["joined_team_frame"] then player.gui.left["joined_team_frame"].destroy() end

        game.print("道友 [color=#00ffff]" .. player.name .. "[/color] 转生，未能提升境界")

        -- 创建玩家界面
        ui.create_team_buttons(player)

        -- 清空玩家背包
        if not no_clear_inside then
            player.clear_items_inside()
        end

        player.force = game.forces.player


        -- 位置传送到0,0
        if level.get_index(player) == 1 then
            player.teleport({ 0, 0 }, game.surfaces.nauvis)
        else
            player.teleport({ 0, 0 }, player.surface)
        end
    end

    local respawn_pos = storage.forceInfos[force.name].spawn_position

    -- 回收出生点size/2,size/2范围的地面
    local cs = map_info.size / 32
    local cx = respawn_pos.x / 32 - cs / 2
    local cy = respawn_pos.y / 32 - cs / 2

    for x = cx, cx + cs - 1 do
        for y = cy, cy + cs - 1 do
            local pos = { x = x, y = y }
            game.surfaces.nauvis.delete_chunk(pos)
            if game.surfaces.fulgora then
                game.surfaces.fulgora.delete_chunk(pos)
            end
            if game.surfaces.vulcanus then
                game.surfaces.vulcanus.delete_chunk(pos)
            end
            if game.surfaces.gleba then
                game.surfaces.gleba.delete_chunk(pos)
            end
            if game.surfaces.aquilo then
                game.surfaces.aquilo.delete_chunk(pos)
            end
        end
    end

    storage.forceInfos[force.name] = nil

    for i = 1, #force.platforms do
        local hub = force.platforms[i].hub
        if hub then
            hub.damage(100000000, "enemy")
            -- hub.destroy()
        end
    end

    force.reset()
    game.merge_forces(force, game.forces.player)
end

-- 创建图层时触发
script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]

    if surface.name == "fulgora" or surface.name == "vulcanus" or surface.name == "gleba" or surface.name == "aquilo" then
        for _, forceInfo in pairs(storage.forceInfos) do
            forceInfo.force.set_spawn_position(forceInfo.spawn_position, surface)
        end
    end

    local surface = game.get_surface(event.surface_index)
    if not surface then return end

    local mgs = surface.map_gen_settings
    mgs.seed = math.random(1, 4294967295)

    if surface == game.surfaces.nauvis then
        -- pass
    end

    local mgs = surface.map_gen_settings
    mgs.default_enable_all_autoplace_controls = false
    surface.map_gen_settings = mgs
    local platform = surface.platform
    if platform then
        mgs.width = 256
        mgs.height = 512
    end

    surface.map_gen_settings = mgs
end)


-- 神识感应
local function show_online_player_postion(player_print)
    for _, player in pairs(game.players) do
        if player.connected then
            player_print.print(string.format("[gps=%d,%d,%s] [color=#00ffff]%s[/color]%s", player.position.x,
                player.position.y,
                player.surface.name,
                player.name, player.tag))
        end
    end
end

-- 观星寻舟
local function show_move_platform(player_print)
    for _, surface in pairs(game.surfaces) do
        -- if surface.platform ~= nil and surface.platform.space_location == nil then
        --     player_print.print(string.format("[gps=0,0,%s] %s", surface.name, surface.platform.name))
        -- end
        if surface.platform ~= nil then
            player_print.print(string.format("[gps=0,0,%s] %s", surface.name, surface.platform.name))
        end
    end
end

local random_messages = {
    "※ 采星髓铸玄铁，炼灵脉为产线 ※",
    "※ 以器证道，以厂入圣 ※",
    "※ 筑自动化洞府生产线，开宗立派广纳门众 ※",
    "▣ 天道禁制 ▣ 宗门不得交换物资 ※",
    "▣ 天道禁制 ▣ 宗门不得建设雷达 [entity=radar] ※",
    "〓 [technology=automation-science-pack] 宗门 最长闭关时间为 [color=#ff3333]六个时辰[/color] 〓",
    "〓 [technology=logistic-science-pack] 宗门 最长闭关时间为 [color=#ff3333]一天[/color] 〓",
    "〓 [technology=chemical-science-pack] 宗门 最长闭关时间为 [color=#ff3333]两天[/color] 〓",
    "〓 [technology=space-science-pack] 宗门 最长闭关时间为 [color=#ff3333]三天[/color] 〓",
    "〓 [technology=cryogenic-science-pack] 宗门 最长闭关时间为 [color=#ff3333]五天[/color] 〓",
    "〓 [technology=promethium-science-pack] 宗门 最长闭关时间为 [color=#ff3333]七天[/color] 〓",
    "※ 碎虚空至星域边界者，可献祭宗门进行转生",
    "※ 宗门无人，当坠[color=#ff00ff]归墟[/color]，湮灭于星海",
    "▶ 输入「神识感应」可查诸天同道方位",
    "▶ 输入「观星寻舟」可窥虚空仙舰轨迹",
    "▶ 输入「钓鱼」「伐木」「采矿」「采药」「捕猎」",
}

function print_random_message()
    game.print(random_messages[math.random(#random_messages)])
end

-- 鱼类采集
local fish_locations = {
    "碧波潭", "忘川河", "星海秘境",
    "九幽寒渊", "天河瀑布", "蓬莱仙池",
    "归墟海眼", "瑶池", "弱水河畔",
}

-- 木材采集
local wood_locations = {
    "青冥山", "紫霞岭", "玄雾峰",
    "落星崖", "云梦泽", "栖凤谷",
    "神木林", "建木遗迹", "梧桐仙谷",
    "蟠桃园", "紫竹林", "昆仑墟",
    "扶桑古地", "菩提道场", "太乙仙林"
}

-- 矿石采集
local ore_names = {
    "uranium-ore", "coal", "stone",
    "iron-ore", "copper-ore",
    "tungsten-ore",
    "calcite",
    "holmium-ore",
}
-- 矿石采集
local ore_locations = {
    "玄铁矿脉", "赤铜山洞", "星辰矿洞",
    "九幽冥窟", "天外陨坑", "紫晶山脉",
    "九幽冥窟", "天外陨坑", "紫晶山脉",
    "太初古矿", "归墟深渊", "混沌裂隙"
}

-- 灵药采集
local herb_locations = {
    "百草园", "药王谷", "神农秘境",
    "太虚药田", "九转灵圃", "紫霄药园",
    "归墟药海", "混沌药界", "天机药圃"
}

local herb_names = {
    "yumako", "jellynut", "wood", "spoilage",
}

local treasure_locations = {
    -- 天象异变
    "九星连珠之地", "血月映照之渊", "日蚀中心",
    "流星雨落点", "极光交汇处", "混沌潮汐眼",

    -- 时空异常
    "时间长河支流", "空间裂隙节点", "平行世界入口",
    "轮回隧道", "命运交织点", "因果律异常区"
}

local treasure_names = {
    "scrap", "iron-bacteria", "copper-bacteria", "pentapod-egg", "biter-egg",
    -- "beacon",
    -- "medium-electric-pole",
    -- "productivity-module",
    -- "quality-module",
    -- "efficiency-module",
    -- "qualitspeedy-module",
    -- "electric-mining-drill",
    -- "beacon",
    -- "solar-panel-equipment",
    -- "construction-robot", "logistic-robot",
    -- "solar-panel-equipment",
}

local random_qualities = {
    "normal", "normal", "normal", "uncommon",
    "normal", "normal", "normal", "uncommon",
    "normal", "normal", "normal", "uncommon",
    "normal", "normal", "normal", "uncommon",
    "normal", "normal", "normal", "uncommon",
    "normal", "normal", "normal", "uncommon",
    "rare", "rare", "rare", "epic",
}


local give_item = function(player, name, location, count)
    if not count then count = 1 end
    if not quality then quality = "normal" end
    player.insert { name = name, count = 1 }
    game.print("道友 [color=#00ffff]" .. player.name
        .. "[/color] 于" .. location
        .. "获得[item=" .. name .. ",quality=" .. random_qualities[math.random(#random_qualities)] .. "]")
end

local seed_location = function(locations, seed)
    return locations[math.floor((game.tick / seed)) % #locations + 1]
end

local time_table_shichen = { "子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥" }
local time_table_shike = { "一", "二", "三", "四", "五", "六", "七", "八", }

-- 聊天时触发
script.on_event(defines.events.on_console_chat, function(event)
    -- 跳过命令和系统消息
    if event.message:sub(1, 1) == "/" then return end

    -- 获取玩家信息
    if not event.player_index then return end
    local player = game.get_player(event.player_index)
    if not player then return end

    if player.force == game.forces.player then return end

    local message = event.message

    if message == "闭关" then
        game.kick_player(player, "道友 [color=#00ffff]" .. player.name .. "[/color] 开始闭关修炼")
        return
    end

    if message == "修仙" or message == "帮助" or message == "help" or message == "修仙" then
        print_random_message()
        return
    end

    if message == "神识感应" or message == "在线的人" or message == "玩家" then
        show_online_player_postion(player)
        return
    end

    if message == "观星寻舟" or message == "飞行的船" or message == "平台" then
        show_move_platform(player)
        return
    end

    if message == "钓鱼" then
        local count = math.random(-3, 1)
        if count > 0 then
            give_item(player, 'raw-fish', seed_location(fish_locations, 1230))
        else
            game.print("道友 [color=#00ffff]" .. player.name .. "[/color]一无所获")
        end
        return
    end

    if message == "伐木" or message == "砍树" then
        give_item(player, 'wood', seed_location(wood_locations, 1231))
        return
    end

    if message == "采矿" or message == "采石" or message == "挖矿" then
        give_item(player, ore_names[math.random(#ore_names)], seed_location(ore_locations, 1232))
        return
    end

    if message == "采药" then
        give_item(player, herb_names[math.random(#herb_names)], seed_location(herb_locations, 1233))
        return
    end

    if message == "采药" then
        give_item(player, herb_names[math.random(#herb_names)], seed_location(herb_locations, 1233))
        return
    end

    if message == "捕猎" or message == "捕猎" then
        if not player.force.technologies['biter-egg-handling'].researched then
            player.force.technologies['biter-egg-handling'].researched = true
        end
        give_item(player, treasure_names[math.random(#treasure_names)], seed_location(treasure_locations, 1234))
        return
    end

    if message == "观星" then
        local shichen = math.floor(game.tick / (120 * 60 * 60)) % 12
        local shike = math.floor(game.tick / (15 * 60 * 60)) % 8
        game.print(string.format("%s时%s刻", time_table_shichen[1 + shichen], time_table_shike[1 + shike]))
        return
    end

    -- -- 开头为"速度"时，设置速度
    -- if event.message:sub(1, 6) == "速度" then
    --     local speed = tonumber(event.message:sub(7))
    --     if speed ~= nil then
    --         if speed < 0 then
    --             speed = 0
    --         end

    --         local index = level.get_index(player)
    --         local max_speed = index * 110
    --         if speed > max_speed then
    --             speed = max_speed
    --         end
    --         if storage.speed_set == nil then
    --             storage.speed_set = {}
    --         end
    --         storage.speed_set[player.name] = level.get_speed(speed) / 60
    --         player.print(string.format("道友 [color=#00ffff]%s[/color] %s设置所在仙舟速度为%.2fkm/s", player.name, player.tag, speed))
    --     end
    -- end

    -- 自定义消息格式
    local force_name = force_manager.get_force_name(player.force)
    local custom_message = string.format("[color=#ffff00]%s[/color] [color=#00ffff]%s[/color]%s 说 %s", force_name,
        player.name, player.tag, event.message)

    -- 广播自定义消息给所有其他宗门和player
    for _, forceInfo in pairs(storage.forceInfos) do
        if forceInfo.force.name ~= player.force.name then
            forceInfo.force.print(custom_message, { color = player.color })
        end
    end

    -- 广播自定义消息给player
    if player.force.name ~= game.forces.player.name then
        game.forces.player.print(custom_message, { color = player.color })
    end
end)


-- 回收地块
DC = function()
    local surface_names = { "nauvis", "fulgora", "vulcanus", "gleba", "aquilo" }
    if storage.dc_list == nil then
        storage.dc_list = {}
    end
    for _, surface_name in pairs(surface_names) do
        local surface = game.surfaces[surface_name]
        if surface then
            for chunk in surface.get_chunks() do
                table.insert(storage.dc_list, { chunk = chunk, surface = surface.name })
            end
        end
    end
    game.print(string.format("▣ 计划回收地块数量: %d ▣", #storage.dc_list))
end

-- 清空神游记录
ClearSpeedRank = function()
    for _, speed_rank in pairs(storage.speed_rank) do
        for key, planet_data in pairs(speed_rank) do
            if type(planet_data) == "table" then
                speed_rank[key] = nil
            end
        end
    end
end

-- 删除离线时长超过100小时的玩家
DeleteOfflinePlayer = function()
    for _, player in pairs(game.players) do
        if not player.connected then
            if player.last_online < game.tick - 100 * 60 * 60 * 60 then
                game.remove_offline_players({ player })
            end
        end
    end
end

-- 获取星球之间的距离
local function get_distance(start_planet, target_planet)
    if start_planet == "shattered-planet" or target_planet == "shattered-planet" then
        return { distance = 4000000, name = "shattered-planet" }
    elseif start_planet == "solar-system-edge" or target_planet == "solar-system-edge" then
        return { distance = 100000, name = "solar-system-edge" }
    elseif start_planet == "aquilo" or target_planet == "aquilo" then
        return { distance = 30000, name = "aquilo" }
    else
        return { distance = 15000, name = "nauvis" }
    end
end

local function max_min_left_of(force)
    local max_offline_m = 1

    if force.technologies["promethium-science-pack"].researched then
        max_offline_m = 24 * 7
    elseif force.technologies["cryogenic-science-pack"].researched then
        max_offline_m = 24 * 5
    elseif force.technologies["space-science-pack"].researched then
        max_offline_m = 24 * 3
    elseif force.technologies["chemical-science-pack"].researched then
        max_offline_m = 24 * 2
    elseif force.technologies["logistic-science-pack"].researched then
        max_offline_m = 24
    elseif force.technologies["automation-science-pack"].researched then
        max_offline_m = 12
    else
        max_offline_m = 6
    end
    return max_offline_m * 60
end

function NotifyForce(info, time_str)
    local name = force_manager.get_force_name(info)
    if not info.canJoin then
        game.print(string.format("宗门 [color=#ffff00]%s[/color] 开始招收弟子", name))
        info.canJoin = true
        for _, p in pairs(info.force.players) do
            if p.gui.left["joined_team_frame"] then
                p.gui.left["joined_team_frame"]["allow_join_checkbox"].state = true
            end
        end
    end
    game.print(string.format("宗门 [color=#ffff00]%s[/color] 仅剩 [color=#ff3333]%s[/color]", name, time_str))
end

-- 每帧调用
script.on_event(defines.events.on_tick, function(event)
    local minute = 60 * 60
    local hour = minute * 60

    if event.tick % hour == 0 then
        DeleteOfflinePlayer()
        game.reset_time_played()
    end

    local ratio = storage.delete_force_time_ratio
    if not ratio then ratio = 1 end

    if event.tick % minute == 0 and ratio > 0 then
        for _, info in pairs(storage.forceInfos) do
            local force = info.force

            local min_offline_m = 0

            for _, player in pairs(force.players) do
                if not player.connected then
                    local offline_m = math.floor((game.tick - player.last_online) / minute / ratio)

                    if min_offline_m == 0 or min_offline_m > offline_m then
                        min_offline_m = offline_m
                    end
                else
                    min_offline_m = 0
                    break
                end
            end

            if min_offline_m == 0 then goto continue end


            local m_left = max_min_left_of(force) - min_offline_m

            if m_left == 24 * 60 then
                NotifyForce(info, "十二时辰")
            elseif m_left == 12 * 60 then
                NotifyForce(info, "六个时辰")
            elseif m_left == 6 * 60 then
                NotifyForce(info, "三个时辰")
            elseif m_left == 2 * 60 then
                NotifyForce(info, "一个时辰")
            elseif m_left == 1 * 60 then
                NotifyForce(info, "半个时辰")
            elseif m_left == 30 then
                NotifyForce(info, "一炷香")
            elseif m_left == 15 then
                NotifyForce(info, "一刻钟")
            elseif m_left == 1 then
                NotifyForce(info, "一分钟")
            end

            if m_left <= 0 then
                DF(info.index)
            end
            ::continue::
        end
    end

    -- 回收地块
    if storage.dc_list ~= nil and #storage.dc_list > 0 then
        if event.tick % 600 == 0 then
            game.print(string.format("▣ 剩余回收地块数量: %d", #storage.dc_list))
        end
        local info = storage.dc_list[1]
        local chunk = info.chunk
        local surface = game.surfaces[info.surface]

        local force = nil
        for _, forceInfo in pairs(storage.forceInfos) do
            local respawn_pos = forceInfo.spawn_position
            local cx = respawn_pos.x / 32
            local cy = respawn_pos.y / 32
            local d = map_info.size / 64
            if chunk.x >= cx - d and chunk.x < cx + d and chunk.y >= cy - d and chunk.y < cy + d then
                force = forceInfo.force
                break
            end
        end
        if force == nil then
            surface.delete_chunk(chunk)
        else
            -- 检测该区域是否有该宗门的实体
            local entities = surface.find_entities_filtered({
                area = { { chunk.x * 32, chunk.y * 32 }, { chunk.x * 32 + 32, chunk.y * 32 + 32 } },
                force =
                    force.name,
                limit = 1
            })

            -- 如果没有实体，则删除该区域
            if #entities == 0 then
                surface.delete_chunk(chunk)
            end
        end


        table.remove(storage.dc_list, 1)
    end


    if event.tick % 360 ~= 0 then
        return
    end

    -- 遍历在线玩家
    for _, player in pairs(game.connected_players) do
        if player.character ~= nil and player.character.surface.platform ~= nil then
            -- 如果玩家在仙舟上
            local platform = player.character.surface.platform

            if platform.space_location ~= nil then -- 停靠 [planet=nauvis]
                if storage.speed_rank == nil then
                    storage.speed_rank = {}
                end
                if storage.speed_rank[player.name] == nil then
                    storage.speed_rank[player.name] = {}
                end
                if storage.speed_rank[player.name].start_planet == nil then
                    storage.speed_rank[player.name].start_planet = platform.space_location.name
                elseif storage.speed_rank[player.name].start_planet ~= platform.space_location.name then
                    if storage.speed_rank[player.name] ~= nil and storage.speed_rank[player.name].weight ~= nil then
                        local start_planet = storage.speed_rank[player.name].start_planet
                        local target_planet = platform.space_location.name
                        local time = (game.tick - storage.speed_rank[player.name].start_time) / 60 -- 秒
                        local weight = storage.speed_rank[player.name].weight / 1000               -- 吨
                        if time > 2 and weight > 10 then
                            local info = get_distance(start_planet, target_planet)                 -- km
                            local distance = info.distance
                            local name = info.name
                            local socre = distance * distance / time / weight -- 分
                            if storage.speed_rank[player.name][name] == nil or storage.speed_rank[player.name][name].socre < socre then
                                storage.speed_rank[player.name][name] = {
                                    time = time,
                                    weight = weight,
                                    socre = socre,
                                    distance = distance,
                                }
                                game.print(string.format(
                                    "[color=#00ffff]%s[/color]%s突破了神游[space-location=%s]分数记录(%d), 前往神游榜查看", player
                                    .name, player.tag, name, socre))
                            end
                            if storage.speed_rank[player.name][name].min_time == nil or storage.speed_rank[player.name][name].min_time.time > time then
                                storage.speed_rank[player.name][name].min_time = {
                                    time = time,
                                    weight = weight,
                                    socre = socre,
                                    distance = distance,
                                }
                                game.print(string.format(
                                    "[color=#00ffff]%s[/color]%s突破了神游[space-location=%s]速度记录(%.2fkm/s), 前往神游榜查看",
                                    player.name, player.tag, name, distance / time))
                            end
                            if storage.speed_rank[player.name][name].min_weight == nil or storage.speed_rank[player.name][name].min_weight.weight > weight then
                                storage.speed_rank[player.name][name].min_weight = {
                                    time = time,
                                    weight = weight,
                                    socre = socre,
                                    distance = distance,
                                }
                                game.print(string.format(
                                    "[color=#00ffff]%s[/color]%s突破了神游[space-location=%s]重量记录(%.1f吨), 前往神游榜查看",
                                    player.name, player.tag, name, weight))
                            end

                            player.print(string.format("神游[space-location=%s]分数:%d,重量:%.1f吨,速度:%.2fkm/s", name, socre,
                                weight, distance / time))

                            -- if platform.space_location.name == "shattered-planet" then
                            --     if storage.speed_rank[player.name].try_time == nil then
                            --         storage.speed_rank[player.name].try_time = 0
                            --     end
                            --     storage.speed_rank[player.name].try_time = storage.speed_rank[player.name].try_time +
                            --         1;
                            --     game.print(string.format("%s%s到达破碎星球，下次速度要求降低50km/s", player.name, player.tag));
                            -- end

                            storage.speed_rank[player.name].curr_time = time -- 最近一次耗时
                            storage.speed_rank[player.name].start_planet = target_planet
                        end
                    end
                end
                storage.speed_rank[player.name].start_time = game.tick
                storage.speed_rank[player.name].weight = 0
            else -- 飞行
                -- 环境速度变化
                if storage.speed_set == nil then
                    storage.speed_set = {}
                end
                if storage.speed_set[player.name] == nil then
                    storage.speed_set[player.name] = 0
                end

                if storage.speed_set[player.name] > 0 and platform.speed > 0 then
                    platform.speed = storage.speed_set[player.name]
                end

                -- 更新船重
                if storage.speed_rank and storage.speed_rank[player.name] then
                    if storage.speed_rank[player.name].weight == nil then
                        storage.speed_rank[player.name].weight = platform.weight
                    elseif platform.weight > storage.speed_rank[player.name].weight then
                        storage.speed_rank[player.name].weight = platform.weight
                    end
                end
            end
        end
    end
end)


-- 检测是否为雷达
local function is_radar(entity)
    if entity.name == "radar" then
        game.print(string.format("▣ 禁止创建[item=radar][gps=%d,%d,%s] ▣", entity.position.x, entity.position.y,
            entity.surface.name))
        -- 创建一个爆炸
        entity.surface.create_entity({
            name = "explosion",
            position = entity.position,
        })
        entity.destroy()
    end
end

-- 检测是否在自己区域
local function is_in_force_area(entity)
    if not entity.valid then return true end
    local check_surfaces = { "nauvis", "fulgora", "vulcanus", "gleba", "aquilo" }
    local is_check = false
    for _, surface_name in pairs(check_surfaces) do
        if entity.surface.name == surface_name then
            is_check = true
            break
        end
    end
    if not is_check then
        return true
    end

    local force = entity.force
    local forceInfo = storage.forceInfos[force.name]
    if forceInfo then
        local respawn_pos = forceInfo.spawn_position
        if entity.position.x >= respawn_pos.x - map_info.size / 2 and entity.position.x < respawn_pos.x + map_info.size / 2 and entity.position.y >= respawn_pos.y - map_info.size / 2 and entity.position.y < respawn_pos.y + map_info.size / 2 then
            return true
        end
    end
    return false
end

-- 机器人创建时调用
script.on_event(defines.events.on_robot_built_entity, function(event)
    local entity = event.entity
    is_radar(entity)
    if not is_in_force_area(entity) then
        entity.destroy()
    end
end)

-- 创建实体时调用
script.on_event(defines.events.on_built_entity, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local entity = event.entity
    is_radar(entity)
    if not is_in_force_area(entity) then
        game.print("▣ 不能在此区域创建实体 ▣" .. player.name)
        entity.destroy()
    end
end)


-- 获取队伍最高境界
local function get_max_level(force)
    local max_level = 0
    for _, player in pairs(force.players) do
        local index = level.get_index(player)
        if index > max_level then
            max_level = index
        end
    end
    return max_level
end


-- 玩家移动时调用
script.on_event(defines.events.on_player_changed_position, function(event)
    local player = game.get_player(event.player_index)


    if not player or not player.character then return end
    if player.controller_type ~= defines.controllers.character then return end          -- 不是玩家
    if player.physical_controller_type ~= defines.controllers.character then return end -- 不是玩家

    -- 检查玩家包裹是否为空或者只有1个物品(穿了衣服)
    if player.get_item_count() <= 1 then
        return
    end

    if not is_in_force_area(player.character) then
        local force_info = storage.forceInfos[player.force.name]
        if force_info then
            player.print("▣ 你已离开宗门区域，将被传送回宗门出生点 ▣")
            player.teleport(force_info.spawn_position, player.surface)
        end
    end
end)

-- todo : 蓝图覆盖修改他人
-- 监听蓝图创建事件
script.on_event(defines.events.on_player_setup_blueprint, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    -- 获取蓝图实体
    local blueprint = player.blueprint_to_setup
    if not blueprint or not blueprint.valid_for_read then
        blueprint = player.cursor_stack
    end
    if not blueprint or not blueprint.valid_for_read then return end

    -- 获取选择的区域内的实体
    local entities = event.mapping.get()
    if not entities then return end

    -- 检查是否包含其他势力的建筑
    for _, entity in pairs(entities) do
        if entity.valid and entity.force ~= player.force then
            -- 清空蓝图
            blueprint.clear_blueprint()
            -- 提示玩家
            game.print(string.format("▣ 不能复制其他宗门的建筑作为蓝图[gps=%d,%d,%s] ▣ %s", entity.position.x, entity.position.y,
                entity.surface.name, player.name))
            return
        end
    end
end)

-- 监听玩家旋转建筑事件
script.on_event(defines.events.on_player_rotated_entity, function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity

    if player and entity and entity.valid then
        -- 检查是否为其他势力的建筑
        if entity.force ~= player.force then
            -- 还原旋转（向反方向旋转回去）
            if event.previous_direction then
                entity.direction = event.previous_direction
            end
            -- 提示玩家
            game.print(string.format("▣ 不能旋转其他宗门的建筑[gps=%d,%d,%s] ▣ %s", entity.position.x, entity.position.y,
                entity.surface.name, player.name))
        end
    end
end)


-- 监听玩家打开GUI事件
script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    -- 检查打开的是否为实体GUI
    if event.gui_type == defines.gui_type.entity then
        local entity = event.entity
        -- 检查实体是否有效且不属于玩家势力
        if entity and entity.valid and entity.force ~= player.force then
            -- 关闭GUI
            player.opened = nil
            -- 提示玩家
            game.print(string.format("▣ 不能查看或修改其他宗门的建筑[gps=%d,%d,%s] ▣ %s", entity.position.x, entity.position.y,
                entity.surface.name, player.name))
        end
    end
end)

-- 监听玩家复制实体设置事件
script.on_event(defines.events.on_entity_settings_pasted, function(event)
    local player = game.get_player(event.player_index)
    local source = event.source           -- 复制源
    local destination = event.destination -- 粘贴目标

    if player and destination and destination.valid then
        -- 检查目标实体是否属于其他势力
        if destination.force ~= player.force then
            -- 提示玩家
            game.print(string.format("▣ 不能通过复制设置修改其他宗门设施[gps=%d,%d,%s] ▣ %s", destination.position.x,
                destination.position.y,
                destination.surface.name, player.name))
            game.print(string.format("▣ %s已被杀死，大家不要学他 ▣", player.name))
            -- 杀死这样操作的玩家
            player.character.die()
        end
    end
end)


return force_manager
