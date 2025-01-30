local size = 192
local map_info = {
    size = size
}

-- 通用创建水
local function create_water(surface, x, y, mx, my, water_name, fish, water_size)
    if mx < water_size or mx > size - 65 - water_size or my < water_size or my > size - 65 - water_size then
        surface.set_tiles({ {
            name = water_name,
            position = { x, y },
        } })
        if fish then fish(x, y, surface) end
        return true
    end
    return false
end

-- 通用创建地格
local function create_tile(surface, x, y, mx, my, tile_name, tile2_name)
    local name = tile_name
    if tile2_name and mx < size / 2 - 32 then
        name = tile2_name
    end

    -- 摧毁当前位置的悬崖
    local cliffs = surface.find_entities_filtered {
        position = { x, y },
        type = "cliff"
    }
    for _, cliff in pairs(cliffs) do
        if cliff.valid then
            cliff.destroy()
        end
    end

    surface.set_tiles({ {
        name = name,
        position = { x, y }
    } })
end

-- 通用油田生成
local function create_oil_field(surface, x, y, mx, my, name)
    if (mx > 2 and mx < size - 65 and (mx - 1) % 3 == 0 and (my == 2 or my == size - 67)) or
        (my > 2 and my < size - 65 and (my - 1) % 3 == 0 and (mx == 2 or mx == size - 67)) then
        surface.create_entity({
            name = name,
            position = { x, y },
            amount = 3000000000,
        })
    end
end

-- 通用生成岩石
local function create_rock(surface, x, y, mx, my, name, name2, distance)
    local dy = 0;
    if name2 then
        dy = 2
        if ((mx > 15 and mx < size / 2 - 35 - distance) or (mx > size / 2 - 29 + distance and mx < size - 80)) and mx % (6 + distance) == 0 then
            if surface.name == "gleba" or surface.name == "vulcanus" then
                if my > size / 2 - 32 and my % 4 == 0 then
                    surface.create_entity({
                        name = name2,
                        position = { x, y },
                    })
                end
            else
                if my == size / 2 - 32 - dy then
                    surface.create_entity({
                        name = name2,
                        position = { x, y },
                    })
                end
            end
        end
    end
    if ((mx > 15 and mx < size / 2 - 35 - distance) or (mx > size / 2 - 29 + distance and mx < size - 80)) and mx % (6 + distance) == 0 then
        if surface.name == "gleba" or surface.name == "vulcanus" then
            if my < size / 2 - 32 and my % 4 == 0 then
                surface.create_entity({
                    name = name,
                    position = { x, y },
                })
            end
        else
            if my == size / 2 - 32 + dy then
                surface.create_entity({
                    name = name,
                    position = { x, y },
                })
            end
        end
    end
end

-- 通用生成植物
local function create_plant(surface, x, y, mx, my, name, name2)
    local dx = 0;
    if name2 then
        if ((my > 15 and my < size / 2 - 35) or (my > size / 2 - 29 and my < size - 80)) then
            if mx < size / 2 - 33 and mx % 4 == 0 then
                surface.create_entity({
                    name = name2,
                    position = { x, y },
                })
            elseif mx > size / 2 - 31 and mx % 4 == 0 then
                surface.create_entity({
                    name = name,
                    position = { x, y },
                })
            end
        end
    elseif (mx == size / 2 - 33 or mx == size / 2 - 31) and ((my > 15 and my < size / 2 - 35) or (my > size / 2 - 29 and my < size - 80)) then
        surface.create_entity({
            name = name,
            position = { x, y },
        })
    end
end


-- 新地球生成鱼
local function create_fish(x, y, surface)
    surface.create_entity({
        name = "fish",
        position = { x, y },
    })
end

-- 新地球生成矿物
local function nauvis_create_ore(surface, x, y, mx, my)
    if mx >= (size - 64) / 4 and mx < (size - 64) * 3 / 4 and my >= (size - 64) / 8 and my < (size - 64) / 4 then
        surface.create_entity({
            name = "uranium-ore",
            position = { x, y },
            amount = 1000000000,
        })
    elseif mx >= (size - 64) / 4 and mx < size / 2 - 32 and my >= (size - 64) / 4 and my < size / 2 - 32 then
        surface.create_entity({
            name = "coal",
            position = { x, y },
            amount = 1000000000,
        })
    elseif mx >= size / 2 - 32 and mx < (size - 64) * 3 / 4 and my >= (size - 64) / 4 and my < size / 2 - 32 then
        surface.create_entity({
            name = "stone",
            position = { x, y },
            amount = 1000000000,
        })
    elseif mx >= (size - 64) / 4 and mx < size / 2 - 32 and my >= size / 2 - 32 and my < (size - 64) * 3 / 4 then
        surface.create_entity({
            name = "iron-ore",
            position = { x, y },
            amount = 1000000000,
        })
    elseif mx >= size / 2 - 32 and mx < (size - 64) * 3 / 4 and my >= size / 2 - 32 and my < (size - 64) * 3 / 4 then
        surface.create_entity({
            name = "copper-ore",
            position = { x, y },
            amount = 1000000000,
        })
    end
