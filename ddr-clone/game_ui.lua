local gameState = require('game_state')

-- Utility functions for animations
local function lerp(a, b, t)
    return a + (b - a) * t * 0.5 -- Further reduced intensity
end

local function createGlowEffect(r, g, b, intensity)
    love.graphics.setColor(r, g, b, 0.08 * intensity) -- Significantly reduced from 0.15
    return function(x, y, width, height, blur)
        for i = blur, 1, -1 do
            love.graphics.rectangle("fill", x - i*0.5, y - i*0.5, width + i*0.8, height + i*0.8) -- Further reduced spread
        end
    end
end

local function pulseEffect(time, min, max, speed)
    return min + (max - min) * math.abs(math.sin(time * speed)) * 0.4 -- Further reduced from 0.6
end

local function drawProgressBar(currentTime, totalTime, colors)
    local width = 800  -- Increased from 400 for 1920x1080
    local height = 15  -- Slightly increased from 10
    local x = love.graphics.getWidth()/2 - width/2
    local y = 80  -- Moved down slightly
    
    -- Glow effect with minimal intensity
    local progress = math.min(currentTime / totalTime, 1)
    local glowIntensity = pulseEffect(love.timer.getTime(), 0.2, 0.5, 3) -- Reduced range
    local glowFunc = createGlowEffect(colors.progressFill[1], colors.progressFill[2], colors.progressFill[3], glowIntensity)
    glowFunc(x, y, width, height, 2) -- Reduced blur
    
    -- Draw background with minimal gradient
    local gradient = love.graphics.newMesh({
        {0, 0, 0, 0, colors.progress[1], colors.progress[2], colors.progress[3], 0.15},
        {width, 0, 1, 0, colors.progress[1], colors.progress[2], colors.progress[3], 0.2},
        {width, height, 1, 1, colors.progress[1], colors.progress[2], colors.progress[3], 0.15},
        {0, height, 0, 1, colors.progress[1], colors.progress[2], colors.progress[3], 0.2}
    }, "fan", "static")
    love.graphics.draw(gradient, x, y)
    
    -- Draw progress with animated fill
    love.graphics.setColor(colors.progressFill)
    love.graphics.rectangle("fill", x, y, width * progress, height)
    
    -- Draw progress markers with minimal opacity
    for i = 0.25, 0.75, 0.25 do
        local markerX = x + width * i
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", markerX - 1, y, 1, height)
    end
end

local function drawSongInfo(songName, colors, fonts)
    local time = love.timer.getTime()
    local scale = pulseEffect(time, 1, 1.02, 2) -- Minimal scale range
    local alpha = pulseEffect(time, 0.9, 1, 3) -- Higher min alpha
    
    love.graphics.setColor(colors.ui[1], colors.ui[2], colors.ui[3], alpha)
    love.graphics.setFont(fonts.medium)
    
    local text = songName
    local textWidth = fonts.medium:getWidth(text)
    local x = love.graphics.getWidth()/2
    local y = 30  -- Adjusted for 1080p
    
    -- Draw minimal glow
    local glowFunc = createGlowEffect(colors.ui[1], colors.ui[2], colors.ui[3], 0.2)
    glowFunc(x - textWidth/2 * scale, y, textWidth * scale, fonts.medium:getHeight() * scale, 5)
    
    -- Draw text with minimal scale
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(scale, scale)
    love.graphics.printf(text, -textWidth/2, 0, textWidth, "center")
    love.graphics.pop()
end

