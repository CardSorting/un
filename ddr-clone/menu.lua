local gameState = require('game_state')
local songManager = require('song_manager')

-- Menu music
local menuMusic = love.audio.newSource("assets/Z Fighter's Anthem.mp3", "stream")
menuMusic:setLooping(true)
menuMusic:play()

-- Animation state
local menuAnimState = {
    time = 0,
    pulseScale = 1,
    particles = {},
    trails = {},
    waveOffset = 0,
    titleGlow = 0,
    selectedScale = 1,
    menuItemOffsets = {},
    bgRotation = 0,
    flashAlpha = 0,
    beatTime = 0,
    shockwaves = {},
    neonIntensity = 0
}

-- Particle system with trails
local function createParticle(x, y, isNeon)
    local angle = love.math.random() * math.pi * 2
    local speed = love.math.random(150, 300)
    return {
        x = x,
        y = y,
        dx = math.cos(angle) * speed,
        dy = math.sin(angle) * speed,
        life = 1,
        trail = {},
        size = love.math.random(2, 4),
        isNeon = isNeon,
        color = isNeon and {
            love.math.random(0.8, 1),
            love.math.random(0.8, 1),
            1,
            1
        } or {1, 1, 1, 1}
    }
end

local function createShockwave(x, y)
    return {
        x = x,
        y = y,
        radius = 0,
        life = 1,
        speed = 500
    }
end

local function updateParticles(dt)
    -- Update existing particles
    for i = #menuAnimState.particles, 1, -1 do
        local p = menuAnimState.particles[i]
        
        -- Add current position to trail
        if p.isNeon then
            table.insert(p.trail, {x = p.x, y = p.y, life = 1})
        end
        
        -- Update position with gravity effect
        p.dy = p.dy + 200 * dt
        p.x = p.x + p.dx * dt
        p.y = p.y + p.dy * dt
        
        -- Update life and remove if dead
        p.life = p.life - dt * 1.5
        p.color[4] = p.life
        
        if p.life <= 0 then
            table.remove(menuAnimState.particles, i)
        end
        
        -- Update trail
        for j = #p.trail, 1, -1 do
            local t = p.trail[j]
            t.life = t.life - dt * 2
            if t.life <= 0 then
                table.remove(p.trail, j)
            end
        end
    end
    
    -- Update shockwaves
    for i = #menuAnimState.shockwaves, 1, -1 do
        local s = menuAnimState.shockwaves[i]
        s.radius = s.radius + s.speed * dt
        s.life = s.life - dt
        if s.life <= 0 then
            table.remove(menuAnimState.shockwaves, i)
        end
    end
end

local function drawParticles()
    -- Draw trails first
    for _, p in ipairs(menuAnimState.particles) do
        if p.isNeon then
            for _, t in ipairs(p.trail) do
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], t.life * 0.5)
                love.graphics.circle("fill", t.x, t.y, p.size * t.life)
            end
        end
    end
    
    -- Draw particles
    for _, p in ipairs(menuAnimState.particles) do
        love.graphics.setColor(p.color)
        if p.isNeon then
            -- Draw glow effect for neon particles
            for i = 1, 3 do
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.color[4] * (0.3 / i))
                love.graphics.circle("fill", p.x, p.y, p.size * (1 + i))
            end
        end
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    
    -- Draw shockwaves
    for _, s in ipairs(menuAnimState.shockwaves) do
        love.graphics.setColor(1, 1, 1, s.life * 0.3)
        love.graphics.circle("line", s.x, s.y, s.radius)
        love.graphics.circle("line", s.x, s.y, s.radius * 0.8)
    end
end

