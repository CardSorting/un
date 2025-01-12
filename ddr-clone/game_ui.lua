local gameState = require('game_state')

-- Utility functions for animations
local function lerp(a, b, t)
    return a + (b - a) * t * 0.7 -- Reduced intensity
end

local function createGlowEffect(r, g, b, intensity)
    love.graphics.setColor(r, g, b, 0.15 * intensity) -- Reduced from 0.3
    return function(x, y, width, height, blur)
        for i = blur, 1, -1 do
            love.graphics.rectangle("fill", x - i*0.7, y - i*0.7, width + i, height + i) -- Reduced spread
        end
    end
end

local function pulseEffect(time, min, max, speed)
    return min + (max - min) * math.abs(math.sin(time * speed)) * 0.6 -- Reduced intensity
end

local function drawProgressBar(currentTime, totalTime, colors)
    local width = 400
    local height = 12  -- Slightly reduced height
    local x = love.graphics.getWidth()/2 - width/2
    local y = 50
    
    -- Glow effect with reduced intensity
    local progress = math.min(currentTime / totalTime, 1)
    local glowIntensity = pulseEffect(love.timer.getTime(), 0.3, 0.7, 3) -- Reduced range
    local glowFunc = createGlowEffect(colors.progressFill[1], colors.progressFill[2], colors.progressFill[3], glowIntensity)
    glowFunc(x, y, width, height, 3) -- Reduced blur
    
    -- Draw background with subtle gradient
    local gradient = love.graphics.newMesh({
        {0, 0, 0, 0, colors.progress[1], colors.progress[2], colors.progress[3], 0.2},
        {width, 0, 1, 0, colors.progress[1], colors.progress[2], colors.progress[3], 0.3},
        {width, height, 1, 1, colors.progress[1], colors.progress[2], colors.progress[3], 0.2},
        {0, height, 0, 1, colors.progress[1], colors.progress[2], colors.progress[3], 0.3}
    }, "fan", "static")
    love.graphics.draw(gradient, x, y)
    
    -- Draw progress with animated fill
    love.graphics.setColor(colors.progressFill)
    love.graphics.rectangle("fill", x, y, width * progress, height)
    
    -- Draw progress markers with reduced opacity
    for i = 0.25, 0.75, 0.25 do
        local markerX = x + width * i
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("fill", markerX - 1, y, 1, height)
    end
end

local function drawSongInfo(songName, colors, fonts)
    local time = love.timer.getTime()
    local scale = pulseEffect(time, 1, 1.03, 2) -- Reduced scale range
    local alpha = pulseEffect(time, 0.85, 1, 3) -- Increased min alpha
    
    love.graphics.setColor(colors.ui[1], colors.ui[2], colors.ui[3], alpha)
    love.graphics.setFont(fonts.medium)
    
    local text = songName
    local textWidth = fonts.medium:getWidth(text)
    local x = love.graphics.getWidth()/2
    local y = 20
    
    -- Draw glow with reduced intensity
    local glowFunc = createGlowEffect(colors.ui[1], colors.ui[2], colors.ui[3], 0.3)
    glowFunc(x - textWidth/2 * scale, y, textWidth * scale, fonts.medium:getHeight() * scale, 7)
    
    -- Draw text with subtle scale
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
    
    -- Draw score with subtle glow
    love.graphics.setFont(fonts.large)
    local scoreText = string.format("%08d", score)
    local glowIntensity = pulseEffect(time, 0.3, 0.7, 2) -- Reduced range
    
    local glowFunc = createGlowEffect(colors.ui[1], colors.ui[2], colors.ui[3], glowIntensity)
    glowFunc(x, y, fonts.large:getWidth(scoreText), fonts.large:getHeight(), 5)
    
    love.graphics.setColor(colors.ui)
    love.graphics.print(scoreText, x, y)
    
    -- Draw multiplier with reduced effects
    local multiplierScale = pulseEffect(time, 1, 1.1, 8) -- Reduced scale range
    local multiplierAlpha = pulseEffect(time, 0.8, 1, 6) -- Increased min alpha
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
    
    -- Draw panel background with subtle gradient
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x - 10, y - 10, 220, 120, 8, 8)
    
    -- Draw stats with subtle pulsing
    love.graphics.setFont(fonts.small)
    local stats = {
        {text = "Perfect: " .. state.perfectHits, color = colors.perfect},
        {text = "Good: " .. state.goodHits, color = colors.good},
        {text = "Miss: " .. state.missedHits, color = colors.miss},
        {text = "Max Combo: " .. state.maxCombo, color = colors.ui}
    }
    
    for i, stat in ipairs(stats) do
        local alpha = pulseEffect(time + i * 0.2, 0.8, 1, 3) -- Increased min alpha
        love.graphics.setColor(stat.color[1], stat.color[2], stat.color[3], alpha)
        love.graphics.printf(stat.text, x, y + (i-1) * 25, 200, "left")
    end
