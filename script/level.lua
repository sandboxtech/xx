local level_names = {
    [1] = "练气期",
    [2] = "筑基期",
    [3] = "金丹期",
    [4] = "元婴期",
    [5] = "化神期",
    [6] = "炼虚期",
    [7] = "合体期",
    [8] = "大乘期",
    [9] = "渡劫期",
    [10] = "天仙境",
    [11] = "真仙境",
    [12] = "玄仙境",
    [13] = "金仙境",
    [14] = "仙君境",
    [15] = "仙尊境",
    [16] = "仙帝境",
}

local level = {}


-- 获取速度
function level.get_speed(x)
    return 5.88833087401084e-17 * x ^ 5 - 2.541740012068197e-13 * x ^ 4 + 2.920373801024497e-09 * x ^ 3 +
    2.763087085005191e-05 * x ^ 2 + 1.0033589971980925 * x
end

function level.get_index(player)
    if storage.levels == nil then
        storage.levels = {}
    end
    local index = storage.levels[player.name]
    if index == nil then
        index = 1
    end
    return index
end

-- 是提升道具是否确认
function level.is_confirm(player)
    if storage.up_level_item == nil then
        storage.up_level_item = {}
    end
    return storage.up_level_item[player.name] ~= nil
end

-- 清理
function ClearUpItem()
    for _, player in pairs(game.players) do
        storage.up_level_item[player.name] = nil
    end
end