-- Background effects
local function drawBackground()
    local w, h = love.graphics.getDimensions()
    menuAnimState.bgRotation = menuAnimState.bgRotation + 0.3
    
    -- Rhythmic beat pulse
    local beatPulse = math.sin(menuAnimState.beatTime * 8) * 0.2
    
    -- Draw dynamic spiral pattern
    for i = 0, 15 do
        local angle = (i / 15) * math.pi * 2 + menuAnimState.bgRotation
        local r = 0.2 + 0.2 * math.sin(menuAnimState.time * 2 + i)
        local g = 0.3 + 0.2 * math.cos(menuAnimState.time * 1.5 + i)
        local b = 0.8 + 0.2 * math.sin(menuAnimState.time + i)
        love.graphics.setColor(r, g, b, 0.1 + beatPulse)
        
        -- Draw spiral arms
        local startRadius = 100 + beatPulse * 50
        local endRadius = math.min(w, h) * (0.6 + beatPulse)
        for radius = startRadius, endRadius, 20 do
            local x1 = w/2 + math.cos(angle + radius * 0.003) * radius
            local y1 = h/2 + math.sin(angle + radius * 0.003) * radius
            local x2 = w/2 + math.cos(angle + radius * 0.003) * (radius + 15)
            local y2 = h/2 + math.sin(angle + radius * 0.003) * (radius + 15)
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    
    -- Draw energy waves
    love.graphics.setColor(1, 1, 1, 0.1 + beatPulse)
    for i = 0, w, 30 do
        local yOffset = math.sin((i + menuAnimState.waveOffset) * 0.02 + menuAnimState.time) * 40
        local height = 20 + 10 * math.sin(menuAnimState.time * 2 + i * 0.01)
        love.graphics.line(i, h/2 + yOffset, i + 15, h/2 + yOffset + height)
    end
end

local function drawNeonText(text, x, y, width, align, glow)
    local intensity = menuAnimState.neonIntensity
    -- Draw multiple layers for glow effect
    for i = 1, 4 do
        local alpha = (5-i) * 0.15 * intensity * glow
        local offset = i * 2
        love.graphics.setColor(0.5, 0.8, 1, alpha)
        love.graphics.printf(text, x - offset, y, width, align)
        love.graphics.printf(text, x + offset, y, width, align)
        love.graphics.printf(text, x, y - offset, width, align)
        love.graphics.printf(text, x, y + offset, width, align)
    end
    -- Draw main text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, x, y, width, align)
end

