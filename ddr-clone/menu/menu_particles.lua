local gameState = require('game_state')

local particles = {
    active = {},
    trails = {},
    shockwaves = {},
    energyWaves = {}
}

local function ensureColorAlpha(color, alpha)
    return {
        color[1] or 1,
        color[2] or 1,
        color[3] or 1,
        alpha or color[4] or 1
    }
end

local function createParticle(x, y, style)
    local angle = love.math.random() * math.pi * 2
    local speed = love.math.random(150, 300) -- Reduced speed range
    local particleTypes = {
        neon = {
            size = love.math.random(2, 4), -- Reduced size
            color = ensureColorAlpha({
                love.math.random(0.8, 1),
                love.math.random(0.8, 1),
                1
            }, 0.8), -- Reduced alpha
            glowSize = love.math.random(1.5, 3), -- Reduced glow
            rotationSpeed = love.math.random(-3, 3) -- Reduced rotation
        },
        spark = {
            size = love.math.random(1, 2), -- Reduced size
            color = ensureColorAlpha(gameState.colors.particles.spark, 0.8),
            glowSize = 1,
            rotationSpeed = love.math.random(-8, 8) -- Reduced rotation
        },
        energy = {
            size = love.math.random(3, 6), -- Reduced size
            color = ensureColorAlpha(gameState.colors.particles.energy, 0.8),
            glowSize = love.math.random(2, 4), -- Reduced glow
            rotationSpeed = love.math.random(-2, 2) -- Reduced rotation
        },
        rainbow = {
            size = love.math.random(3, 6), -- Reduced size
            color = {1, 1, 1, 0.8}, -- Reduced alpha
            glowSize = love.math.random(2, 4), -- Reduced glow
            rotationSpeed = love.math.random(-2, 2), -- Reduced rotation
            rainbowPhase = love.math.random() * math.pi * 2
        }
    }

    local particleType = particleTypes[style or "neon"]
    return {
        x = x,
        y = y,
        dx = math.cos(angle) * speed,
        dy = math.sin(angle) * speed,
        life = 1,
        trail = {},
        rotation = love.math.random() * math.pi * 2,
        rotationSpeed = particleType.rotationSpeed,
        size = particleType.size,
        color = particleType.color,
        glowSize = particleType.glowSize,
        style = style or "neon",
        rainbowPhase = particleType.rainbowPhase
    }
end

local function createShockwave(x, y, color)
    return {
        x = x,
        y = y,
        radius = 0,
        life = 1,
        speed = 600, -- Reduced speed
        color = ensureColorAlpha(color or gameState.colors.neon.blue, 0.8),
        thickness = love.math.random(1, 3) -- Reduced thickness
    }
end

