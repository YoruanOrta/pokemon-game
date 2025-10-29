-- Battle Module
-- battle.lua

Battle = {}

function Battle.init()
    Battle.enemy = nil
    Battle.playerCreature = nil
    Battle.menuSelection = 1
    Battle.moveSelection = 1
    Battle.teamSelection = 1
    Battle.state = "menu"
    Battle.message = ""
    Battle.messageTimer = 0
    Battle.attackAnimation = 0
    Battle.turn = "player"
    Battle.pokeballs = 5
    Battle.showLevelUp = false
    Battle.levelUpMessage = ""
    Battle.newMove = nil
end

function Battle.start()
    local template = creatureDatabase[math.random(#creatureDatabase)]
    local enemyLevel = math.random(3, 7)
    Battle.enemy = createCreature(template, enemyLevel)
    Battle.playerCreature = playerTeam[1]
    Battle.menuSelection = 1
    Battle.state = "message"
    Battle.message = "¡Un " .. Battle.enemy.name .. " salvaje apareció!"
    Battle.messageTimer = 2
end

function Battle.update(dt)
    if Battle.state == "message" then
        Battle.messageTimer = Battle.messageTimer - dt
        if Battle.messageTimer <= 0 then
            Battle.state = "menu"
        end
    elseif Battle.state == "waiting" then
        Battle.messageTimer = Battle.messageTimer - dt
        if Battle.messageTimer <= 0 then
            if Battle.turn == "enemy" then
                Battle.enemyAttack()
            else
                Battle.state = "menu"
            end
        end
    elseif Battle.state == "attack" then
        Battle.attackAnimation = Battle.attackAnimation + dt * 8
        if Battle.attackAnimation >= 1 then
            Battle.attackAnimation = 0
            Battle.state = "waiting"
            Battle.messageTimer = 1.5
        end
    elseif Battle.state == "victory" then
        Battle.messageTimer = Battle.messageTimer - dt
        if Battle.messageTimer <= 0 then
            if Battle.showLevelUp then
                Battle.state = "levelup"
                Battle.showLevelUp = false
                Battle.messageTimer = 2
            else
                inBattle = false
            end
        end
    elseif Battle.state == "levelup" then
        Battle.messageTimer = Battle.messageTimer - dt
        if Battle.messageTimer <= 0 then
            inBattle = false
        end
    elseif Battle.state == "defeat" then
        Battle.messageTimer = Battle.messageTimer - dt
        if Battle.messageTimer <= 0 then
            for i, c in ipairs(playerTeam) do
                c.hp = c.maxHP
            end
            inBattle = false
        end
    end
end

function Battle.playerAttack(moveIndex)
    local attacker = Battle.playerCreature
    local defender = Battle.enemy
    
    if not moveIndex then
        moveIndex = 1
    end
    
    if not attacker.moves[moveIndex] then
        Battle.message = "¡Error: movimiento no válido!"
        Battle.state = "waiting"
        Battle.messageTimer = 1
        return
    end
    
    local move = attacker.moves[moveIndex]
    
    if math.random(100) > move.accuracy then
        Battle.message = attacker.name .. " usó " .. move.name .. " pero falló!"
        Battle.state = "waiting"
        Battle.turn = "enemy"
        Battle.messageTimer = 1.5
        return
    end
    
    local damage = math.max(1, math.floor((attacker.attack / defender.defense) * (move.power / 10) + math.random(-2, 2)))
    defender.hp = math.max(0, defender.hp - damage)
    
    Battle.message = attacker.name .. " usó " .. move.name .. " causando " .. damage .. " de daño!"
    Battle.state = "attack"
    Battle.turn = "enemy"
    
    if defender.hp <= 0 then
        local expGained = defender.level * 8
        Battle.message = "¡" .. defender.name .. " fue derrotado! +" .. expGained .. " EXP"
        gainExp(Battle.playerCreature, expGained)
        Battle.state = "victory"
        Battle.messageTimer = 2
    end
end

function Battle.enemyAttack()
    local attacker = Battle.enemy
    local defender = Battle.playerCreature
    
    local move = attacker.moves[math.random(#attacker.moves)]
    
    if math.random(100) > move.accuracy then
        Battle.message = attacker.name .. " usó " .. move.name .. " pero falló!"
        Battle.state = "waiting"
        Battle.turn = "player"
        Battle.messageTimer = 1.5
        return
    end
    
    local damage = math.max(1, math.floor((attacker.attack / defender.defense) * (move.power / 10) + math.random(-2, 2)))
    defender.hp = math.max(0, defender.hp - damage)
    
    Battle.message = attacker.name .. " usó " .. move.name .. " causando " .. damage .. " de daño!"
    Battle.state = "attack"
    Battle.turn = "player"
    
    if defender.hp <= 0 then
        Battle.message = "¡" .. defender.name .. " fue derrotado!"
        
        local allDefeated = true
        for i, c in ipairs(playerTeam) do
            if c.hp > 0 then
                allDefeated = false
                break
            end
        end
        
        if allDefeated then
            Battle.message = "¡Todas tus criaturas fueron derrotadas! Perdiste..."
            Battle.state = "defeat"
            Battle.messageTimer = 3
        else
            Battle.state = "team"
            Battle.teamSelection = 1
            Battle.message = "¡" .. defender.name .. " fue debilitado! Elige otra criatura."
        end
    end
end

function Battle.switchCreature(index)
    if index < 1 or index > #playerTeam then
        return
    end
    
    local newCreature = playerTeam[index]
    
    if newCreature.hp <= 0 then
        Battle.message = "¡" .. newCreature.name .. " está debilitado!"
        Battle.state = "waiting"
        Battle.messageTimer = 1.5
        return
    end
    
    if newCreature == Battle.playerCreature then
        Battle.message = "¡" .. newCreature.name .. " ya está en batalla!"
        Battle.state = "waiting"
        Battle.messageTimer = 1.5
        return
    end
    
    Battle.playerCreature = newCreature
    Battle.message = "¡Adelante, " .. newCreature.name .. "!"
    Battle.state = "waiting"
    Battle.turn = "enemy"
    Battle.messageTimer = 1.5
end

function Battle.tryCapture()
    if Battle.pokeballs <= 0 then
        Battle.message = "¡No tienes Pokéballs!"
        Battle.state = "waiting"
        Battle.messageTimer = 1.5
        Battle.turn = "enemy"
        return
    end
    
    Battle.pokeballs = Battle.pokeballs - 1
    
    local captureRate = (1 - Battle.enemy.hp / Battle.enemy.maxHP) * 0.5 + 0.2
    
    if math.random() < captureRate then
        Battle.message = "¡Capturaste a " .. Battle.enemy.name .. "!"
        table.insert(playerTeam, Battle.enemy)
        Battle.state = "victory"
        Battle.messageTimer = 2
    else
        Battle.message = "¡Oh no! " .. Battle.enemy.name .. " escapó de la Pokéball!"
        Battle.state = "waiting"
        Battle.messageTimer = 1.5
        Battle.turn = "enemy"
    end
end

function Battle.setLevelUp(message)
    Battle.levelUpMessage = message
    Battle.showLevelUp = true
end

function Battle.setNewMove(moveName)
    Battle.newMove = moveName
end

function Battle.draw()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    
    love.graphics.setColor(0.9, 0.95, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Enemigo
    local enemyX = w * 0.7
    local enemyY = h * 0.25
    if Battle.state == "attack" and Battle.turn == "player" then
        enemyX = enemyX + math.sin(Battle.attackAnimation * 10) * 20
    end
    love.graphics.setColor(Battle.enemy.color)
    love.graphics.circle("fill", enemyX, enemyY, 40)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(Battle.enemy.name, enemyX - 60, enemyY - 60, 120, "center")
    love.graphics.printf("Nv." .. Battle.enemy.level, enemyX - 60, enemyY - 80, 120, "center")
    
    local hpPercent = Battle.enemy.hp / Battle.enemy.maxHP
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", enemyX - 50, enemyY + 50, 100, 10)
    if hpPercent > 0.5 then
        love.graphics.setColor(0.3, 0.8, 0.3)
    elseif hpPercent > 0.2 then
        love.graphics.setColor(1, 0.8, 0.2)
    else
        love.graphics.setColor(1, 0.2, 0.2)
    end
    love.graphics.rectangle("fill", enemyX - 50, enemyY + 50, 100 * hpPercent, 10)
    
    -- Jugador
    local playerX = w * 0.3
    local playerY = h * 0.55
    if Battle.state == "attack" and Battle.turn == "enemy" then
        playerX = playerX + math.sin(Battle.attackAnimation * 10) * 20
    end
    love.graphics.setColor(Battle.playerCreature.color)
    love.graphics.circle("fill", playerX, playerY, 40)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(Battle.playerCreature.name, playerX - 60, playerY + 50, 120, "center")
    love.graphics.printf("Nv." .. Battle.playerCreature.level, playerX - 60, playerY + 70, 120, "center")
    
    hpPercent = Battle.playerCreature.hp / Battle.playerCreature.maxHP
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", playerX - 50, playerY - 60, 100, 10)
    if hpPercent > 0.5 then
        love.graphics.setColor(0.3, 0.8, 0.3)
    elseif hpPercent > 0.2 then
        love.graphics.setColor(1, 0.8, 0.2)
    else
        love.graphics.setColor(1, 0.2, 0.2)
    end
    love.graphics.rectangle("fill", playerX - 50, playerY - 60, 100 * hpPercent, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(Battle.playerCreature.hp .. "/" .. Battle.playerCreature.maxHP, playerX - 50, playerY - 50, 100, "center")
    
    -- EXP bar
    local expPercent = Battle.playerCreature.exp / Battle.playerCreature.expToNext
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", playerX - 50, playerY - 45, 100, 6)
    love.graphics.setColor(0.3, 0.6, 1)
    love.graphics.rectangle("fill", playerX - 50, playerY - 45, 100 * expPercent, 6)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.printf("EXP", playerX - 50, playerY - 37, 100, "center")
    love.graphics.setFont(love.graphics.newFont(12))
    
    -- Mensaje
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 20, h - 120, w - 40, 100)
    love.graphics.setColor(1, 1, 1)
    
    if Battle.state == "levelup" then
        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf(Battle.levelUpMessage, 40, h - 100, w - 80, "center")
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ATK:" .. Battle.playerCreature.attack .. " DEF:" .. Battle.playerCreature.defense .. " HP:" .. Battle.playerCreature.maxHP, 40, h - 70, w - 80, "center")
        
        if Battle.newMove then
            love.graphics.setColor(0.5, 1, 0.5)
            love.graphics.printf("¡Aprendió " .. Battle.newMove .. "!", 40, h - 50, w - 80, "center")
            Battle.newMove = nil
        end
        
        love.graphics.setFont(love.graphics.newFont(12))
    else
        love.graphics.printf(Battle.message, 40, h - 100, w - 80, "left")
    end
    
    -- Menús
    if Battle.state == "menu" then
        Battle.drawMainMenu()
    elseif Battle.state == "moves" then
        Battle.drawMovesMenu()
    elseif Battle.state == "team" then
        Battle.drawTeamMenu()
    end
end

function Battle.drawMainMenu()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local menuX = w - 220
    local menuY = h - 240
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", menuX, menuY, 200, 110)
    
    local options = {"ATACAR", "CAPTURAR", "EQUIPO", "HUIR"}
    for i, option in ipairs(options) do
        if i == Battle.menuSelection then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.print(option, menuX + 20, menuY + 10 + (i-1) * 25)
    end
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Pokéballs: " .. Battle.pokeballs, menuX + 20, menuY + 110)
end

function Battle.drawMovesMenu()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local menuX = w - 320
    local menuY = h - 240
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", menuX, menuY, 300, 150)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Selecciona un ataque:", menuX + 20, menuY + 10)
    
    for i, move in ipairs(Battle.playerCreature.moves) do
        if i == Battle.moveSelection then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        local moveText = move.name .. " (Poder:" .. move.power .. " Prec:" .. move.accuracy .. "%)"
        love.graphics.print(moveText, menuX + 20, menuY + 35 + (i-1) * 25)
    end
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("B para volver", menuX + 20, menuY + 125)
end

function Battle.drawTeamMenu()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local menuX = 50
    local menuY = 50
    
    love.graphics.setColor(0.2, 0.2, 0.2, 0.95)
    love.graphics.rectangle("fill", menuX, menuY, w - 100, h - 100)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("TU EQUIPO", menuX + 20, menuY + 15)
    love.graphics.setFont(love.graphics.newFont(12))
    
    for i, creature in ipairs(playerTeam) do
        local itemY = menuY + 60 + (i - 1) * 80
        
        if i == Battle.teamSelection then
            love.graphics.setColor(0.3, 0.3, 0.5)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
        end
        love.graphics.rectangle("fill", menuX + 20, itemY, w - 140, 70)
        
        love.graphics.setColor(creature.color)
        love.graphics.circle("fill", menuX + 50, itemY + 35, 25)
        
        if creature.hp <= 0 then
            love.graphics.setColor(0.5, 0.5, 0.5)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.print(creature.name, menuX + 90, itemY + 10)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print("Nv." .. creature.level, menuX + 90, itemY + 30)
        
        local hpPercent = creature.hp / creature.maxHP
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", menuX + 90, itemY + 50, 200, 10)
        
        if creature.hp <= 0 then
            love.graphics.setColor(0.5, 0.5, 0.5)
        elseif hpPercent > 0.5 then
            love.graphics.setColor(0.3, 0.8, 0.3)
        elseif hpPercent > 0.2 then
            love.graphics.setColor(1, 0.8, 0.2)
        else
            love.graphics.setColor(1, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", menuX + 90, itemY + 50, 200 * hpPercent, 10)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(creature.hp .. "/" .. creature.maxHP, menuX + 300, itemY + 48)
        
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print("ATK:" .. creature.attack .. " DEF:" .. creature.defense, menuX + 400, itemY + 50)
        
        if creature == Battle.playerCreature then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("★ EN BATALLA", menuX + 400, itemY + 10)
        end
    end
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("W/S: Seleccionar | ENTER: Cambiar | B: Volver", menuX + 20, h - 60)
end

function Battle.keypressed(key)
    if Battle.state == "menu" then
        if key == "up" or key == "w" then
            Battle.menuSelection = Battle.menuSelection - 1
            if Battle.menuSelection < 1 then Battle.menuSelection = 4 end
        elseif key == "down" or key == "s" then
            Battle.menuSelection = Battle.menuSelection + 1
            if Battle.menuSelection > 4 then Battle.menuSelection = 1 end
        elseif key == "return" or key == "space" then
            if Battle.menuSelection == 1 then
                Battle.state = "moves"
                Battle.moveSelection = 1
            elseif Battle.menuSelection == 2 then
                Battle.tryCapture()
            elseif Battle.menuSelection == 3 then
                Battle.state = "team"
                Battle.teamSelection = 1
            elseif Battle.menuSelection == 4 then
                Battle.message = "¡Huiste de la batalla!"
                Battle.state = "victory"
                Battle.messageTimer = 1.5
            end
        end
    elseif Battle.state == "moves" then
        if key == "up" or key == "w" then
            Battle.moveSelection = Battle.moveSelection - 1
            if Battle.moveSelection < 1 then Battle.moveSelection = #Battle.playerCreature.moves end
        elseif key == "down" or key == "s" then
            Battle.moveSelection = Battle.moveSelection + 1
            if Battle.moveSelection > #Battle.playerCreature.moves then Battle.moveSelection = 1 end
        elseif key == "return" or key == "space" then
            Battle.playerAttack(Battle.moveSelection)
        elseif key == "b" or key == "backspace" then
            Battle.state = "menu"
        end
    elseif Battle.state == "team" then
        if key == "up" or key == "w" then
            Battle.teamSelection = Battle.teamSelection - 1
            if Battle.teamSelection < 1 then Battle.teamSelection = #playerTeam end
        elseif key == "down" or key == "s" then
            Battle.teamSelection = Battle.teamSelection + 1
            if Battle.teamSelection > #playerTeam then Battle.teamSelection = 1 end
        elseif key == "return" or key == "space" then
            Battle.switchCreature(Battle.teamSelection)
        elseif key == "b" or key == "backspace" then
            Battle.state = "menu"
        end
    end
end