local function drawMainMenu()
    local w, h = love.graphics.getDimensions()
    
    -- Update animation state
    local dt = love.timer.getDelta()
    menuAnimState.time = menuAnimState.time + dt
    menuAnimState.beatTime = menuAnimState.beatTime + dt
    menuAnimState.pulseScale = 1 + 0.1 * math.sin(menuAnimState.beatTime * 8)
    menuAnimState.waveOffset = menuAnimState.waveOffset + 150 * dt
    menuAnimState.titleGlow = 0.7 + 0.3 * math.sin(menuAnimState.time * 3)
    menuAnimState.neonIntensity = 0.7 + 0.3 * math.sin(menuAnimState.time * 5)
    menuAnimState.flashAlpha = math.max(0, menuAnimState.flashAlpha - dt * 2)
    updateParticles(dt)
    
    -- Draw animated background
    drawBackground()
    
    -- Draw flash effect
    love.graphics.setColor(1, 1, 1, menuAnimState.flashAlpha)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Draw main panel with dynamic border
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", w/2 - 260, 40, 520, 420)
    
    -- Draw energetic border
    for i = 1, 4 do
        local borderGlow = 0.3 + 0.2 * math.sin(menuAnimState.time * 3 + i)
        love.graphics.setColor(0.5, 0.8, 1, borderGlow * 0.2)
        love.graphics.rectangle("line", w/2 - 260 - i, 40 - i, 520 + i*2, 420 + i*2)
    end
    
    -- Draw title with spectacular effects
    love.graphics.setFont(gameState.fonts.title)
    local titleY = 90
    local titleScale = 1 + 0.05 * math.sin(menuAnimState.beatTime * 8)
    
    love.graphics.push()
    love.graphics.translate(w/2, titleY + 20)
    love.graphics.scale(titleScale, titleScale)
    drawNeonText("Sound Bozo", -w/2, -20, w, "center", menuAnimState.titleGlow)
    love.graphics.pop()
    
    -- Draw menu items with enhanced effects
    love.graphics.setFont(gameState.fonts.medium)
    for i, item in ipairs(gameState.menuItems) do
        local baseY = 250 + (i-1) * 50
        menuAnimState.menuItemOffsets[i] = menuAnimState.menuItemOffsets[i] or 0
        local y = baseY + menuAnimState.menuItemOffsets[i]
        local text = item.text
        
        -- Selected item effects
        if i == gameState.state.selectedMenuItem then
            -- Dynamic scale effect
            local scale = menuAnimState.pulseScale * (1.1 + 0.1 * math.sin(menuAnimState.time * 10))
            love.graphics.push()
            love.graphics.translate(w/2, y + 15)
            love.graphics.scale(scale, scale)
            
            -- Draw spectacular selection effect
            drawNeonText("> " .. text .. " <", -w/2, -15, w, "center", 1.5)
            love.graphics.pop()
            
            -- Generate particles with trails
            if love.math.random() < 0.2 then
                table.insert(menuAnimState.particles, createParticle(
                    w/2 + love.math.random(-150, 150),
                    y + love.math.random(-10, 10),
                    true
                ))
            end
            
            -- Shockwave effect on beat
            if math.sin(menuAnimState.beatTime * 8) > 0.9 then
                table.insert(menuAnimState.shockwaves, createShockwave(w/2, y))
            end
        else
            -- Non-selected items with enhanced animation
            local wobble = math.sin(menuAnimState.time * 2 + i) * 3
            local alpha = 0.5 + 0.2 * math.sin(menuAnimState.time * 3 + i)
            love.graphics.setColor(gameState.colors.uiDark[1], gameState.colors.uiDark[2], gameState.colors.uiDark[3], alpha)
            love.graphics.printf(text, 0, y + wobble, w, "center")
        end
    end
    
    -- Draw particles and effects
    drawParticles()
    
    -- Draw instructions with dynamic effects
    local alpha = 0.6 + 0.4 * math.sin(menuAnimState.time * 2)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setFont(gameState.fonts.small)
    drawNeonText("Use arrow keys to select, Enter to confirm", 0, 500, w, "center", 0.5)
end

