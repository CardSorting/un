local gameState = require('game_state')

local function drawProgressBar(currentTime, totalTime, colors)
    local width = 400
    local height = 10
    local x = love.graphics.getWidth()/2 - width/2
    local y = 50
    
    -- Draw background
    love.graphics.setColor(colors.progress)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Draw progress
    love.graphics.setColor(colors.progressFill)
    local progress = math.min(currentTime / totalTime, 1)
    love.graphics.rectangle("fill", x, y, width * progress, height)
end

local function drawSongInfo(songName, colors, fonts)
    love.graphics.setColor(colors.ui)
    love.graphics.setFont(fonts.medium)
    love.graphics.printf(songName, 0, 20, love.graphics.getWidth(), "center")
end

local function drawScorePanel(score, multiplier, colors, fonts)
    -- Draw score
    love.graphics.setColor(colors.ui)
    love.graphics.setFont(fonts.large)
    love.graphics.printf(string.format("%08d", score), 50, 100, 200, "left")
    
    -- Draw multiplier
    love.graphics.setColor(colors.multiplier)
    love.graphics.setFont(fonts.multiplier)
    love.graphics.printf("x" .. multiplier, 50, 140, 100, "left")
end

local function drawStatsPanel(state, colors, fonts)
    local x = love.graphics.getWidth() - 250
    local y = 100
    
    love.graphics.setColor(colors.ui)
    love.graphics.setFont(fonts.small)
    
    -- Draw hit stats
    love.graphics.printf("Perfect: " .. state.perfectHits, x, y, 200, "left")
    love.graphics.printf("Good: " .. state.goodHits, x, y + 25, 200, "left")
    love.graphics.printf("Miss: " .. state.missedHits, x, y + 50, 200, "left")
    love.graphics.printf("Max Combo: " .. state.maxCombo, x, y + 75, 200, "left")
end

local function drawHealthBar(health, colors)
    local width = 200
    local height = 20
    local x = love.graphics.getWidth() - width - 50
    local y = 50
    
    -- Draw background
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Draw health
    local healthColor = health < 30 and colors.healthLow or colors.health
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", x, y, width * (health/100), height)
end

local function drawCombo(combo, scale, colors, fonts)
    love.graphics.setColor(colors.combo)
    love.graphics.setFont(fonts.combo)
    
    -- Draw with scale effect
    local text = combo .. " COMBO"
    local textWidth = fonts.combo:getWidth(text)
    local x = love.graphics.getWidth()/2
    local y = love.graphics.getHeight() - 150
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(scale, scale)
    love.graphics.printf(text, -textWidth/2, 0, textWidth, "center")
    love.graphics.pop()
end

local function drawHitRating(rating, colors, fonts)
    love.graphics.setFont(fonts.large)
    
    if rating == "Perfect" then
        love.graphics.setColor(colors.perfect)
    elseif rating == "Good" then
        love.graphics.setColor(colors.good)
    else
        love.graphics.setColor(colors.miss)
    end
    
    love.graphics.printf(rating, 0, love.graphics.getHeight() - 200, love.graphics.getWidth(), "center")
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