-- Creatures Module
-- creatures.lua

-- Base de datos de ataques
attackDatabase = {
    -- Ataques de fuego
    {name = "Ascuas", type = "fuego", power = 40, accuracy = 100},
    {name = "Lanzallamas", type = "fuego", power = 90, accuracy = 85},
    {name = "Giro Fuego", type = "fuego", power = 60, accuracy = 95},
    {name = "Infierno", type = "fuego", power = 120, accuracy = 70},
    
    -- Ataques de agua
    {name = "Pistola Agua", type = "agua", power = 40, accuracy = 100},
    {name = "Hidrobomba", type = "agua", power = 110, accuracy = 80},
    {name = "Burbuja", type = "agua", power = 50, accuracy = 100},
    {name = "Surf", type = "agua", power = 90, accuracy = 100},
    
    -- Ataques de planta
    {name = "Látigo Cepa", type = "planta", power = 45, accuracy = 100},
    {name = "Rayo Solar", type = "planta", power = 120, accuracy = 85},
    {name = "Hoja Afilada", type = "planta", power = 55, accuracy = 95},
    {name = "Planta Feroz", type = "planta", power = 90, accuracy = 90},
    
    -- Ataques eléctricos
    {name = "Impactrueno", type = "eléctrico", power = 40, accuracy = 100},
    {name = "Rayo", type = "eléctrico", power = 90, accuracy = 85},
    {name = "Chispa", type = "eléctrico", power = 65, accuracy = 100},
    {name = "Trueno", type = "eléctrico", power = 110, accuracy = 70},
    
    -- Ataques de roca
    {name = "Lanzarrocas", type = "roca", power = 50, accuracy = 90},
    {name = "Tumba Rocas", type = "roca", power = 75, accuracy = 95},
    {name = "Pedrada", type = "roca", power = 40, accuracy = 100},
    {name = "Roca Afilada", type = "roca", power = 100, accuracy = 80},
    
    -- Ataques normales
    {name = "Placaje", type = "normal", power = 40, accuracy = 100},
    {name = "Arañazo", type = "normal", power = 40, accuracy = 100},
    {name = "Destructor", type = "normal", power = 90, accuracy = 85}
}

-- Base de datos de criaturas
creatureDatabase = {
    {
        name = "Flamito", 
        type = "fuego", 
        color = {1, 0.3, 0}, 
        baseHP = 45, 
        baseAtk = 52, 
        baseDef = 43,
        movePool = {1, 2, 3, 21, 22}
    },
    {
        name = "Aquito", 
        type = "agua", 
        color = {0.2, 0.5, 1}, 
        baseHP = 44, 
        baseAtk = 48, 
        baseDef = 65,
        movePool = {5, 6, 7, 8, 21}
    },
    {
        name = "Plantix", 
        type = "planta", 
        color = {0.3, 0.9, 0.3}, 
        baseHP = 45, 
        baseAtk = 49, 
        baseDef = 49,
        movePool = {9, 10, 11, 12, 21}
    },
    {
        name = "Voltix", 
        type = "eléctrico", 
        color = {1, 1, 0.2}, 
        baseHP = 35, 
        baseAtk = 55, 
        baseDef = 40,
        movePool = {13, 14, 15, 16, 22}
    },
    {
        name = "Rockino", 
        type = "roca", 
        color = {0.6, 0.5, 0.4}, 
        baseHP = 50, 
        baseAtk = 45, 
        baseDef = 55,
        movePool = {17, 18, 19, 20, 21}
    }
}

-- Equipo del jugador
playerTeam = {}

function createCreature(template, level)
    local creature = {
        name = template.name,
        type = template.type,
        color = template.color,
        level = level,
        maxHP = template.baseHP + level * 2,
        hp = 0,
        attack = template.baseAtk + level,
        defense = template.baseDef + level,
        exp = 0,
        expToNext = level * 10,
        baseHP = template.baseHP,
        baseAtk = template.baseAtk,
        baseDef = template.baseDef,
        moves = {}
    }
    creature.hp = creature.maxHP
    
    learnMoves(creature, template.movePool)
    
    return creature
end

function learnMoves(creature, movePool)
    creature.moves = {}
    
    table.insert(creature.moves, attackDatabase[movePool[1]])
    
    if creature.level >= 3 and movePool[2] then
        table.insert(creature.moves, attackDatabase[movePool[2]])
    end
    if creature.level >= 7 and movePool[3] then
        table.insert(creature.moves, attackDatabase[movePool[3]])
    end
    if creature.level >= 12 and movePool[4] then
        table.insert(creature.moves, attackDatabase[movePool[4]])
    end
    
    while #creature.moves > 4 do
        table.remove(creature.moves, 1)
    end
end

function gainExp(creature, amount)
    creature.exp = creature.exp + amount
    
    while creature.exp >= creature.expToNext do
        creature.exp = creature.exp - creature.expToNext
        levelUp(creature)
    end
end

function levelUp(creature)
    creature.level = creature.level + 1
    
    local oldMaxHP = creature.maxHP
    creature.maxHP = creature.baseHP + creature.level * 2
    creature.attack = creature.baseAtk + creature.level
    creature.defense = creature.baseDef + creature.level
    creature.expToNext = creature.level * 10
    
    local hpGain = creature.maxHP - oldMaxHP
    creature.hp = creature.hp + hpGain
    
    local template = nil
    for i, t in ipairs(creatureDatabase) do
        if t.name == creature.name then
            template = t
            break
        end
    end
    
    if template then
        local oldMoveCount = #creature.moves
        learnMoves(creature, template.movePool)
        
        if #creature.moves > oldMoveCount then
            Battle.setNewMove(creature.moves[#creature.moves].name)
        end
    end
    
    Battle.setLevelUp(creature.name .. " subió al nivel " .. creature.level .. "!")
end