local gameState = require('game_state')
local animations = require('menu/menu_animations')
local renderer = require('menu/menu_renderer')
local particles = require('menu/menu_particles')
local menuAudio = require('menu/menu_audio')
local songManager = require('song_manager')

local menuUI = {}

function menuUI.init()
    menuAudio.init()
    animations.reset()
    particles.clear()
end

function menuUI.drawMainMenu()
    local w, h = love.graphics.getDimensions()
    
    -- Update animations
    local dt = love.timer.getDelta()
    animations.update(dt)
    particles.update(dt, animations.state)
    
    -- Reset preview system
    menuAudio.resetPreview()
    
    -- Draw background and effects
    renderer.drawBackground()
    renderer.drawFlashEffect()
    
    -- Draw main panel (increased size for 1920x1080)
    renderer.drawPanel(w/2 - 400, 100, 800, 600, 20)
    
    -- Draw title (adjusted position and scale)
    love.graphics.setFont(gameState.fonts.header)
    local titleY = 180
    local titleScale = animations.getPulseScale(1.2, 0.08, 8)  -- Increased base scale
    
    love.graphics.push()
    love.graphics.translate(w/2, titleY + 20)
    love.graphics.scale(titleScale, titleScale)
    renderer.drawNeonText("Sound Bozo", -w/2, -20, w, "center", animations.state.titleGlow * 1.5)
    love.graphics.pop()
    
    -- Generate title particles
    if love.math.random() < 0.1 then
        particles.spawn(
            w/2 + love.math.random(-300, 300),  -- Increased spread
            titleY + love.math.random(-20, 20),
            "rainbow"
        )
    end
    
    -- Draw menu items (adjusted spacing and position)
    love.graphics.setFont(gameState.fonts.neon)
    for i, item in ipairs(gameState.menuItems) do
        local baseY = 380 + (i-1) * 70  -- Increased spacing between items
        animations.state.menuItemOffsets[i] = animations.state.menuItemOffsets[i] or 0
        local y = baseY + animations.state.menuItemOffsets[i]
        
        if i == gameState.state.selectedMenuItem then
            -- Draw selected item with effects
            local scale = animations.getPulseScale(1.3, 0.15, 10)  -- Increased base scale
            love.graphics.push()
            love.graphics.translate(w/2, y + 15)
            love.graphics.scale(scale, scale)
            renderer.drawNeonText("> " .. item.text .. " <", -w/2, -15, w, "center", 2, animations.getRainbowColor())
            love.graphics.pop()
            
            -- Generate particles
            if love.math.random() < 0.3 then
                particles.spawn(
                    w/2 + love.math.random(-300, 300),  -- Increased spread
                    y + love.math.random(-10, 10),
                    love.math.random() < 0.6 and "rainbow" or "energy"
                )
            end
            
            -- Shockwave effect on beat
            if animations.state.beatPulse > 0.9 then
                particles.spawnShockwave(w/2, y, animations.getRainbowColor())
            end
        else
            -- Draw non-selected items
            local wobble = math.sin(animations.state.time * 2 + i) * 4
            local alpha = 0.5 + 0.2 * math.sin(animations.state.time * 3 + i)
            love.graphics.setColor(gameState.colors.uiDark[1], gameState.colors.uiDark[2], gameState.colors.uiDark[3], alpha)
            love.graphics.printf(item.text, 0, y + wobble, w, "center")
        end
    end
    
    -- Draw particles
    particles.draw()
    
    -- Draw instructions (adjusted position)
    love.graphics.setFont(gameState.fonts.small)
    renderer.drawNeonText(
        "Use arrow keys to select, Enter to confirm",
        0, h - 100, w, "center",
        0.8,
        animations.getRainbowColor(math.pi)
    )
end

