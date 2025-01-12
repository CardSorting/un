local gameState = require('game_state')

-- Utility functions for animations
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function createGlowEffect(r, g, b, intensity)
    love.graphics.setColor(r, g, b, 0.3 * intensity)
    return function(x, y, width, height, blur)
        for i = blur, 1, -1 do
            love.graphics.rectangle("fill", x - i, y - i, width + i * 2, height + i * 2)
        end
    end
end

local function pulseEffect(time, min, max, speed)
    return min + (max - min) * math.abs(math.sin(time * speed))
end

local function drawProgressBar(currentTime, totalTime, colors)
    local width = 400
    local height = 15  -- Increased height
    local x = love.graphics.getWidth()/2 - width/2
    local y = 50
    
    -- Glow effect
    local progress = math.min(currentTime / totalTime, 1)
    local glowIntensity = pulseEffect(love.timer.getTime(), 0.5, 1, 3)
    createGlowEffect(colors.progressFill[1], colors.progressFill[2], colors.progressFill[3], glowIntensity)
        (x, y, width, height, 5)
    
    -- Draw background with gradient
    local gradient = love.graphics.newMesh({
        {0, 0, 0, 0, colors.progress[1], colors.progress[2], colors.progress[3], 0.3},
        {width, 0, 1, 0, colors.progress[1], colors.progress[2], colors.progress[3], 0.5},
        {width, height, 1, 1, colors.progress[1], colors.progress[2], colors.progress[3], 0.3},
        {0, height, 0, 1, colors.progress[1], colors.progress[2], colors.progress[3], 0.5}
    }, "fan", "static")
    love.graphics.draw(gradient, x, y)
    
    -- Draw progress with animated fill
    love.graphics.setColor(colors.progressFill)
    love.graphics.rectangle("fill", x, y, width * progress, height)
    
    -- Draw progress markers
    for i = 0.25, 0.75, 0.25 do
        local markerX = x + width * i
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", markerX - 1, y, 2, height)
    end
end

local function drawSongInfo(songName, colors, fonts)
    local time = love.timer.getTime()
    local scale = pulseEffect(time, 1, 1.05, 2)
    local alpha = pulseEffect(time, 0.8, 1, 3)
    
    love.graphics.setColor(colors.ui[1], colors.ui[2], colors.ui[3], alpha)
    love.graphics.setFont(fonts.medium)
    
    local text = songName
    local textWidth = fonts.medium:getWidth(text)
    local x = love.graphics.getWidth()/2
    local y = 20
    
    -- Draw glow
    createGlowEffect(colors.ui[1], colors.ui[2], colors.ui[3], 0.5)
        (x - textWidth/2 * scale, y, textWidth * scale, fonts.medium:getHeight() * scale, 10)
    
    -- Draw text with scale
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(scale, scale)
    love.graphics.printf(text, -textWidth/2, 0, textWidth, "center")
    love.graphics.pop()
end

local function drawScorePanel(score, multiplier, colors, fonts)
    local time = love.timer.getTime()
    local x = 50
    local y = 100
    
    -- Draw score with glow effect
    love.graphics.setFont(fonts.large)
    local scoreText = string.format("%08d", score)
    local glowIntensity = pulseEffect(time, 0.5, 1, 2)
    
    createGlowEffect(colors.ui[1], colors.ui[2], colors.ui[3], glowIntensity)
        (x, y, fonts.large:getWidth(scoreText), fonts.large:getHeight(), 8)
    
    love.graphics.setColor(colors.ui)
    love.graphics.print(scoreText, x, y)
    
    -- Draw multiplier with dynamic effects
    local multiplierScale = pulseEffect(time, 1, 1.2, 8)
    local multiplierAlpha = pulseEffect(time, 0.7, 1, 6)
    love.graphics.setColor(colors.multiplier[1], colors.multiplier[2], colors.multiplier[3], multiplierAlpha)
    love.graphics.setFont(fonts.multiplier)
    
    local multiplierText = "x" .. multiplier
    love.graphics.push()
    love.graphics.translate(x + 20, y + 60)
    love.graphics.scale(multiplierScale, multiplierScale)
    love.graphics.print(multiplierText, 0, 0)
    love.graphics.pop()
end

