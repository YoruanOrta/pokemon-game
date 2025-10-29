-- Map Module
-- map.lua

Map = {}

function Map.init()
    Map.tileSize = 32
    Map.currentMap = "pueblo"
    
    -- Definir todos los mapas
    Map.maps = {
        pueblo = {
            tiles = {
                {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
                {2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2},
                {2, 4, 5, 5, 4, 4, 5, 5, 4, 4, 5, 5, 4, 4, 2},
                {2, 4, 5, 5, 4, 4, 5, 5, 4, 4, 5, 5, 4, 4, 2},
                {2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2},
                {2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2},
                {2, 4, 5, 5, 4, 4, 4, 4, 4, 4, 5, 5, 4, 4, 2},
                {2, 4, 5, 5, 4, 4, 4, 4, 4, 4, 5, 5, 4, 4, 2},
                {2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2},
                {2, 4, 4, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 4, 2},
                {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
                {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
                {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
                {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
            },
            name = "Pueblo Inicial",
            encounters = false,
            spawns = {x = 7, y = 6}
        },
        ruta1 = {
            tiles = {
                {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
                {2, 4, 4, 4, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 2},
                {2, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 2},
                {2, 1, 1, 2, 2, 1, 1, 4, 1, 1, 2, 2, 1, 1, 2},
                {2, 1, 1, 2, 2, 1, 1, 4, 1, 1, 2, 2, 1, 1, 2},
                {2, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 2},
                {2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2},
                {2, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 2},
                {2, 1, 1, 3, 3, 3, 1, 4, 1, 3, 3, 3, 1, 1, 2},
                {2, 1, 1, 3, 3, 3, 1, 4, 1, 3, 3, 3, 1, 1, 2},
                {2, 1, 1, 3, 3, 3, 1, 4, 1, 3, 3, 3, 1, 1, 2},
                {2, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 2},
                {2, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 2},
                {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
            },
            name = "Ruta 1",
            encounters = true,
            spawns = {x = 7, y = 2}
        }
    }
    
    -- Colores para los tiles
    Map.colors = {
        [1] = {0.4, 0.8, 0.4},    -- césped
        [2] = {0.2, 0.5, 0.2},    -- árbol
        [3] = {0.3, 0.5, 0.9},    -- agua
        [4] = {0.8, 0.7, 0.5},    -- camino
        [5] = {0.6, 0.4, 0.3},    -- casa
        [6] = {1, 0.8, 0}         -- puerta/portal
    }
    
    -- Tiles sólidos (no puedes caminar)
    Map.solidTiles = {
        [2] = true,  -- árboles
        [3] = true,  -- agua
        [5] = true   -- casas
    }
    
    -- Transiciones entre mapas (tile 6 = puerta)
    Map.transitions = {
        pueblo = {
            {x = 7, y = 9, target = "ruta1", targetX = 8, targetY = 2}
        },
        ruta1 = {
            {x = 8, y = 2, target = "pueblo", targetX = 7, targetY = 8}
        }
    }
    
    -- Sistema de encuentros
    Map.encounterChance = 0.1
    
    -- Cámara
    Map.camera = {
        x = 0,
        y = 0
    }
end

function Map.getCurrentTiles()
    return Map.maps[Map.currentMap].tiles
end

function Map.update(dt)
    -- Actualizar cámara para seguir al jugador
    Map.camera.x = Player.pixelX - love.graphics.getWidth() / 2 + Map.tileSize / 2
    Map.camera.y = Player.pixelY - love.graphics.getHeight() / 2 + Map.tileSize / 2
end

function Map.draw()
    love.graphics.push()
    love.graphics.translate(-Map.camera.x, -Map.camera.y)
    
    local tiles = Map.getCurrentTiles()
    
    -- Dibujar tiles
    for y = 1, #tiles do
        for x = 1, #tiles[y] do
            local tile = tiles[y][x]
            local color = Map.colors[tile]
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", (x-1) * Map.tileSize, (y-1) * Map.tileSize, Map.tileSize, Map.tileSize)
            
            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.rectangle("line", (x-1) * Map.tileSize, (y-1) * Map.tileSize, Map.tileSize, Map.tileSize)
        end
    end
    
    love.graphics.pop()
end

function Map.isWalkable(x, y)
    local tiles = Map.getCurrentTiles()
    if y < 1 or y > #tiles or x < 1 or x > #tiles[1] then
        return false
    end
    local tile = tiles[y][x]
    return not Map.solidTiles[tile]
end

function Map.checkTransition(x, y)
    local transitions = Map.transitions[Map.currentMap]
    if not transitions then 
        return false 
    end
    
    for i, trans in ipairs(transitions) do
        if trans.x == x and trans.y == y then
            Map.changeMap(trans.target, trans.targetX, trans.targetY)
            return true
        end
    end
    
    return false
end

function Map.changeMap(newMap, targetX, targetY)
    Map.currentMap = newMap
    Player.x = targetX
    Player.y = targetY
    Player.pixelX = targetX * Map.tileSize
    Player.pixelY = targetY * Map.tileSize
    Player.targetX = targetX
    Player.targetY = targetY
end

function Map.checkEncounter(x, y)
    -- Solo si el mapa permite encuentros
    if not Map.maps[Map.currentMap].encounters then
        return false
    end
    
    local tiles = Map.getCurrentTiles()
    -- Solo en césped (tile 1)
    if tiles[y][x] == 1 then
        if math.random() < Map.encounterChance then
            return true
        end
    end
    return false
end

function Map.getCurrentName()
    return Map.maps[Map.currentMap].name
end

return Map