local function createEnergyWave(y)
    local waveColors = {
        gameState.colors.neon.blue,
        gameState.colors.neon.pink,
        gameState.colors.neon.green
    }
    local selectedColor = waveColors[love.math.random(1, #waveColors)]
    
    return {
        y = y,
        amplitude = love.math.random(15, 30), -- Reduced amplitude
        frequency = love.math.random(2, 4),
        speed = love.math.random(80, 150), -- Reduced speed
        color = ensureColorAlpha(selectedColor, 0.4), -- Reduced alpha
        offset = love.math.random() * math.pi * 2
    }
end

function particles.update(dt, animState)
    -- Update particles with enhanced physics
    for i = #particles.active, 1, -1 do
        local p = particles.active[i]
        
        if p.style == "rainbow" then
            -- Update rainbow particle color with reduced intensity
            local hue = (animState.rainbowTime + p.rainbowPhase) % (math.pi * 2)
            p.color = {
                0.6 + 0.4 * math.sin(hue), -- Reduced range
                0.6 + 0.4 * math.sin(hue + math.pi * 2/3),
                0.6 + 0.4 * math.sin(hue + math.pi * 4/3),
                p.life * 0.8 -- Reduced alpha
            }
        end
        
        -- Add current position to trail
        if p.style ~= "spark" then
            table.insert(p.trail, {x = p.x, y = p.y, life = 1, rotation = p.rotation})
        end
        
        -- Update position with style-specific movement
        if p.style == "energy" or p.style == "rainbow" then
            p.dy = p.dy + 80 * dt -- Reduced gravity
        else
            p.dy = p.dy + 250 * dt -- Reduced gravity
        end
        
        p.x = p.x + p.dx * dt
        p.y = p.y + p.dy * dt
        p.rotation = p.rotation + p.rotationSpeed * dt
        
        -- Update life with style-specific decay
        local decayRate = p.style == "spark" and 2 or 1.5
        p.life = p.life - dt * decayRate
        p.color[4] = p.life * 0.8 -- Reduced alpha
        
        if p.life <= 0 then
            table.remove(particles.active, i)
        end
        
        -- Update trail with faster fade
        for j = #p.trail, 1, -1 do
            local t = p.trail[j]
            t.life = t.life - dt * 3 -- Faster fade
            if t.life <= 0 then
                table.remove(p.trail, j)
            end
        end
    end
    
    -- Update shockwaves with faster fade
    for i = #particles.shockwaves, 1, -1 do
        local s = particles.shockwaves[i]
        s.radius = s.radius + s.speed * dt
        s.life = s.life - dt * 1.2 -- Faster fade
        if s.life <= 0 then
            table.remove(particles.shockwaves, i)
        end
    end
    
    -- Update energy waves with faster fade
    for i = #particles.energyWaves, 1, -1 do
        local w = particles.energyWaves[i]
        w.offset = w.offset + w.speed * dt
        if w.offset > math.pi * 3 then -- Reduced lifetime
            table.remove(particles.energyWaves, i)
        end
    end
end

function particles.draw()
    -- Draw trails with reduced opacity
    for _, p in ipairs(particles.active) do
        if p.style ~= "spark" then
            for _, t in ipairs(p.trail) do
                local alpha = (p.color[4] or 1) * t.life * 0.3 -- Reduced opacity
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
                love.graphics.push()
                love.graphics.translate(t.x, t.y)
                love.graphics.rotate(t.rotation)
                love.graphics.rectangle("fill", -p.size/2 * t.life, -p.size/2 * t.life, 
                                     p.size * t.life, p.size * t.life)
                love.graphics.pop()
            end
        end
    end
    
    -- Draw particles with reduced glow
    for _, p in ipairs(particles.active) do
        love.graphics.setColor(p.color)
        
        if p.style ~= "spark" then
            -- Draw glow effect with reduced layers
            for i = 1, 2 do -- Reduced from 3 to 2 layers
                local alpha = (p.color[4] or 1) * (0.2 / i) -- Reduced glow intensity
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
                love.graphics.circle("fill", p.x, p.y, p.size * p.glowSize * i)
            end
        end
        
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.rotate(p.rotation)
        
        if p.style == "spark" then
            love.graphics.line(-p.size, 0, p.size, 0)
            love.graphics.line(0, -p.size, 0, p.size)
        else
            love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
        end
        
        love.graphics.pop()
    end
    
    -- Draw shockwaves with reduced layers
    for _, s in ipairs(particles.shockwaves) do
        for i = 1, 2 do -- Reduced from 3 to 2 layers
            local alpha = s.life * 0.2 / i -- Reduced opacity
            love.graphics.setColor(s.color[1], s.color[2], s.color[3], alpha)
            love.graphics.setLineWidth(s.thickness * i)
            love.graphics.circle("line", s.x, s.y, s.radius * (1 - 0.08 * i)) -- Reduced spread
        end
    end
    
    -- Draw energy waves with reduced intensity
    for _, w in ipairs(particles.energyWaves) do
        love.graphics.setColor(w.color)
        local points = {}
        for x = 0, love.graphics.getWidth(), 6 do -- Increased step size
            local y = w.y + math.sin(x * w.frequency * 0.01 + w.offset) * w.amplitude
            table.insert(points, x)
            table.insert(points, y)
        end
        love.graphics.setLineWidth(2) -- Reduced line width
        love.graphics.line(points)
    end
end

function particles.spawn(x, y, style)
    table.insert(particles.active, createParticle(x, y, style))
end

function particles.spawnShockwave(x, y, color)
    table.insert(particles.shockwaves, createShockwave(x, y, color))
end

function particles.spawnEnergyWave(y)
    table.insert(particles.energyWaves, createEnergyWave(y))
end

function particles.clear()
    particles.active = {}
    particles.shockwaves = {}
    particles.energyWaves = {}
end

return particles