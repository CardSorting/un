local gameState = require('game_state')
local songManager = require('song_manager')

-- Menu music
local menuMusic = love.audio.newSource("assets/Z Fighter's Anthem.mp3", "stream")
menuMusic:setLooping(true)
menuMusic:play()

-- Preview system
local previewSystem = {
    currentPreview = nil,
    lastSelectedSong = nil,
    previewStartTime = 0,
    fadeVolume = 1
}

local function updatePreview(selectedSong, songs)
    if selectedSong ~= previewSystem.lastSelectedSong then
        if previewSystem.currentPreview then
            previewSystem.currentPreview:stop()
            previewSystem.currentPreview = nil
        end
        
        if selectedSong and songs[selectedSong] and songs[selectedSong].music then
            menuMusic:setVolume(0)
            previewSystem.currentPreview = songs[selectedSong].music
            previewSystem.currentPreview:setVolume(1.0)
            previewSystem.currentPreview:play()
            previewSystem.previewStartTime = love.timer.getTime()
        else
            menuMusic:setVolume(1)
        end
        
        previewSystem.lastSelectedSong = selectedSong
    end
end

-- Animation state with enhanced properties
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
    neonIntensity = 0,
    colorCycle = 0,
    energyWaves = {},
    beatPulse = 0,
    selectedParticles = {}
}

-- Enhanced particle system
local function createParticle(x, y, style)
    local angle = love.math.random() * math.pi * 2
    local speed = love.math.random(200, 400)
    local particleTypes = {
        neon = {
            size = love.math.random(3, 6),
            color = {
                love.math.random(0.8, 1),
                love.math.random(0.8, 1),
                1,
                1
            },
            glowSize = love.math.random(2, 4),
            rotationSpeed = love.math.random(-5, 5)
        },
        spark = {
            size = love.math.random(1, 3),
            color = {1, 1, 1, 1},
            glowSize = 1,
            rotationSpeed = love.math.random(-10, 10)
        },
        energy = {
            size = love.math.random(4, 8),
            color = {
                0.5 + love.math.random() * 0.5,
                0.7 + love.math.random() * 0.3,
                1,
                1
            },
            glowSize = love.math.random(3, 6),
            rotationSpeed = love.math.random(-3, 3)
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
        style = style or "neon"
    }
end

local function createShockwave(x, y, color)
    return {
        x = x,
        y = y,
        radius = 0,
        life = 1,
        speed = 800,
        color = color or {1, 1, 1, 1},
        thickness = love.math.random(2, 4)
    }
end

local function createEnergyWave(y)
    return {
        y = y,
        amplitude = love.math.random(20, 40),
        frequency = love.math.random(2, 4),
        speed = love.math.random(100, 200),
        color = {
            0.5 + love.math.random() * 0.5,
            0.7 + love.math.random() * 0.3,
            1,
            0.5
        },
        offset = love.math.random() * math.pi * 2
    }
end

local function updateParticles(dt)
    -- Update color cycle
    menuAnimState.colorCycle = (menuAnimState.colorCycle + dt * 0.5) % (math.pi * 2)
    
    -- Update beat pulse
    menuAnimState.beatPulse = math.max(0, menuAnimState.beatPulse - dt * 4)
    if math.sin(menuAnimState.beatTime * 8) > 0.9 then
        menuAnimState.beatPulse = 1
    end

    -- Update particles with enhanced physics
    for i = #menuAnimState.particles, 1, -1 do
        local p = menuAnimState.particles[i]
        
        -- Add current position to trail with style-specific behavior
        if p.style == "neon" or p.style == "energy" then
            table.insert(p.trail, {x = p.x, y = p.y, life = 1, rotation = p.rotation})
        end
        
        -- Update position with style-specific movement
        if p.style == "energy" then
            p.dy = p.dy + 100 * dt -- Less gravity for energy particles
        else
            p.dy = p.dy + 300 * dt
        end
        
        p.x = p.x + p.dx * dt
        p.y = p.y + p.dy * dt
        p.rotation = p.rotation + p.rotationSpeed * dt
        
        -- Update life with style-specific decay
        local decayRate = p.style == "spark" and 2 or 1.5
        p.life = p.life - dt * decayRate
        p.color[4] = p.life
        
        if p.life <= 0 then
            table.remove(menuAnimState.particles, i)
        end
        
        -- Update trail with enhanced fade
        for j = #p.trail, 1, -1 do
            local t = p.trail[j]
            t.life = t.life - dt * 2.5
            if t.life <= 0 then
                table.remove(p.trail, j)
            end
        end
    end
    
    -- Update shockwaves with enhanced effects
    for i = #menuAnimState.shockwaves, 1, -1 do
        local s = menuAnimState.shockwaves[i]
        s.radius = s.radius + s.speed * dt
        s.life = s.life - dt * 0.8 -- Slower decay for more visible effects
        if s.life <= 0 then
            table.remove(menuAnimState.shockwaves, i)
        end
    end
    
    -- Update energy waves
    for i = #menuAnimState.energyWaves, 1, -1 do
        local w = menuAnimState.energyWaves[i]
        w.offset = w.offset + w.speed * dt
        if w.offset > math.pi * 4 then
            table.remove(menuAnimState.energyWaves, i)
        end
    end
end

local function drawParticles()
    -- Draw trails with enhanced effects
    for _, p in ipairs(menuAnimState.particles) do
        if p.style ~= "spark" then
            for _, t in ipairs(p.trail) do
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], t.life * 0.5)
                love.graphics.push()
                love.graphics.translate(t.x, t.y)
                love.graphics.rotate(t.rotation)
                love.graphics.rectangle("fill", -p.size/2 * t.life, -p.size/2 * t.life, 
                                     p.size * t.life, p.size * t.life)
                love.graphics.pop()
            end
        end
    end
    
    -- Draw particles with enhanced effects
    for _, p in ipairs(menuAnimState.particles) do
        love.graphics.setColor(p.color)
        
        -- Style-specific rendering
        if p.style == "neon" or p.style == "energy" then
            -- Draw glow effect
            for i = 1, 3 do
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.color[4] * (0.3 / i))
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
    
    -- Draw shockwaves with enhanced effects
    for _, s in ipairs(menuAnimState.shockwaves) do
        for i = 1, 3 do
            local alpha = s.life * 0.3 / i
            love.graphics.setColor(s.color[1], s.color[2], s.color[3], alpha)
            love.graphics.setLineWidth(s.thickness * i)
            love.graphics.circle("line", s.x, s.y, s.radius * (1 - 0.1 * i))
        end
    end
    
    -- Draw energy waves
    for _, w in ipairs(menuAnimState.energyWaves) do
        love.graphics.setColor(w.color)
        local points = {}
        for x = 0, love.graphics.getWidth(), 5 do
            local y = w.y + math.sin(x * w.frequency * 0.01 + w.offset) * w.amplitude
            table.insert(points, x)
            table.insert(points, y)
        end
        love.graphics.setLineWidth(3)
        love.graphics.line(points)
    end