local function drawScorePanel(score, multiplier, colors, fonts)
    local time = love.timer.getTime()
    local x = 100  -- Increased from 50 for better spacing
    local y = 150  -- Increased from 100 for better visibility
    
    -- Draw score with minimal glow
    love.graphics.setFont(fonts.large)
    local scoreText = string.format("%08d", score)
    local glowIntensity = pulseEffect(time, 0.2, 0.5, 2) -- Reduced range
    
    local glowFunc = createGlowEffect(colors.ui[1], colors.ui[2], colors.ui[3], glowIntensity)
    glowFunc(x, y, fonts.large:getWidth(scoreText), fonts.large:getHeight(), 3)
    
    love.graphics.setColor(colors.ui)
    love.graphics.print(scoreText, x, y)
    
    -- Draw multiplier with minimal effects
    local multiplierScale = pulseEffect(time, 1, 1.05, 8) -- Minimal scale range
    local multiplierAlpha = pulseEffect(time, 0.9, 1, 6) -- Higher min alpha
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
    local x = love.graphics.getWidth() - 350  -- Increased from 250 for better spacing
    local y = 150  -- Increased from 100 for better visibility
    local time = love.timer.getTime()
    
    -- Draw panel background with minimal gradient
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x - 10, y - 10, 300, 140, 8, 8)  -- Increased size and rounded corners
    
    -- Draw stats with minimal pulsing
    love.graphics.setFont(fonts.small)
    local stats = {
        {text = "Perfect: " .. state.perfectHits, color = colors.perfect},
        {text = "Good: " .. state.goodHits, color = colors.good},
        {text = "Miss: " .. state.missedHits, color = colors.miss},
        {text = "Max Combo: " .. state.maxCombo, color = colors.ui}
    }
    
    for i, stat in ipairs(stats) do
        local alpha = pulseEffect(time + i * 0.2, 0.9, 1, 3) -- Higher min alpha
        love.graphics.setColor(stat.color[1], stat.color[2], stat.color[3], alpha)
        love.graphics.printf(stat.text, x, y + (i-1) * 30, 280, "left")  -- Increased spacing between stats
    end
end

local function drawHealthBar(health, colors)
    local width = 400  -- Increased from 200 for better visibility
    local height = 25  -- Increased from 18 for better visibility
    local x = love.graphics.getWidth() - width - 100  -- Adjusted position
    local y = 80  -- Adjusted to align with progress bar
    local time = love.timer.getTime()
    
    -- Draw background with minimal gradient
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, width, height, 4, 4)  -- Slightly larger rounded corners
    
    -- Calculate health color with smoother transition
    local healthColor = {
        lerp(colors.healthLow[1], colors.health[1], health/100),
        lerp(colors.healthLow[2], colors.health[2], health/100),
        lerp(colors.healthLow[3], colors.health[3], health/100),
        0.85 -- Slightly reduced opacity
    }
    
    -- Draw health with minimal glow
    local glowIntensity = pulseEffect(time, 0.2, 0.5, 4) -- Reduced range
    local glowFunc = createGlowEffect(healthColor[1], healthColor[2], healthColor[3], glowIntensity)
    glowFunc(x, y, width * (health/100), height, 2)
    
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", x, y, width * (health/100), height, 4, 4)
    
    -- Draw health segments with minimal opacity
    for i = 1, 9 do
        local segX = x + (width * (i/10))
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.rectangle("fill", segX - 1, y, 1, height)
    end
end

local function drawCombo(combo, scale, colors, fonts)
    if combo < 2 then return end
    
    local time = love.timer.getTime()
    local pulseScale = scale * pulseEffect(time, 0.98, 1.03, 8) -- Minimal scale range
    local alpha = pulseEffect(time, 0.9, 1, 6) -- Higher min alpha
    
    love.graphics.setColor(colors.combo[1], colors.combo[2], colors.combo[3], alpha)
    love.graphics.setFont(fonts.combo)
    
    local text = combo .. " COMBO"
    local textWidth = fonts.combo:getWidth(text)
    local x = love.graphics.getWidth()/2
    local y = love.graphics.getHeight() - 200  -- Adjusted for 1080p
    
    -- Draw minimal glow
    local glowFunc = createGlowEffect(colors.combo[1], colors.combo[2], colors.combo[3], 0.3)
    glowFunc(x - textWidth/2 * pulseScale, y, textWidth * pulseScale, fonts.combo:getHeight() * pulseScale, 6)
    
    -- Draw combo text with minimal scale
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(pulseScale, pulseScale)
    love.graphics.printf(text, -textWidth/2, 0, textWidth, "center")
    love.graphics.pop()
end

local function drawHitRating(rating, colors, fonts)
    local time = love.timer.getTime()
    local scale = pulseEffect(time, 1, 1.05, 10) -- Minimal scale range
    local alpha = pulseEffect(time, 0.9, 1, 8) -- Higher min alpha
    
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
    local y = love.graphics.getHeight() - 300  -- Adjusted for 1080p
    
    -- Draw minimal glow
    local glowFunc = createGlowEffect(color[1], color[2], color[3], 0.25)
    glowFunc(x - textWidth/2 * scale, y, textWidth * scale, fonts.large:getHeight() * scale, 5)
    
    -- Draw rating text with minimal effects
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