-- Player Module
-- player.lua

Player = {}

function Player.init()
    Player.x = 7
    Player.y = 6
    Player.speed = 4
    Player.moving = false
    Player.targetX = 7
    Player.targetY = 6
    Player.pixelX = 7 * Map.tileSize
    Player.pixelY = 6 * Map.tileSize
    Player.direction = "down"
    
    -- Crear criatura inicial
    table.insert(playerTeam, createCreature(creatureDatabase[1], 5))
end

function Player.update(dt)
    if Player.moving then
        local dx = (Player.targetX * Map.tileSize - Player.pixelX) * Player.speed * dt
        local dy = (Player.targetY * Map.tileSize - Player.pixelY) * Player.speed * dt
        
        Player.pixelX = Player.pixelX + dx
        Player.pixelY = Player.pixelY + dy
        
        local distX = math.abs(Player.targetX * Map.tileSize - Player.pixelX)
        local distY = math.abs(Player.targetY * Map.tileSize - Player.pixelY)
        
        if distX < 1 and distY < 1 then
            Player.pixelX = Player.targetX * Map.tileSize
            Player.pixelY = Player.targetY * Map.tileSize
            Player.x = Player.targetX
            Player.y = Player.targetY
            Player.moving = false
            
            -- Verificar transición de mapa PRIMERO
            local transitioned = Map.checkTransition(Player.x, Player.y)
            
            -- Solo verificar encuentro si NO hubo transición
            if not transitioned and Map.checkEncounter(Player.x, Player.y) then
                Battle.start()
                inBattle = true
            end
        end
    else
        local newX, newY = Player.x, Player.y
        local moved = false
        
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
            newY = newY - 1
            Player.direction = "up"
            moved = true
        elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
            newY = newY + 1
            Player.direction = "down"
            moved = true
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            newX = newX - 1
            Player.direction = "left"
            moved = true
        elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            newX = newX + 1
            Player.direction = "right"
            moved = true
        end
        
        if moved and Map.isWalkable(newX, newY) then
            Player.targetX = newX
            Player.targetY = newY
            Player.moving = true
        end
    end
end

function Player.draw()
    love.graphics.push()
    love.graphics.translate(-Map.camera.x, -Map.camera.y)
    
    -- Dibujar jugador
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.rectangle("fill", Player.pixelX + 4, Player.pixelY + 4, Map.tileSize - 8, Map.tileSize - 8)
    
    -- Dirección del jugador
    love.graphics.setColor(1, 1, 1)
    local cx, cy = Player.pixelX + Map.tileSize/2, Player.pixelY + Map.tileSize/2
    if Player.direction == "up" then
        love.graphics.circle("fill", cx, cy - 8, 3)
    elseif Player.direction == "down" then
        love.graphics.circle("fill", cx, cy + 8, 3)
    elseif Player.direction == "left" then
        love.graphics.circle("fill", cx - 8, cy, 3)
    else
        love.graphics.circle("fill", cx + 8, cy, 3)
    end
    
    love.graphics.pop()
end

return Player