end

-- 新地球生成虫巢
local function nauvis_create_spwaner(surface, x, y, mx, my)
    if (mx > 10 and mx < size - 76 and (mx - 1) % 7 == 0 and (my == 7 or my == size - 72)) or
        (my > 10 and my < size - 76 and (my - 1) % 7 == 0 and (mx == 7 or mx == size - 72)) then
        local name = "biter-spawner"
        if mx == 7 or mx == size - 72 then name = "spitter-spawner" end
        surface.create_entity({
            name = name,
            position = { x, y },
        })
    end
end

-- 雷神星球生成矿物
local function fulgora_create_ore(surface, x, y, mx, my)
    if mx >= (size - 64) / 3 and mx < (size - 64) * 2 / 3 and my >= (size - 64) / 3 and my < (size - 64) * 2 / 3 then
        surface.create_entity({
            name = "scrap",
            position = { x, y },
            amount = 1000000000,
        })
    end
end

-- 雷神星特产
local function fulgora_create_specical(surface, x, y, mx, my)
    if mx >= 20 and mx <= size - 84 and my >= 20 and my <= size - 84 and (mx + 12) % 40 == 0 and (my + 12) % 40 == 0 then
        surface.create_entity({
            name = "fulgoran-ruin-attractor",
            position = { x, y },
            force = "player",
        })
    end
end

-- 祝融星特产
local function vulcanus_create_specical(surface, x, y, mx, my)
    if mx >= 20 and mx <= size - 84 and my >= 20 and my <= size - 84 and (mx + 12) % 40 == 0 and (my + 12) % 40 == 0 then
        surface.create_entity({
            name = "vulcanus-chimney",
            position = { x, y },
        })
    end
end

-- 祝融星矿物生成
local function vulcanus_create_ore(surface, x, y, mx, my)
    if mx >= (size - 64) / 4 and mx < size / 2 - 32 and my >= (size - 64) / 4 and my < size / 2 - 32 then
        surface.create_entity({
            name = "tungsten-ore",
            position = { x, y },
            amount = 1000000000,
        })
    elseif mx >= size / 2 - 32 and mx < (size - 64) * 3 / 4 and my >= (size - 64) / 4 and my < size / 2 - 32 then
        surface.create_entity({
            name = "calcite",
            position = { x, y },
            amount = 1000000000,
        })
    elseif mx >= (size - 64) / 4 and mx < (size - 64) * 3 / 4 and my >= size / 2 - 32 and my < (size - 64) * 5 / 8 then
        surface.create_entity({
            name = "coal",
            position = { x, y },
            amount = 1000000000,
        })
    end
end

-- 巨芒星生成虫巢
local function gleba_create_spwaner(surface, x, y, mx, my)
    if (mx > 0 and mx < size - 76 and (mx + 3) % 7 == 0 and (my == 4 or my == size - 68)) or
        (my > 0 and my < size - 76 and (my + 3) % 7 == 0 and (mx == 4 or mx == size - 68)) then
        local name = "gleba-spawner"
        surface.create_entity({
            name = name,
            position = { x, y },
        })
    end

    -- 珊瑚
    if (mx > 10 and mx < size - 80 and (mx + 6) % 4 == 0 and (my == 10 or my == size - 74)) or
        (my > 10 and my < size - 80 and (my + 6) % 4 == 0 and (mx == 10 or mx == size - 74)) then
        local name = "slipstack"
        surface.create_entity({
            name = name,
            position = { x, y },
        })
    end
end

-- 巨芒星矿物生成
local function gleba_create_ore(surface, x, y, mx, my)
    if mx >= (size - 64) / 3 and mx < (size - 64) * 2 / 3 and my >= (size - 64) / 3 and my < (size - 64) * 2 / 3 then
        surface.create_entity({
            name = "stone",
            position = { x, y },
            amount = 1000000000,
        })
    end
end

-- 玄冥星矿物生成
local function aquilo_create_ore(surface, x, y, mx, my)
    if (mx > 35 and mx < size - 100 and (mx - 1) % 3 == 0 and my == 34) then
        surface.create_entity({
            name = "crude-oil",
            position = { x, y },
            amount = 3000000000,
        })
    end
    if (my > 35 and my < size - 100 and (my - 1) % 3 == 0 and mx == 34) then
        surface.create_entity({
            name = "lithium-brine",
            position = { x, y },
            amount = 3000000000,
        })
    end
    if (my > 35 and my < size - 100 and (my - 1) % 3 == 0 and mx == size - 99) then
        surface.create_entity({
            name = "fluorine-vent",
            position = { x, y },
            amount = 3000000000,
        })
    end