end

-- Enhanced background effects
local function drawBackground()
    local w, h = love.graphics.getDimensions()
    menuAnimState.bgRotation = menuAnimState.bgRotation + 0.5
    
    -- Enhanced beat pulse
    local beatPulse = menuAnimState.beatPulse * 0.3
    
    -- Draw dynamic spiral pattern with enhanced effects
    for i = 0, 20 do
        local angle = (i / 20) * math.pi * 2 + menuAnimState.bgRotation
        local r = 0.3 + 0.3 * math.sin(menuAnimState.time * 2 + i)
        local g = 0.4 + 0.3 * math.cos(menuAnimState.time * 1.5 + i)
        local b = 0.9 + 0.1 * math.sin(menuAnimState.time + i)
        love.graphics.setColor(r, g, b, 0.15 + beatPulse)
        
        -- Draw enhanced spiral arms
        local startRadius = 100 + beatPulse * 100
        local endRadius = math.min(w, h) * (0.7 + beatPulse)
        for radius = startRadius, endRadius, 15 do
            local x1 = w/2 + math.cos(angle + radius * 0.004) * radius
            local y1 = h/2 + math.sin(angle + radius * 0.004) * radius
            local x2 = w/2 + math.cos(angle + radius * 0.004) * (radius + 12)
            local y2 = h/2 + math.sin(angle + radius * 0.004) * (radius + 12)
            love.graphics.setLineWidth(2 + beatPulse * 2)
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    
    -- Draw enhanced energy waves
    if love.math.random() < 0.05 then
        table.insert(menuAnimState.energyWaves, createEnergyWave(love.math.random(0, h)))
    end
