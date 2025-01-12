local ui = require('ui_config')

local gameplay = {}

function gameplay.createArrowColors()
    return {
        left = {{1, 0, 0, 0.9}, {0.6, 0, 0, 0.3}},    -- Red with transparency
        down = {{0, 1, 0, 0.9}, {0, 0.6, 0, 0.3}},    -- Green with transparency
        up = {{0, 0, 1, 0.9}, {0, 0, 0.6, 0.3}},      -- Blue with transparency
        right = {{1, 1, 0, 0.9}, {0.6, 0.6, 0, 0.3}}  -- Yellow with transparency
    }
end

-- Store lane positions globally for consistent hit detection
local lanePositions = {
    left = 0,
    down = 0,
    up = 0,
    right = 0
}

function gameplay.createTargetArrows()
    local screenWidth = love.graphics.getWidth()
    local gameWidth = ui.gameArea.width
    local startX = (screenWidth - gameWidth) / 2
    
    -- Calculate and store lane center positions
    lanePositions.left = startX + ui.gameArea.laneWidth/2
    lanePositions.down = lanePositions.left + ui.gameArea.laneWidth + 20
    lanePositions.up = lanePositions.down + ui.gameArea.laneWidth + 20
    lanePositions.right = lanePositions.up + ui.gameArea.laneWidth + 20
    
    return {
        {x = lanePositions.left, y = ui.gameArea.targetY, direction = "left"},
        {x = lanePositions.down, y = ui.gameArea.targetY, direction = "down"},
        {x = lanePositions.up, y = ui.gameArea.targetY, direction = "up"},
        {x = lanePositions.right, y = ui.gameArea.targetY, direction = "right"}
    }
end

function gameplay.drawArrow(x, y, direction, isTarget, arrowColors)
    local colors = arrowColors[direction]
    local mainColor = colors[1]
    local glowColor = colors[2]
    local halfSize = ui.gameArea.arrowSize/2
    
    -- Draw lane guide
    if isTarget then
        love.graphics.setColor(ui.colors.laneGuide[1], ui.colors.laneGuide[2], 
            ui.colors.laneGuide[3], ui.colors.laneGuide[4])
        love.graphics.rectangle("fill", 
            x - ui.gameArea.laneWidth/2,
            y + halfSize,
            ui.gameArea.laneWidth,
            love.graphics.getHeight() - y - halfSize)
    end
    
    -- Draw glow effect for target arrows
    if isTarget then
        love.graphics.setColor(glowColor)
        love.graphics.circle("fill", x, y + halfSize, halfSize * 1.5)
    end
    
    -- Draw arrow
    love.graphics.setColor(mainColor)
    if direction == "up" then
        love.graphics.polygon("fill", 
            x, y,                    -- top point
            x - halfSize, y + ui.gameArea.arrowSize,    -- bottom left
            x + halfSize, y + ui.gameArea.arrowSize)    -- bottom right
    elseif direction == "down" then
        love.graphics.polygon("fill",
            x, y + ui.gameArea.arrowSize,              -- bottom point
            x - halfSize, y,        -- top left
            x + halfSize, y)        -- top right
    elseif direction == "left" then
        love.graphics.polygon("fill",
            x - halfSize, y + halfSize,    -- left point
            x + halfSize, y,             -- top right
            x + halfSize, y + ui.gameArea.arrowSize)      -- bottom right
    elseif direction == "right" then
        love.graphics.polygon("fill",
            x + halfSize, y + halfSize,    -- right point
            x - halfSize, y,             -- top left
            x - halfSize, y + ui.gameArea.arrowSize)      -- bottom left
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function gameplay.drawLaneEffects(targetArrows, laneEffects)
    love.graphics.setColor(ui.colors.laneEffect[1], ui.colors.laneEffect[2], 
        ui.colors.laneEffect[3], ui.colors.laneEffect[4])
    for _, arrow in ipairs(targetArrows) do
        if laneEffects[arrow.direction] > 0 then
            love.graphics.rectangle("fill", 
                arrow.x - ui.gameArea.laneWidth/2,
                0,
                ui.gameArea.laneWidth,
                love.graphics.getHeight())
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function gameplay.drawHitEffects(hitEffects, colors)
    for _, effect in ipairs(hitEffects) do
        local color = colors.miss
        if effect.rating == "Perfect" then
            color = colors.perfect
        elseif effect.rating == "Good" then
            color = colors.good
        end
        love.graphics.setColor(color[1], color[2], color[3], effect.alpha * 0.3)
        love.graphics.circle("fill", effect.x, effect.y + ui.gameArea.arrowSize/2,
            ui.gameArea.arrowSize/2)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function gameplay.addHitEffect(x, y, rating)
    return {
        x = x,
        y = y,
        rating = rating,
        timer = ui.animation.hitEffectDuration,
        duration = ui.animation.hitEffectDuration,
        alpha = 1
    }
end

function gameplay.getArrowXPosition(direction)
    return lanePositions[direction]
end

function gameplay.isArrowInLane(arrow, direction)
    local laneCenter = lanePositions[direction]
    return math.abs(arrow.x - laneCenter) < 5  -- Small tolerance for position matching
end

function gameplay.checkHit(arrow, targetY, hitThreshold, perfectThreshold)
    local accuracy = math.abs(arrow.y - targetY)
    if accuracy < hitThreshold then
        if accuracy < perfectThreshold then
            return "Perfect"
        else
            return "Good"
        end
    end
    return nil
end

return gameplay