-- 获取境界提升所需道具
function level.get_items(player)
    if storage.up_level_item[player.name] ~= nil then
        return storage.up_level_item[player.name]
    end

    local up_level_item = {}
    local index = level.get_index(player)
    local count = (index + 1) * index / 2

    local items = {}
    for name, item in pairs(prototypes.item) do
        if item.valid and not item.hidden and not item.flags and not item.spoil_result
            and player.force.recipes[item.name] and player.force.recipes[item.name].enabled == true
            and item.group.name ~= "other" and item.subgroup.name ~= "space-material" then
            table.insert(items, name)
        end
    end

    for _ = 1, count do
        local rand_item = math.random(1, #items)
        local name = items[rand_item]

        if up_level_item[name] == nil then
            up_level_item[name] = 0
        end
        up_level_item[name] = up_level_item[name] + 10
    end

    storage.up_level_item[player.name] = up_level_item
    return up_level_item
end

local get_name = function(index, isbracket)
    local colors = { -- 白绿蓝紫橙红粉金
        [1] = "#ffffff",
        [2] = "#00ff00",
        [3] = "#00BFFF",
        [4] = "#ff00ff",
        [5] = "#ffa500",
        [6] = "#ff0000",
        [7] = "#ffc0cb",
        [8] = "#ffd700",
    }

    local name = ""
    local color = ""
    if index > 16 then
        color = colors[8]
        if isbracket then
            name = "[font=default-large-bold][color=" .. color .. "]仙帝" .. (index - 16) .. "重境[/color][/font]"
        else
            name = "[font=default-large-bold][color=" .. color .. "][仙帝" .. (index - 16) .. "重境][/color][/font]"
        end
    else
        color = colors[math.floor((index + 1) / 2)]
        name = level_names[index]
        if isbracket then
            name = "[color=" .. color .. "][" .. name .. "][/color]"
        else
            name = "[color=" .. color .. "]" .. name .. "[/color]"
        end
        if index % 2 == 0 then
            name = "[font=default-bold]" .. name .. "[/font]"
        end
    end

    return name
end

function level.get_name(player, isbracket)
    local index = level.get_index(player)
    return get_name(index, isbracket)
end

function GN(index, isbracket)
    game.print(get_name(index, isbracket))
end

-- 记录玩家重生 surface_name次数
function level.record_spawn_surface_count(player, surface_name)
    if storage.spawn_surface_count == nil then
        storage.spawn_surface_count = {}
    end
    if storage.spawn_surface_count[player.name] == nil then
        storage.spawn_surface_count[player.name] = {}
    end
    if storage.spawn_surface_count[player.name][surface_name] == nil then
        storage.spawn_surface_count[player.name][surface_name] = 0
    end
    storage.spawn_surface_count[player.name][surface_name] = storage.spawn_surface_count[player.name][surface_name] + 1
end

-- 获取玩家重生 surface_name次数
function level.get_spawn_surface_count(player, surface_name)
    if storage.spawn_surface_count == nil then
        storage.spawn_surface_count = {}
    end
    return (storage.spawn_surface_count[player.name] and storage.spawn_surface_count[player.name][surface_name]) or 0
end

-- 根据surface_name次数设置对应星球的产能科技等级
function level.set_tech_level(player)
    local nauvis_count = level.get_spawn_surface_count(player, "nauvis")
    local fulgora_count = level.get_spawn_surface_count(player, "fulgora")
    local vulcanus_count = level.get_spawn_surface_count(player, "vulcanus")
    local gleba_count = level.get_spawn_surface_count(player, "gleba")

    local force = player.force


    local index = level.get_index(player)
    if (index > 1) then
        game.print(string.format("%s当前境界:%s", player.name, level.get_name(player, true)))
        force.technologies["research-productivity"].level = index
        game.print(string.format("[technology=research-productivity]自动解锁%d次\n", index - 1))
    end

    if nauvis_count > 0 then
        local count = nauvis_count * 2
        force.technologies["mining-productivity-3"].level = count + 3
        force.technologies["steel-plate-productivity"].level = count + 1
        game.print(string.format("%s在[planet=nauvis]重生%d次", player.name, nauvis_count))
        game.print(string.format("[technology=mining-productivity-3]自动解锁%d次", count))
        game.print(string.format("[technology=steel-plate-productivity]自动解锁%d次\n", count))
    end

    if fulgora_count > 0 then
        local count = fulgora_count * 2
        force.technologies["processing-unit-productivity"].level = count + 1
        force.technologies["scrap-recycling-productivity"].level = count + 1
        game.print(string.format("%s在[planet=fulgora]重生%d次", player.name, fulgora_count))
        game.print(string.format("[technology=processing-unit-productivity]自动解锁%d次", count))
        game.print(string.format("[technology=scrap-recycling-productivity]自动解锁%d次\n", count))
    end

    if vulcanus_count > 0 then
        local count = vulcanus_count * 2
        force.technologies["low-density-structure-productivity"].level = count + 1
        game.print(string.format("%s在[planet=vulcanus]重生%d次", player.name, vulcanus_count))
        game.print(string.format("[technology=low-density-structure-productivity]自动解锁%d次\n", count))
    end

    if gleba_count > 0 then
        local count = gleba_count * 2
        force.technologies["rocket-fuel-productivity"].level = count + 1
        force.technologies["plastic-bar-productivity"].level = count + 1
        force.technologies["asteroid-productivity"].level = count + 1
        game.print(string.format("%s在[planet=gleba]重生%d次", player.name, gleba_count))
        game.print(string.format("[technology=rocket-fuel-productivity]自动解锁%d次", count))
        game.print(string.format("[technology=plastic-bar-productivity]自动解锁%d次", count))
        game.print(string.format("[technology=asteroid-productivity]自动解锁%d次", count))
    end
end

-- 提升境界
function level.up(player)
    local index = level.get_index(player)
    local count = index
    if count > 10 then
        count = 10
    end

    local trash = player.surface.platform.hub.get_inventory(defines.inventory.hub_trash)


    local spawn_surface = storage.forceInfos[player.force.name].spawn_surface


    player.force = game.forces.player

    -- 备选地面
    local pre_surface_names = { "nauvis", "fulgora", "vulcanus", "gleba" }


    local surface_names = {}

    for _, name in pairs(pre_surface_names) do
        if name ~= spawn_surface then
            table.insert(surface_names, name)
        end
    end


    -- 随机一个地面(和上次不一样)
    local surface_name = surface_names[math.random(1, #surface_names)]

    -- 传送到新地球出生点
    player.character.teleport({ 0, 0 }, game.surfaces[surface_name])

    -- 记录玩家重生 surface_name
    level.record_spawn_surface_count(player, surface_name)

    -- 将trash的前count格物品插入玩家背包
    for i = 1, count do
        if trash[i].valid_for_read then
            -- 获取物品堆栈
            local stack = trash[i]
            -- 将物品插入玩家背包
            player.insert(stack)
        end
    end
    storage.speed_rank[player.name].add = nil
    storage.speed_rank[player.name].try_time = 0
    storage.up_level_item[player.name] = nil
    storage.levels[player.name] = index + 1
    player.tag = level.get_name(player, true)

    storage.speed_rank[player.name].start_planet = nil -- 清除起点
    game.print(string.format("恭喜 %s 突破至 %s[gps=%d,%d,%s]", player.name, level.get_name(player, true), player.position.x,
        player.position.y, surface_name))
end

return level