end

local function drawNeonText(text, x, y, width, align, glow, color)
    local intensity = menuAnimState.neonIntensity
    local cycleColor = color or {
        0.5 + 0.5 * math.sin(menuAnimState.colorCycle),
        0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3),
        1,
        1
    }
    
    -- Draw multiple layers for enhanced glow effect
    for i = 1, 5 do
        local alpha = (6-i) * 0.15 * intensity * glow
        local offset = i * 2
        love.graphics.setColor(cycleColor[1], cycleColor[2], cycleColor[3], alpha)
        love.graphics.printf(text, x - offset, y, width, align)
        love.graphics.printf(text, x + offset, y, width, align)
        love.graphics.printf(text, x, y - offset, width, align)
        love.graphics.printf(text, x, y + offset, width, align)
    end
    
    -- Draw main text with color cycling
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, x, y, width, align)
end

local function drawMainMenu()
    local w, h = love.graphics.getDimensions()
    
    -- Update animation state with enhanced timing
    local dt = love.timer.getDelta()
    menuAnimState.time = menuAnimState.time + dt
    menuAnimState.beatTime = menuAnimState.beatTime + dt
    menuAnimState.pulseScale = 1 + 0.15 * math.sin(menuAnimState.beatTime * 8)
    menuAnimState.waveOffset = menuAnimState.waveOffset + 200 * dt
    menuAnimState.titleGlow = 0.7 + 0.3 * math.sin(menuAnimState.time * 3)
    menuAnimState.neonIntensity = 0.7 + 0.3 * math.sin(menuAnimState.time * 5)
    menuAnimState.flashAlpha = math.max(0, menuAnimState.flashAlpha - dt * 2)
    updateParticles(dt)
    
    -- Reset preview system
    if previewSystem.currentPreview then
        previewSystem.currentPreview:stop()
        previewSystem.currentPreview = nil
        previewSystem.lastSelectedSong = nil
        menuMusic:setVolume(1)
    end
    
    -- Draw enhanced background
    drawBackground()
    
    -- Draw flash effect
    love.graphics.setColor(1, 1, 1, menuAnimState.flashAlpha)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Draw main panel with enhanced effects
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", w/2 - 260, 40, 520, 420, 15, 15)
    
    -- Draw energetic border with enhanced effects
    for i = 1, 5 do
        local borderGlow = 0.4 + 0.3 * math.sin(menuAnimState.time * 3 + i)
        local cycleColor = {
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle + i),
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3 + i),
            1,
            borderGlow * 0.25
        }
        love.graphics.setColor(cycleColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", w/2 - 260 - i*2, 40 - i*2, 520 + i*4, 420 + i*4, 15, 15)
    end
    
    -- Draw title with spectacular effects
    love.graphics.setFont(gameState.fonts.title)
    local titleY = 90
    local titleScale = 1 + 0.08 * math.sin(menuAnimState.beatTime * 8)
    
    love.graphics.push()
    love.graphics.translate(w/2, titleY + 20)
    love.graphics.scale(titleScale, titleScale)
    drawNeonText("Sound Bozo", -w/2, -20, w, "center", menuAnimState.titleGlow * 1.5)
    love.graphics.pop()
    
    -- Generate title particles
    if love.math.random() < 0.1 then
        local particleX = w/2 + love.math.random(-200, 200)
        local particleY = titleY + love.math.random(-20, 20)
        table.insert(menuAnimState.particles, createParticle(particleX, particleY, "energy"))
    end
    
    -- Draw menu items with enhanced effects
    love.graphics.setFont(gameState.fonts.medium)
    for i, item in ipairs(gameState.menuItems) do
        local baseY = 250 + (i-1) * 50
        menuAnimState.menuItemOffsets[i] = menuAnimState.menuItemOffsets[i] or 0
        local y = baseY + menuAnimState.menuItemOffsets[i]
        local text = item.text
        
        -- Selected item effects
        if i == gameState.state.selectedMenuItem then
            -- Dynamic scale effect with enhanced animation
            local scale = menuAnimState.pulseScale * (1.2 + 0.15 * math.sin(menuAnimState.time * 10))
            love.graphics.push()
            love.graphics.translate(w/2, y + 15)
            love.graphics.scale(scale, scale)
            
            -- Draw spectacular selection effect with color cycling
            local cycleColor = {
                0.5 + 0.5 * math.sin(menuAnimState.colorCycle),
                0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3),
                1,
                1
            }
            drawNeonText("> " .. text .. " <", -w/2, -15, w, "center", 2, cycleColor)
            love.graphics.pop()
            
            -- Generate enhanced particles
            if love.math.random() < 0.3 then
                local style = love.math.random() < 0.7 and "neon" or "energy"
                table.insert(menuAnimState.particles, createParticle(
                    w/2 + love.math.random(-200, 200),
                    y + love.math.random(-10, 10),
                    style
                ))
            end
            
            -- Enhanced shockwave effect on beat
            if menuAnimState.beatPulse > 0.9 then
                table.insert(menuAnimState.shockwaves, createShockwave(w/2, y, cycleColor))
            end
        else
            -- Non-selected items with enhanced animation
            local wobble = math.sin(menuAnimState.time * 2 + i) * 4
            local alpha = 0.5 + 0.2 * math.sin(menuAnimState.time * 3 + i)
            love.graphics.setColor(gameState.colors.uiDark[1], gameState.colors.uiDark[2], gameState.colors.uiDark[3], alpha)
            love.graphics.printf(text, 0, y + wobble, w, "center")
        end
    end
    
    -- Draw particles and effects
    drawParticles()
    
    -- Draw instructions with enhanced dynamic effects
    local alpha = 0.6 + 0.4 * math.sin(menuAnimState.time * 2)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setFont(gameState.fonts.small)
    drawNeonText("Use arrow keys to select, Enter to confirm", 0, 500, w, "center", 0.8)