local function drawSongSelect()
    local w, h = love.graphics.getDimensions()
    
    -- Update animation state
    local dt = love.timer.getDelta()
    menuAnimState.time = menuAnimState.time + dt
    menuAnimState.beatTime = menuAnimState.beatTime + dt
    menuAnimState.waveOffset = menuAnimState.waveOffset + 150 * dt
    menuAnimState.neonIntensity = 0.7 + 0.3 * math.sin(menuAnimState.time * 5)
    updateParticles(dt)
    
    -- Draw animated background
    drawBackground()
    
    -- Draw main panel with enhanced effects
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", w/2 - 310, 20, 620, 520)
    
    -- Draw energetic border
    for i = 1, 4 do
        local borderGlow = 0.3 + 0.2 * math.sin(menuAnimState.time * 3 + i)
        love.graphics.setColor(0.5, 0.8, 1, borderGlow * 0.2)
        love.graphics.rectangle("line", w/2 - 310 - i, 20 - i, 620 + i*2, 520 + i*2)
    end
    
    -- Draw title with spectacular effects
    love.graphics.setFont(gameState.fonts.title)
    local titleScale = 1 + 0.05 * math.sin(menuAnimState.beatTime * 8)
    love.graphics.push()
    love.graphics.translate(w/2, 60)
    love.graphics.scale(titleScale, titleScale)
    drawNeonText("Song Selection", -w/2, -20, w, "center", 1.2)
    love.graphics.pop()
    
    -- Calculate pagination
    local songs = songManager.getSongs()
    local startIndex = (gameState.state.currentPage - 1) * gameState.state.songsPerPage + 1
    local endIndex = math.min(startIndex + gameState.state.songsPerPage - 1, #songs)
    local totalPages = math.ceil(#songs / gameState.state.songsPerPage)
    
    -- Draw song list with enhanced effects
    love.graphics.setFont(gameState.fonts.medium)
    for i = startIndex, endIndex do
        local song = songs[i]
        local displayIndex = i - startIndex + 1
        local baseY = 140 + (displayIndex-1) * 100
        local y = baseY + math.sin(menuAnimState.time * 2 + displayIndex) * 5
        
        -- Song panel background with enhanced effects
        local panelGlow = 0.5 + 0.3 * math.sin(menuAnimState.time * 2 + displayIndex)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", w/2 - 200, y - 10, 400, 80)
        
        -- Selected song effects
        if i == gameState.state.selectedSong then
            -- Draw energetic border
            for j = 1, 4 do
                local borderGlow = 0.3 + 0.2 * math.sin(menuAnimState.time * 3 + j)
                love.graphics.setColor(0.5, 0.8, 1, borderGlow * 0.2)
                love.graphics.rectangle("line", w/2 - 200 - j, y - 10 - j, 400 + j*2, 80 + j*2)
            end
            
            -- Generate particles
            if love.math.random() < 0.2 then
                table.insert(menuAnimState.particles, createParticle(
                    w/2 + love.math.random(-150, 150),
                    y + love.math.random(0, 80),
                    true
                ))
            end
            
            -- Draw song name with neon effect
            drawNeonText("> " .. song.name .. " <", 0, y + 5, w, "center", 1.2)
            
            -- Draw song details with dynamic effects
            love.graphics.setFont(gameState.fonts.small)
            local detailsAlpha = 0.8 + 0.2 * math.sin(menuAnimState.time * 4)
            love.graphics.setColor(1, 1, 1, detailsAlpha)
            
            -- Enhanced detail display
            local difficultyText = "Difficulty: " .. song.difficulty
            local bpmText = "BPM: " .. song.bpm
            drawNeonText(difficultyText, 0, y + 40, w, "center", 0.8)
            drawNeonText(bpmText, 0, y + 60, w, "center", 0.8)
            
            love.graphics.setFont(gameState.fonts.medium)
        else
            -- Non-selected songs with subtle animation
            local alpha = 0.5 + 0.2 * math.sin(menuAnimState.time * 2 + displayIndex)
            love.graphics.setColor(gameState.colors.uiDark[1], gameState.colors.uiDark[2], gameState.colors.uiDark[3], alpha)
            love.graphics.printf(song.name, 0, y + 5, w, "center")
        end
    end
    
    -- Draw particles and effects
    drawParticles()
    
    -- Draw pagination with enhanced effects
    love.graphics.setFont(gameState.fonts.small)
    
    -- Previous page button
    if gameState.state.currentPage > 1 then
        drawNeonText("< Prev", w/2 - 200, 450, 100, "left", 0.8)
    else
        love.graphics.setColor(gameState.colors.uiDark)
        love.graphics.printf("< Prev", w/2 - 200, 450, 100, "left")
    end
    
    -- Page indicator with dynamic scaling
    local pageScale = 1 + 0.05 * math.sin(menuAnimState.time * 4)
    love.graphics.push()
    love.graphics.translate(w/2, 465)
    love.graphics.scale(pageScale, pageScale)
    drawNeonText(string.format("Page %d/%d", gameState.state.currentPage, totalPages),
        -100, -15, 200, "center", 1)
    love.graphics.pop()
    
    -- Next page button
    if gameState.state.currentPage < totalPages then
        drawNeonText("Next >", w/2 + 100, 450, 100, "right", 0.8)
    else
        love.graphics.setColor(gameState.colors.uiDark)
        love.graphics.printf("Next >", w/2 + 100, 450, 100, "right")
    end
    
    -- Draw instructions with dynamic effects
    drawNeonText("Press Enter to select, Escape to return", 0, 500, w, "center", 0.6)
    drawNeonText("Left/Right to change pages", 0, 520, w, "center", 0.6)
end

return {
    drawMainMenu = drawMainMenu,
    drawSongSelect = drawSongSelect
}