local function drawStatsPanel(state, colors, fonts)
    local x = love.graphics.getWidth() - 250
    local y = 100
    local time = love.timer.getTime()
    
    -- Draw panel background with gradient
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x - 10, y - 10, 220, 120, 10, 10)
    
    -- Draw stats with pulsing effects
    love.graphics.setFont(fonts.small)
    local stats = {
        {text = "Perfect: " .. state.perfectHits, color = colors.perfect},
        {text = "Good: " .. state.goodHits, color = colors.good},
        {text = "Miss: " .. state.missedHits, color = colors.miss},
        {text = "Max Combo: " .. state.maxCombo, color = colors.ui}
    }
    
    for i, stat in ipairs(stats) do
        local alpha = pulseEffect(time + i * 0.2, 0.7, 1, 3)
        love.graphics.setColor(stat.color[1], stat.color[2], stat.color[3], alpha)
        love.graphics.printf(stat.text, x, y + (i-1) * 25, 200, "left")
    end
end

local function drawHealthBar(health, colors)
    local width = 200
    local height = 25  -- Increased height
    local x = love.graphics.getWidth() - width - 50
    local y = 50
    local time = love.timer.getTime()
    
    -- Draw background with gradient
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Calculate health color based on current health
    local healthColor = {
        lerp(colors.healthLow[1], colors.health[1], health/100),
        lerp(colors.healthLow[2], colors.health[2], health/100),
        lerp(colors.healthLow[3], colors.health[3], health/100),
        1
    }
    
    -- Draw health with glow effect
    local glowIntensity = pulseEffect(time, 0.5, 1, 4)
    createGlowEffect(healthColor[1], healthColor[2], healthColor[3], glowIntensity)
        (x, y, width * (health/100), height, 5)
    
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", x, y, width * (health/100), height, 5, 5)
    
    -- Draw health segments
    for i = 1, 9 do
        local segX = x + (width * (i/10))
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", segX - 1, y, 2, height)
    end
end

local function drawCombo(combo, scale, colors, fonts)
    if combo < 2 then return end
    
    local time = love.timer.getTime()
    local pulseScale = scale * pulseEffect(time, 0.9, 1.1, 8)
    local alpha = pulseEffect(time, 0.8, 1, 6)
    
    love.graphics.setColor(colors.combo[1], colors.combo[2], colors.combo[3], alpha)
    love.graphics.setFont(fonts.combo)
    
    local text = combo .. " COMBO"
    local textWidth = fonts.combo:getWidth(text)
    local x = love.graphics.getWidth()/2
    local y = love.graphics.getHeight() - 150
    
    -- Draw glow effect
    createGlowEffect(colors.combo[1], colors.combo[2], colors.combo[3], 0.7)
        (x - textWidth/2 * pulseScale, y, textWidth * pulseScale, fonts.combo:getHeight() * pulseScale, 15)
    
    -- Draw combo text with scale effect
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(pulseScale, pulseScale)
    love.graphics.printf(text, -textWidth/2, 0, textWidth, "center")
    love.graphics.pop()
end

local function drawHitRating(rating, colors, fonts)
    local time = love.timer.getTime()
    local scale = pulseEffect(time, 1, 1.2, 10)
    local alpha = pulseEffect(time, 0.7, 1, 8)
    
    love.graphics.setFont(fonts.large)
    local color
    if rating == "Perfect" then
        color = colors.perfect
    elseif rating == "Good" then
        color = colors.good
    else
        color = colors.miss
    end
    
    local textWidth = fonts.large:getWidth(rating)
    local x = love.graphics.getWidth()/2
    local y = love.graphics.getHeight() - 200
    
    -- Draw glow effect
    createGlowEffect(color[1], color[2], color[3], 0.6)
        (x - textWidth/2 * scale, y, textWidth * scale, fonts.large:getHeight() * scale, 12)
    
    -- Draw rating text with effects
    love.graphics.setColor(color[1], color[2], color[3], alpha)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(scale, scale)
    love.graphics.printf(rating, -textWidth/2, 0, textWidth, "center")
    love.graphics.pop()
end

return {
    drawProgressBar = drawProgressBar,
    drawSongInfo = drawSongInfo,
    drawScorePanel = drawScorePanel,
    drawStatsPanel = drawStatsPanel,
    drawHealthBar = drawHealthBar,
    drawCombo = drawCombo,
    drawHitRating = drawHitRating
}