end

local function drawSongSelect()
    local w, h = love.graphics.getDimensions()
    
    -- Update animation state with enhanced timing
    local dt = love.timer.getDelta()
    menuAnimState.time = menuAnimState.time + dt
    menuAnimState.beatTime = menuAnimState.beatTime + dt
    menuAnimState.waveOffset = menuAnimState.waveOffset + 200 * dt
    menuAnimState.neonIntensity = 0.7 + 0.3 * math.sin(menuAnimState.time * 5)
    updateParticles(dt)
    
    -- Update song preview with enhanced transition
    local songs = songManager.getSongs()
    updatePreview(gameState.state.selectedSong, songs)
    
    -- Draw enhanced background
    drawBackground()
    
    -- Draw main panel with enhanced effects
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", w/2 - 310, 20, 620, 520, 15, 15)
    
    -- Draw energetic border with enhanced effects
    for i = 1, 5 do
        local borderGlow = 0.4 + 0.3 * math.sin(menuAnimState.time * 3 + i)
        local cycleColor = {
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle + i),
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3 + i),
            1,
            borderGlow * 0.25
        }
        love.graphics.setColor(cycleColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", w/2 - 310 - i*2, 20 - i*2, 620 + i*4, 520 + i*4, 15, 15)
    end
    
    -- Draw title with spectacular effects
    love.graphics.setFont(gameState.fonts.title)
    local titleScale = 1 + 0.08 * math.sin(menuAnimState.beatTime * 8)
    love.graphics.push()
    love.graphics.translate(w/2, 60)
    love.graphics.scale(titleScale, titleScale)
    drawNeonText("Song Selection", -w/2, -20, w, "center", 1.5)
    love.graphics.pop()
    
    -- Calculate pagination
    local startIndex = (gameState.state.currentPage - 1) * gameState.state.songsPerPage + 1
    local endIndex = math.min(startIndex + gameState.state.songsPerPage - 1, #songs)
    local totalPages = math.ceil(#songs / gameState.state.songsPerPage)
    
    -- Draw song list with enhanced effects
    love.graphics.setFont(gameState.fonts.medium)
    for i = startIndex, endIndex do
        local song = songs[i]
        local displayIndex = i - startIndex + 1
        local baseY = 140 + (displayIndex-1) * 100
        local y = baseY + math.sin(menuAnimState.time * 2 + displayIndex) * 6
        
        -- Song panel background with enhanced effects
        local panelGlow = 0.5 + 0.3 * math.sin(menuAnimState.time * 2 + displayIndex)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", w/2 - 200, y - 10, 400, 80, 10, 10)
        
        -- Selected song effects
        if i == gameState.state.selectedSong then
            -- Draw energetic border with color cycling
            for j = 1, 5 do
                local borderGlow = 0.4 + 0.3 * math.sin(menuAnimState.time * 3 + j)
                local cycleColor = {
                    0.5 + 0.5 * math.sin(menuAnimState.colorCycle + j),
                    0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3 + j),
                    1,
                    borderGlow * 0.25
                }
                love.graphics.setColor(cycleColor)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", w/2 - 200 - j*2, y - 10 - j*2, 400 + j*4, 80 + j*4, 10, 10)
            end
            
            -- Generate enhanced particles
            if love.math.random() < 0.3 then
                local style = love.math.random() < 0.6 and "neon" or "energy"
                table.insert(menuAnimState.particles, createParticle(
                    w/2 + love.math.random(-150, 150),
                    y + love.math.random(0, 80),
                    style
                ))
            end
            
            -- Draw song name with enhanced neon effect
            drawNeonText("> " .. song.name .. " <", 0, y + 5, w, "center", 1.5)
            
            -- Draw song details with enhanced dynamic effects
            love.graphics.setFont(gameState.fonts.small)
            local detailsAlpha = 0.8 + 0.2 * math.sin(menuAnimState.time * 4)
            love.graphics.setColor(1, 1, 1, detailsAlpha)
            
            -- Enhanced detail display with color cycling
            local cycleColor = {
                0.5 + 0.5 * math.sin(menuAnimState.colorCycle),
                0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3),
                1,
                1
            }
            local difficultyText = "Difficulty: " .. song.difficulty
            local bpmText = "BPM: " .. song.bpm
            drawNeonText(difficultyText, 0, y + 40, w, "center", 1, cycleColor)
            drawNeonText(bpmText, 0, y + 60, w, "center", 1, cycleColor)
            
            love.graphics.setFont(gameState.fonts.medium)
        else
            -- Non-selected songs with enhanced animation
            local alpha = 0.5 + 0.2 * math.sin(menuAnimState.time * 2 + displayIndex)
            love.graphics.setColor(gameState.colors.uiDark[1], gameState.colors.uiDark[2], gameState.colors.uiDark[3], alpha)
            love.graphics.printf(song.name, 0, y + 5, w, "center")
        end
    end
    
    -- Draw particles and effects
    drawParticles()
    
    -- Draw pagination with enhanced effects
    love.graphics.setFont(gameState.fonts.small)
    
    -- Previous page button with enhanced effects
    if gameState.state.currentPage > 1 then
        local cycleColor = {
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle),
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3),
            1,
            1
        }
        drawNeonText("< Prev", w/2 - 200, 450, 100, "left", 1, cycleColor)
    else
        love.graphics.setColor(gameState.colors.uiDark)
        love.graphics.printf("< Prev", w/2 - 200, 450, 100, "left")
    end
    
    -- Page indicator with enhanced dynamic scaling
    local pageScale = 1 + 0.08 * math.sin(menuAnimState.time * 4)
    love.graphics.push()
    love.graphics.translate(w/2, 465)
    love.graphics.scale(pageScale, pageScale)
    drawNeonText(string.format("Page %d/%d", gameState.state.currentPage, totalPages),
        -100, -15, 200, "center", 1.2)
    love.graphics.pop()
    
    -- Next page button with enhanced effects
    if gameState.state.currentPage < totalPages then
        local cycleColor = {
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle),
            0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3),
            1,
            1
        }
        drawNeonText("Next >", w/2 + 100, 450, 100, "right", 1, cycleColor)
    else
        love.graphics.setColor(gameState.colors.uiDark)
        love.graphics.printf("Next >", w/2 + 100, 450, 100, "right")
    end
    
    -- Draw instructions with enhanced dynamic effects
    local cycleColor = {
        0.5 + 0.5 * math.sin(menuAnimState.colorCycle),
        0.5 + 0.5 * math.sin(menuAnimState.colorCycle + math.pi/3),
        1,
        1
    }
    drawNeonText("Press Enter to select, Escape to return", 0, 500, w, "center", 0.8, cycleColor)
    drawNeonText("Left/Right to change pages", 0, 520, w, "center", 0.8, cycleColor)
end

return {
    drawMainMenu = drawMainMenu,
    drawSongSelect = drawSongSelect
}