end

local function drawHealthBar(health, colors)
    local width = 200
    local height = 20
    local x = love.graphics.getWidth() - width - 50
    local y = 50
    local time = love.timer.getTime()
    
    -- Draw background with subtle gradient
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x, y, width, height, 4, 4)
    
    -- Calculate health color with smoother transition
    local healthColor = {
        lerp(colors.healthLow[1], colors.health[1], health/100),
        lerp(colors.healthLow[2], colors.health[2], health/100),
        lerp(colors.healthLow[3], colors.health[3], health/100),
        0.9 -- Slightly reduced opacity
    }
    
    -- Draw health with subtle glow
    local glowIntensity = pulseEffect(time, 0.3, 0.7, 4) -- Reduced range
    local glowFunc = createGlowEffect(healthColor[1], healthColor[2], healthColor[3], glowIntensity)
    glowFunc(x, y, width * (health/100), height, 3)
    
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", x, y, width * (health/100), height, 4, 4)
    
    -- Draw health segments with reduced opacity
    for i = 1, 9 do
        local segX = x + (width * (i/10))
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.rectangle("fill", segX - 1, y, 1, height)
    end
end

local function drawCombo(combo, scale, colors, fonts)
    if combo < 2 then return end
    
    local time = love.timer.getTime()
    local pulseScale = scale * pulseEffect(time, 0.95, 1.05, 8) -- Reduced scale range
    local alpha = pulseEffect(time, 0.85, 1, 6) -- Increased min alpha
    
    love.graphics.setColor(colors.combo[1], colors.combo[2], colors.combo[3], alpha)
    love.graphics.setFont(fonts.combo)
    
    local text = combo .. " COMBO"
    local textWidth = fonts.combo:getWidth(text)
    local x = love.graphics.getWidth()/2
    local y = love.graphics.getHeight() - 150
    
    -- Draw glow with reduced intensity
    local glowFunc = createGlowEffect(colors.combo[1], colors.combo[2], colors.combo[3], 0.5)
    glowFunc(x - textWidth/2 * pulseScale, y, textWidth * pulseScale, fonts.combo:getHeight() * pulseScale, 10)
    
    -- Draw combo text with subtle scale
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(pulseScale, pulseScale)
    love.graphics.printf(text, -textWidth/2, 0, textWidth, "center")
    love.graphics.pop()
end

local function drawHitRating(rating, colors, fonts)
    local time = love.timer.getTime()
    local scale = pulseEffect(time, 1, 1.1, 10) -- Reduced scale range
    local alpha = pulseEffect(time, 0.8, 1, 8) -- Increased min alpha
    
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
    
    -- Draw glow with reduced intensity
    local glowFunc = createGlowEffect(color[1], color[2], color[3], 0.4)
    glowFunc(x - textWidth/2 * scale, y, textWidth * scale, fonts.large:getHeight() * scale, 8)
    
    -- Draw rating text with subtle effects
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