-- Pokemon Game - Main Entry Point
-- main.lua

function love.load()
    love.window.setTitle("Pokemon Game")
    
    -- Cargar módulos (el orden importa)
    require("creatures")
    require("map")
    require("player")
    require("battle")
    
    -- Inicializar módulos
    Map.init()
    Player.init()
    Battle.init()
    
    inBattle = false
end

function love.update(dt)
    if inBattle then
        Battle.update(dt)
    else
        Player.update(dt)
        Map.update(dt)
    end
end

function love.draw()
    if inBattle then
        Battle.draw()
    else
        Map.draw()
        Player.draw()
        
        -- UI del mundo
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Usa WASD o flechas para moverte", 10, 10)
        love.graphics.print("Ubicación: " .. Map.getCurrentName(), 10, 30)
        love.graphics.print("Equipo: " .. #playerTeam .. " criaturas", 10, 50)
        love.graphics.print("Posición: (" .. Player.x .. ", " .. Player.y .. ")", 10, 70)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if inBattle then
        Battle.keypressed(key)
    end
end