end

local create_info = {
    ["nauvis"] = { -- 新地球
        water_size = 1,
        tile = "dirt-1",
        water = "water",
        fish = create_fish,
        oil = "crude-oil",
        ore = nauvis_create_ore,
        spwaner = nauvis_create_spwaner,
        rock = "huge-rock",
        plant = "tree-09-red",
    },
    ["fulgora"] = { -- 雷神星
        water_size = 1,
        tile = "volcanic-ash-soil",
        water = "oil-ocean-shallow",
        ore = fulgora_create_ore,
        rock = "fulgoran-ruin-vault",
        rock_distance = 12,
        plant = "fulgurite",
        special = fulgora_create_specical,
    },
    ["vulcanus"] = { -- 祝融星
        water_size = 1,
        tile = "volcanic-smooth-stone",
        water = "lava",
        oil = "sulfuric-acid-geyser",
        ore = vulcanus_create_ore,
        rock = "big-volcanic-rock",
        rock2 = "big-volcanic-rock",
        plant = "ashland-lichen-tree",
        special = vulcanus_create_specical,
    },
    ["gleba"] = { -- 巨芒星
        water_size = 16,
        water = "wetland-blue-slime",
        tile = "natural-yumako-soil",
        tile2 = "natural-jellynut-soil",
        ore = gleba_create_ore,
        water_spwaner = gleba_create_spwaner,
        rock = "copper-stromatolite",
        rock2 = "iron-stromatolite",
        plant = "yumako-tree",
        plant2 = "jellystem"
    },
    ["aquilo"] = { -- 玄冥星
        water_size = 32,
        tile = "dust-flat",
        water = "ammoniacal-ocean",
        ore = aquilo_create_ore,
        rock = "lithium-iceberg-big",
        rock2 = "lithium-iceberg-big",
    },
}



-- 创建地面
local function create_ground(x, y, mx, my, surface)
    local info = create_info[surface.name]
    if not info then
        return;
    end

    -- 摧毁当前位置的悬崖
    local cliffs = surface.find_entities_filtered {
        position = { x, y },
        type = "cliff"
    }
    for _, cliff in pairs(cliffs) do
        if cliff.valid then
            cliff.destroy()
        end
    end

    if create_water(surface, x, y, mx, my, info.water, info.fish, info.water_size) then
        if info.water_spwaner then
            info.water_spwaner(surface, x, y, mx, my)
        end
        return;
    end

    create_tile(surface, x, y, mx, my, info.tile, info.tile2)

    if (info.oil) then
        create_oil_field(surface, x, y, mx, my, info.oil)
    end

    if info.ore then
        info.ore(surface, x, y, mx, my)
    end

    if info.spwaner then
        info.spwaner(surface, x, y, mx, my)
    end

    if info.rock then
        local distance = 0;
        if info.rock_distance then
            distance = info.rock_distance
        end
        create_rock(surface, x, y, mx, my, info.rock, info.rock2, distance)
    end

    if info.plant then
        create_plant(surface, x, y, mx, my, info.plant, info.plant2)
    end

    if info.special then
        info.special(surface, x, y, mx, my)
    end
end



-- 当地表生成时
script.on_event(defines.events.on_chunk_generated, function(event)
    -- 如果不是星球图层，则不进行处理
    local name = event.surface.name
    if name ~= "nauvis" and name ~= "vulcanus" and name ~= "fulgora" and name ~= "gleba" and name ~= "aquilo" then
        return;
    end



    local chunk_x = event.area.left_top.x
    local chunk_y = event.area.left_top.y

    -- 遍历区块中的每个地格
    for x = 0, 31 do
        for y = 0, 31 do
            local tile_x = chunk_x + x
            local tile_y = chunk_y + y

            if tile_x >= -size / 2 and tile_x < size / 2 and tile_y >= -size / 2 and tile_y < size / 2 then
                if tile_x >= -8 and tile_x < 8 and tile_y >= -8 and tile_y < 8 then
                    event.surface.set_tiles({ {
                        name = "refined-concrete",
                        position = { tile_x, tile_y }
                    } })
                else
                    event.surface.set_tiles({ {
                        name = "out-of-map",
                        position = { tile_x, tile_y }
                    } })
                end
            else
                local x_mod = (tile_x - size / 2 - 32) % size
                local y_mod = (tile_y - size / 2 - 32) % size
                local is_in_build_area = x_mod < size - 64 and y_mod < size - 64

                if is_in_build_area then
                    create_ground(tile_x, tile_y, x_mod, y_mod, event.surface)
                else
                    create_tile(event.surface, tile_x, tile_y, x_mod, y_mod, "out-of-map")
                end
            end
        end
    end
end)


return map_info