function menuUI.drawSongSelect()
    local w, h = love.graphics.getDimensions()
    
    -- Update animations
    local dt = love.timer.getDelta()
    animations.update(dt)
    particles.update(dt, animations.state)
    
    -- Update song preview
    local songs = songManager.getSongs()
    menuAudio.updatePreview(gameState.state.selectedSong, songs)
    
    -- Draw background and effects
    renderer.drawBackground()
    
    -- Draw main panel (increased size for 1920x1080)
    renderer.drawPanel(w/2 - 500, 50, 1000, 800, 20)
    
    -- Draw title
    love.graphics.setFont(gameState.fonts.header)
    local titleScale = animations.getPulseScale(1.2, 0.08, 8)  -- Increased base scale
    love.graphics.push()
    love.graphics.translate(w/2, 120)
    love.graphics.scale(titleScale, titleScale)
    renderer.drawNeonText("Song Selection", -w/2, -20, w, "center", 1.5, animations.getRainbowColor())
    love.graphics.pop()
    
    -- Calculate pagination
    local startIndex = (gameState.state.currentPage - 1) * gameState.state.songsPerPage + 1
    local endIndex = math.min(startIndex + gameState.state.songsPerPage - 1, #songs)
    local totalPages = math.ceil(#songs / gameState.state.songsPerPage)
    
    -- Draw song list (adjusted sizes and spacing)
    love.graphics.setFont(gameState.fonts.neon)
    for i = startIndex, endIndex do
        local song = songs[i]
        local displayIndex = i - startIndex + 1
        local baseY = 220 + (displayIndex-1) * 120  -- Increased spacing
        local y = baseY + math.sin(animations.state.time * 2 + displayIndex) * 6
        
        renderer.drawSongPanel(
            song,
            w/2 - 400, y - 10, 800, 100,  -- Increased panel size
            i == gameState.state.selectedSong,
            animations.state.time
        )
        
        -- Generate particles for selected song
        if i == gameState.state.selectedSong and love.math.random() < 0.3 then
            particles.spawn(
                w/2 + love.math.random(-300, 300),  -- Increased spread
                y + love.math.random(0, 100),
                love.math.random() < 0.6 and "rainbow" or "energy"
            )
        end
    end
    
    -- Draw particles
    particles.draw()
    
    -- Draw pagination (adjusted positions)
    love.graphics.setFont(gameState.fonts.small)
    
    -- Previous page button
    if gameState.state.currentPage > 1 then
        renderer.drawNeonText("< Prev", w/2 - 400, h - 150, 200, "left", 1, animations.getRainbowColor())
    else
        love.graphics.setColor(gameState.colors.uiDark)
        love.graphics.printf("< Prev", w/2 - 400, h - 150, 200, "left")
    end
    
    -- Page indicator
    local pageScale = animations.getPulseScale(1, 0.08, 4)
    love.graphics.push()
    love.graphics.translate(w/2, h - 135)
    love.graphics.scale(pageScale, pageScale)
    renderer.drawNeonText(
        string.format("Page %d/%d", gameState.state.currentPage, totalPages),
        -100, -15, 200, "center", 1.2
    )
    love.graphics.pop()
    
    -- Next page button
    if gameState.state.currentPage < totalPages then
        renderer.drawNeonText("Next >", w/2 + 200, h - 150, 200, "right", 1, animations.getRainbowColor())
    else
        love.graphics.setColor(gameState.colors.uiDark)
        love.graphics.printf("Next >", w/2 + 200, h - 150, 200, "right")
    end
    
    -- Draw instructions (adjusted positions)
    renderer.drawNeonText(
        "Press Enter to select, Escape to return",
        0, h - 100, w, "center",
        0.8,
        animations.getRainbowColor(math.pi)
    )
    renderer.drawNeonText(
        "Left/Right to change pages",
        0, h - 70, w, "center",
        0.8,
        animations.getRainbowColor(math.pi)
    )
end

function menuUI.cleanup()
    menuAudio.cleanup()
    animations.reset()
    particles.clear()
end

return menuUI