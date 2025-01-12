local gameState = require('game_state')
local animations = require('menu/menu_animations')

local renderer = {}

function renderer.drawNeonText(text, x, y, width, align, glow, color)
    local intensity = animations.state.neonIntensity * 0.6 -- Reduced intensity
    local cycleColor = color or animations.getNeonColor()
    
    -- Draw multiple layers for enhanced glow effect (reduced layers and opacity)
    for i = 1, 3 do -- Reduced from 5 to 3 layers
        local alpha = (4-i) * 0.1 * intensity * glow -- Reduced alpha multiplier
        local offset = i * 1.5 -- Reduced offset
        love.graphics.setColor(cycleColor[1], cycleColor[2], cycleColor[3], alpha)
        love.graphics.printf(text, x - offset, y, width, align)
        love.graphics.printf(text, x + offset, y, width, align)
        love.graphics.printf(text, x, y - offset, width, align)
        love.graphics.printf(text, x, y + offset, width, align)
    end
    
    -- Draw main text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, x, y, width, align)
end

function renderer.drawBackground()
    local w, h = love.graphics.getDimensions()
    local beatPulse = animations.getBeatPulse() * 0.7 -- Reduced pulse intensity
    
    -- Draw dynamic spiral pattern with reduced opacity
    for i = 0, 20 do
        local angle = (i / 20) * math.pi * 2 + animations.state.bgRotation
        local phase = animations.state.time * 2 + i
        local neonColor = gameState.colors.neon
        local r = animations.lerp(neonColor.blue[1], neonColor.pink[1], (math.sin(phase) + 1) * 0.5)
        local g = animations.lerp(neonColor.blue[2], neonColor.pink[2], (math.sin(phase + math.pi/3) + 1) * 0.5)
        local b = animations.lerp(neonColor.blue[3], neonColor.pink[3], (math.sin(phase + math.pi*2/3) + 1) * 0.5)
        
        love.graphics.setColor(r, g, b, 0.1 + beatPulse * 0.7) -- Reduced base opacity
        
        -- Draw spiral arms
        local startRadius = 100 + beatPulse * 70 -- Reduced pulse effect
        local endRadius = math.min(w, h) * (0.6 + beatPulse * 0.7) -- Reduced size and pulse
        for radius = startRadius, endRadius, 15 do
            local x1 = w/2 + math.cos(angle + radius * 0.004) * radius
            local y1 = h/2 + math.sin(angle + radius * 0.004) * radius
            local x2 = w/2 + math.cos(angle + radius * 0.004) * (radius + 12)
            local y2 = h/2 + math.sin(angle + radius * 0.004) * (radius + 12)
            love.graphics.setLineWidth(1.5 + beatPulse) -- Reduced line width
            love.graphics.line(x1, y1, x2, y2)
        end
    end
end

function renderer.drawPanel(x, y, width, height, cornerRadius)
    -- Draw main panel with slightly increased opacity for better contrast
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", x, y, width, height, cornerRadius, cornerRadius)
    
    -- Draw energetic border with reduced glow
    for i = 1, 3 do -- Reduced from 5 to 3 layers
        local borderGlow = 0.3 + 0.2 * math.sin(animations.state.time * 3 + i) -- Reduced glow
        local cycleColor = animations.getNeonColor(i)
        cycleColor[4] = borderGlow * 0.15 -- Reduced opacity
        
        love.graphics.setColor(cycleColor)
        love.graphics.setLineWidth(1.5) -- Reduced line width
        love.graphics.rectangle("line", 
            x - i*1.5, y - i*1.5, -- Reduced border spread
            width + i*3, height + i*3, 
            cornerRadius, cornerRadius)
    end
end

function renderer.drawSongPanel(song, x, y, width, height, selected, animTime)
    -- Draw panel background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x, y, width, height, 10, 10)
    
    if selected then
        -- Draw energetic border with reduced color cycling
        for j = 1, 3 do -- Reduced from 5 to 3 layers
            local borderGlow = 0.3 + 0.2 * math.sin(animTime * 3 + j) -- Reduced glow
            local cycleColor = animations.getRainbowColor(j)
            cycleColor[4] = borderGlow * 0.15 -- Reduced opacity
            
            love.graphics.setColor(cycleColor)
            love.graphics.setLineWidth(1.5) -- Reduced line width
            love.graphics.rectangle("line", 
                x - j*1.5, y - j*1.5, -- Reduced border spread
                width + j*3, height + j*3, 
                10, 10)
        end
        
        -- Draw song details with reduced effects
        local cycleColor = animations.getRainbowColor(math.pi)
        renderer.drawNeonText(song.name, 0, y + 5, love.graphics.getWidth(), "center", 1.2)
        
        love.graphics.setFont(gameState.fonts.small)
        renderer.drawNeonText("Difficulty: " .. song.difficulty, 
            0, y + 40, love.graphics.getWidth(), "center", 0.6, cycleColor)
        renderer.drawNeonText("BPM: " .. song.bpm,
            0, y + 60, love.graphics.getWidth(), "center", 0.6, cycleColor)
    else
        -- Non-selected songs with reduced animation
        local alpha = 0.4 + 0.15 * math.sin(animTime * 2) -- Reduced animation range
        love.graphics.setColor(gameState.colors.uiDark[1], 
            gameState.colors.uiDark[2], 
            gameState.colors.uiDark[3], alpha)
        love.graphics.printf(song.name, 0, y + 5, love.graphics.getWidth(), "center")
    end
end

function renderer.drawFlashEffect()
    if animations.state.flashAlpha > 0 then
        love.graphics.setColor(1, 1, 1, animations.state.flashAlpha * 0.7) -- Reduced flash intensity
        love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    end
end

return renderer