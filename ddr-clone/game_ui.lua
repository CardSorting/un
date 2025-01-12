local ui = require('ui_config')

local gameUI = {}

function gameUI.drawProgressBar(gameTime, songLength, colors)
    local width = 300
    local height = 3
    local x = (love.graphics.getWidth() - width) / 2
    local y = 5
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.7)  -- Dark background
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Fill
    local progress = math.min(gameTime / songLength, 1)
    love.graphics.setColor(0.6, 0.6, 0.6, 0.9)  -- Light fill
    love.graphics.rectangle("fill", x, y, width * progress, height)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function gameUI.drawSongInfo(songName, colors, fonts)
    local width = 300
    local height = 20
    local x = (love.graphics.getWidth() - width) / 2
    local y = 12
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Text
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.setFont(fonts.small)
    love.graphics.printf(songName, x, y + 2, width, "center")
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function gameUI.drawScorePanel(score, multiplier, colors, fonts)
    local x = 10
    local y = 150
    local width = 150
    local height = 90
    
    -- Panel background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Score
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.setFont(fonts.medium)
    love.graphics.print(string.format("%07d", score), x + 10, y + 10)
    
    -- Multiplier
    love.graphics.setFont(fonts.multiplier)
    love.graphics.setColor(1, 0.5, 0.8, 0.9)
    love.graphics.print(string.format("x%d", multiplier), x + 10, y + 50)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function gameUI.drawStatsPanel(gameState, colors, fonts)
    local width = 150
    local height = 90
    local x = love.graphics.getWidth() - width - 10
    local y = 150
    
    -- Panel background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Stats
    love.graphics.setFont(fonts.small)
    
    -- Perfect hits
    love.graphics.setColor(0.3, 1, 0.3, 0.9)
    love.graphics.print(string.format("Perfect: %d", gameState.perfectHits), x + 10, y + 10)
    
    -- Good hits
    love.graphics.setColor(0.3, 0.3, 1, 0.9)
    love.graphics.print(string.format("Good: %d", gameState.goodHits), x + 10, y + 30)
    
    -- Misses
    love.graphics.setColor(1, 0.3, 0.3, 0.9)
    love.graphics.print(string.format("Miss: %d", gameState.missedHits), x + 10, y + 50)
    
    -- Accuracy
    love.graphics.setColor(1, 1, 1, 0.9)
    local totalNotes = gameState.perfectHits + gameState.goodHits + gameState.missedHits
    local accuracy = totalNotes > 0 and
        math.floor((gameState.perfectHits + gameState.goodHits * 0.5) / totalNotes * 100) or 100
    love.graphics.print(string.format("Acc: %d%%", accuracy), x + 10, y + 70)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function gameUI.drawHealthBar(health, colors)
    local width = 200
    local height = 6
    local x = (love.graphics.getWidth() - width) / 2
    local y = love.graphics.getHeight() - 10
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Health bar
    if health > 30 then
        love.graphics.setColor(0.3, 1, 0.3, 0.9)  -- Green for healthy
    else
        love.graphics.setColor(1, 0.3, 0.3, 0.9)  -- Red for low health
    end
    love.graphics.rectangle("fill", x, y, (width * health) / 100, height)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function gameUI.drawCombo(combo, scale, colors, fonts)
    if combo > 0 then
        love.graphics.setFont(fonts.combo)
        love.graphics.setColor(1, 0.8, 0.2, 0.9)
        love.graphics.push()
        love.graphics.translate(love.graphics.getWidth()/2, 60)
        love.graphics.scale(scale * 0.7)
        love.graphics.printf(string.format("%d", combo), -50, 0, 100, "center")
        love.graphics.pop()
        
        -- Reset color
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function gameUI.drawHitRating(rating, colors, fonts)
    love.graphics.setFont(fonts.medium)
    if rating == "Perfect" then
        love.graphics.setColor(0.3, 1, 0.3, 0.9)
    elseif rating == "Good" then
        love.graphics.setColor(0.3, 0.3, 1, 0.9)
    else
        love.graphics.setColor(1, 0.3, 0.3, 0.9)
    end
    love.graphics.printf(rating, 0, 30, love.graphics.getWidth(), "center")
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return gameUI